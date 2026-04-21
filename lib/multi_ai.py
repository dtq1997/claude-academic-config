#!/usr/bin/env python3
"""
multi_ai — GPT / Gemini API 统一调用底层模块

设计原则：
- 底层函数，raise on error，不吞异常
- 不管理对话历史（messages/contents 由调用方传入）
- 不格式化返回值（不加 "— GPT xxx" 后缀）
- 通过回调支持进度通知（on_chunk / on_thinking）
- 配置热重载（mtime 检查）
"""

import json
import ssl
import os
import sys
import base64
import mimetypes
import tempfile
import urllib.request

# ── 常量 ──

USER_AGENT = "claude-code/2.1.39"
_SECRETS_PATH = os.environ.get("CLAUDE_SECRETS_PATH") or os.path.expanduser("~/ai/data/keys/api-keys.json")
_FALLBACK_MODELS = {"gemini": "gemini-3.1-pro", "gpt": "gpt-5.4"}

# ── 代理：保留本地代理（Clash 等），海外中转站需要走代理才能连通 ──

# ── SSL（全局共享） ──

SSL_CTX = ssl.create_default_context()
SSL_CTX.check_hostname = False
SSL_CTX.verify_mode = ssl.CERT_NONE

# ── 模型类型推断（内部用，不对外暴露选项列表） ──

def _model_type(name):
    """从模型名推断类型。"""
    if name.startswith("gpt-") or name.startswith("o"):
        return "gpt"
    if name == "gemini-3-pro-image":
        return "gemini-img"
    if name.startswith("gemini-"):
        return "gemini"
    if name.startswith("claude-"):
        return "claude"
    return "unknown"


# 向后兼容：旧代码可能引用 BASE_MODELS，改为动态属性
# 不再硬编码模型列表，所有选项来自上游配置
BASE_MODELS = {}  # deprecated, use get_models()

# ── 配置热重载 ──

_secrets = {}
_secrets_mtime = 0


def _reload_if_changed():
    """检查 secrets.json mtime，变化则重载。"""
    global _secrets, _secrets_mtime
    try:
        mtime = os.path.getmtime(_SECRETS_PATH)
    except OSError:
        return
    if mtime == _secrets_mtime:
        return
    try:
        with open(_SECRETS_PATH) as f:
            new = json.load(f)
        _secrets.clear()
        _secrets.update(new)
        _secrets_mtime = mtime
        _up = _secrets.get('upstreams', {})
        print(f"[multi_ai] 配置已重载: gemini={_up.get('gemini',{}).get('model','?')}, "
              f"gpt={_up.get('gpt',{}).get('model','?')}", file=sys.stderr)
    except (FileNotFoundError, json.JSONDecodeError) as e:
        print(f"[multi_ai] WARNING: 重载失败: {e}", file=sys.stderr)


# 首次加载
_reload_if_changed()


# ── 公共 API：配置 ──

def get_config():
    """返回完整配置快照（自动热重载）。"""
    _reload_if_changed()
    return dict(_secrets)


def get_upstream(service):
    """获取指定服务的 upstream 配置 dict。"""
    _reload_if_changed()
    return dict(_secrets.get('upstreams', {}).get(service, {}))


def default_model(service):
    """从配置获取默认模型名，回退到硬编码。"""
    _reload_if_changed()
    m = _secrets.get('upstreams', {}).get(service, {}).get('model', '')
    return m or _FALLBACK_MODELS.get(service, '')


def get_models():
    """返回当前可用的模型（仅来自上游配置 + 图片生成）。"""
    _reload_if_changed()
    models = {}
    for svc in ('gpt', 'gemini'):
        m = _secrets.get('upstreams', {}).get(svc, {}).get('model', '') or _FALLBACK_MODELS.get(svc, '')
        if m:
            models[m] = {"type": _model_type(m), "desc": "来自配置"}
    models["gemini-3-pro-image"] = {"type": "gemini-img", "desc": "图片生成"}
    return models


def force_reload():
    """强制重载配置（用于 web 保存后主动触发）。"""
    global _secrets_mtime
    _secrets_mtime = 0
    _reload_if_changed()


# ── 工具函数 ──

def build_gemini_parts(text, image_path=None):
    """构建 Gemini 请求的 parts 列表。"""
    parts = [{"text": text}]
    if image_path:
        with open(image_path, "rb") as f:
            img_b64 = base64.b64encode(f.read()).decode()
        mime = mimetypes.guess_type(image_path)[0] or "image/jpeg"
        parts.insert(0, {"inline_data": {"mime_type": mime, "data": img_b64}})
    return parts


def extract_gemini_thinking(full_text):
    """
    从 Gemini 响应中分离推理过程和回答。
    返回 (answer, thinking)。没检测到推理时 thinking 为空。
    """
    if "**" not in full_text or "\n\n" not in full_text:
        return full_text, ""

    lines = full_text.split("\n")
    thinking_start = -1
    for i, line in enumerate(lines):
        if line.strip().startswith("**") and line.strip().endswith("**"):
            thinking_start = i
            break

    if thinking_start < 0:
        return full_text, ""

    thinking_end = -1
    empty_count = 0
    for i in range(thinking_start + 1, len(lines)):
        if lines[i].strip() == "":
            empty_count += 1
            if empty_count >= 2:
                thinking_end = i
                break
        else:
            empty_count = 0

    if thinking_end <= thinking_start:
        return full_text, ""

    thinking_lines = lines[thinking_start + 1:thinking_end]
    answer_lines = lines[thinking_end + 1:]
    thinking_text = "\n".join(thinking_lines).strip()
    answer_text = "\n".join(answer_lines).strip()

    if thinking_text and answer_text:
        return answer_text, thinking_text

    return full_text, ""


# ── 核心调用：GPT ──

def call_gpt(messages, *, model=None, timeout=None, on_chunk=None, on_thinking=None):
    """
    调用 GPT API（流式）。

    Args:
        messages: 完整消息列表 [{"role":"user","content":"..."},...]
        model: 模型名，None 则从配置读
        timeout: HTTP 超时秒数
        on_chunk: callback(delta_text) — 每个内容 chunk
        on_thinking: callback(delta_text) — 每个推理 chunk

    Returns:
        (content, thinking) 二元组

    Raises:
        Exception on API error
    """
    _reload_if_changed()
    if model is None:
        model = default_model("gpt")

    gpt_config = get_upstream('gpt')
    url = gpt_config.get('base_url', 'https://api.openai.com/v1/responses')
    api_key = gpt_config.get('api_key', '')
    if not api_key:
        raise Exception("GPT 需要配置 upstreams.gpt.api_key")

    # 自动判断 API 格式
    is_responses_api = url.rstrip('/').endswith('/responses')

    if is_responses_api:
        body_data = {"model": model, "input": messages, "stream": True}
        body_data["reasoning"] = {"effort": "high"}
    else:
        body_data = {"model": model, "messages": messages, "stream": True}
        body_data["reasoning_effort"] = "high"

    body = json.dumps(body_data).encode()
    req = urllib.request.Request(url, data=body, headers={
        "Content-Type": "application/json",
        "Authorization": f"Bearer {api_key}",
        "User-Agent": USER_AGENT,
    })

    open_kwargs = {"context": SSL_CTX}
    if timeout is not None:
        open_kwargs["timeout"] = timeout

    try:
        resp = urllib.request.urlopen(req, **open_kwargs)
    except urllib.error.HTTPError as e:
        err_body = e.read().decode('utf-8', errors='ignore')[:300]
        raise Exception(f"GPT API {e.code}: {err_body}") from None

    chunks, thinking_chunks = [], []
    _unmatched_types = set()
    for line in resp:
        line = line.decode().strip()
        if not line.startswith("data: ") or line == "data: [DONE]":
            continue
        try:
            d = json.loads(line[6:])
            # foxcode Responses API 格式
            if d.get("type") == "response.output_text.delta":
                text = d.get("delta", "")
                if text:
                    chunks.append(text)
                    if on_chunk:
                        on_chunk(text)
            elif d.get("type") == "response.reasoning_text.delta":
                text = d.get("delta", "")
                if text:
                    thinking_chunks.append(text)
                    if on_thinking:
                        on_thinking(text)
            # Responses API: tool use events (GPT-5.x agentic)
            elif d.get("type", "").startswith("response.function_call"):
                pass  # tool use 中间事件，静默跳过
            elif d.get("type") in ("response.created", "response.in_progress",
                                    "response.output_item.added",
                                    "response.output_item.done",
                                    "response.content_part.added",
                                    "response.content_part.done",
                                    "response.output_text.done",
                                    "response.reasoning_text.done",
                                    "response.completed", "response.done"):
                pass  # 生命周期事件，静默跳过
            # 标准 OpenAI Chat Completions 格式
            elif "choices" in d and d["choices"]:
                delta = d["choices"][0].get("delta", {})
                rc = delta.get("reasoning_content", "")
                if rc:
                    thinking_chunks.append(rc)
                    if on_thinking:
                        on_thinking(rc)
                c = delta.get("content", "")
                if c:
                    chunks.append(c)
                    if on_chunk:
                        on_chunk(c)
            else:
                evt_type = d.get("type", str(list(d.keys())[:3]))
                _unmatched_types.add(str(evt_type))
        except json.JSONDecodeError:
            pass

    if _unmatched_types:
        import sys
        print(f"[multi_ai] GPT unmatched SSE types: {_unmatched_types}", file=sys.stderr)

    return "".join(chunks), "".join(thinking_chunks)


# ── 核心调用：Gemini ──

def _gemini_endpoint(base_url):
    """确保 Gemini base_url 以 /v1beta/models 结尾。"""
    b = base_url.rstrip('/')
    if not b.endswith('/models'):
        b += '/v1beta/models'
    return b


def call_gemini(contents, *, model=None, timeout=None):
    """
    调用 Gemini API（非流式）。自动分离推理过程。

    Args:
        contents: Gemini 格式 [{"role":"user","parts":[{"text":"..."}]},...]
        model: 模型名，None 则从配置读
        timeout: HTTP 超时秒数

    Returns:
        (answer, thinking) 二元组

    Raises:
        Exception on API error
    """
    _reload_if_changed()
    if model is None:
        model = default_model("gemini")

    gemini_config = get_upstream('gemini')
    base_url = _gemini_endpoint(gemini_config.get('base_url', 'https://generativelanguage.googleapis.com/v1beta/models'))
    api_key = gemini_config.get('api_key', '')
    if not api_key:
        raise Exception("Gemini 需要配置 upstreams.gemini.api_key")

    url = f"{base_url}/{model}:generateContent"
    body = json.dumps({"contents": contents}).encode()
    req = urllib.request.Request(url, data=body, headers={
        "Content-Type": "application/json",
        "Authorization": f"Bearer {api_key}",
        "User-Agent": USER_AGENT,
    })

    open_kwargs = {"context": SSL_CTX}
    if timeout is not None:
        open_kwargs["timeout"] = timeout

    try:
        resp = urllib.request.urlopen(req, **open_kwargs)
    except urllib.error.HTTPError as e:
        err_body = e.read().decode('utf-8', errors='ignore')[:300]
        raise Exception(f"Gemini API {e.code}: {err_body}") from None

    data = json.loads(resp.read().decode())
    parts = data.get("candidates", [{}])[0].get("content", {}).get("parts", [])
    full_text = "".join(p.get("text", "") for p in parts)

    answer, thinking = extract_gemini_thinking(full_text)
    return answer, thinking


# ── 核心调用：Gemini 图片生成 ──

def call_gemini_image(prompt, *, model="gemini-3-pro-image"):
    """
    Gemini 图片生成。

    Returns:
        (texts: list[str], image_paths: list[str])

    Raises:
        Exception on API error
    """
    _reload_if_changed()
    gemini_config = get_upstream('gemini')
    base_url = _gemini_endpoint(gemini_config.get('base_url', 'https://generativelanguage.googleapis.com/v1beta/models'))
    api_key = gemini_config.get('api_key', '')
    if not api_key:
        raise Exception("Gemini 需要配置 upstreams.gemini.api_key")

    url = f"{base_url}/{model}:generateContent"
    body = json.dumps({
        "contents": [{"role": "user", "parts": [{"text": prompt}]}],
        "generationConfig": {"responseModalities": ["TEXT", "IMAGE"]},
    }).encode()
    req = urllib.request.Request(url, data=body, headers={
        "Content-Type": "application/json",
        "Authorization": f"Bearer {api_key}",
        "User-Agent": USER_AGENT,
    })
    resp = urllib.request.urlopen(req, context=SSL_CTX)
    data = json.loads(resp.read().decode())
    parts = data.get("candidates", [{}])[0].get("content", {}).get("parts", [])

    texts, image_paths = [], []
    for p in parts:
        if "text" in p:
            texts.append(p["text"])
        elif "inline_data" in p:
            img_data = base64.b64decode(p["inline_data"]["data"])
            mime = p["inline_data"].get("mime_type", "image/png")
            ext = ".png" if "png" in mime else ".jpg"
            fpath = os.path.join(tempfile.gettempdir(), f"gemini_img_{len(image_paths)}{ext}")
            with open(fpath, "wb") as f:
                f.write(img_data)
            image_paths.append(fpath)

    return texts, image_paths


# ── 配置写入：下游同步（SSOT: secrets.json → 各 CLI 配置文件） ──

_HOME = os.path.expanduser("~")
_CLAUDE_SETTINGS = os.path.join(_HOME, ".claude", "settings.json")
_GEMINI_ENV = os.path.join(_HOME, ".gemini", ".env")
_CODEX_AUTH = os.path.join(_HOME, ".codex", "auth.json")
_CODEX_CONF = os.path.join(_HOME, ".codex", "config.toml")


def sync_downstream(upstreams=None):
    """
    将 upstreams 同步到所有下游 CLI 配置文件。
    如果 upstreams 为 None，使用当前内存中的 _secrets。

    同步目标：
    1. ~/.claude/settings.json
    2. ~/.gemini/.env
    3. ~/.codex/auth.json + config.toml

    返回 (ok: bool, errors: list[str])。部分失败不阻断后续。
    """
    if upstreams is None:
        _reload_if_changed()
        upstreams = _secrets.get('upstreams', {})

    errors = []

    # 1. Claude: settings.json
    claude_cfg = upstreams.get('claude', {})
    if claude_cfg.get('provider') == 'official':
        # 官方账号模式：移除 ANTHROPIC_* env，注入 NODE_OPTIONS 代理让 OAuth 走 Clash
        _proxy_bootstrap = os.path.join(os.path.expanduser("~"), "ai", "config", "node-proxy-bootstrap.js")
        try:
            try:
                with open(_CLAUDE_SETTINGS) as f:
                    settings = json.load(f)
            except (FileNotFoundError, json.JSONDecodeError):
                settings = {"env": {}}
            env = settings.setdefault("env", {})
            for k in list(env.keys()):
                if k.startswith("ANTHROPIC_"):
                    del env[k]
            # 注入 NODE_OPTIONS 让 Node.js 走代理（幂等：先移除旧值再添加）
            _require_flag = f"--require {_proxy_bootstrap}"
            old_opts = env.get("NODE_OPTIONS", "")
            clean_opts = old_opts.replace(_require_flag, "").strip()
            env["NODE_OPTIONS"] = f"{_require_flag} {clean_opts}".strip() if clean_opts else _require_flag
            os.makedirs(os.path.dirname(_CLAUDE_SETTINGS), exist_ok=True)
            with open(_CLAUDE_SETTINGS, 'w') as f:
                json.dump(settings, f, indent=2, ensure_ascii=False)
        except Exception as e:
            errors.append(f"claude/settings.json (official): {e}")
    elif claude_cfg.get('api_key'):
        _proxy_bootstrap = os.path.join(os.path.expanduser("~"), "ai", "config", "node-proxy-bootstrap.js")
        try:
            try:
                with open(_CLAUDE_SETTINGS) as f:
                    settings = json.load(f)
            except (FileNotFoundError, json.JSONDecodeError):
                settings = {"env": {}}

            settings.setdefault("env", {})
            settings["env"]["ANTHROPIC_API_KEY"] = claude_cfg["api_key"]
            settings["env"]["ANTHROPIC_BASE_URL"] = claude_cfg.get("base_url", "")
            model = claude_cfg.get("model", "").strip()
            if model:
                settings["env"]["ANTHROPIC_MODEL"] = model
            else:
                settings["env"].pop("ANTHROPIC_MODEL", None)
            # 切回第三方时清除代理注入（第三方中转不需要翻墙）
            _require_flag = f"--require {_proxy_bootstrap}"
            old_opts = settings["env"].get("NODE_OPTIONS", "")
            if _require_flag in old_opts:
                clean_opts = old_opts.replace(_require_flag, "").strip()
                if clean_opts:
                    settings["env"]["NODE_OPTIONS"] = clean_opts
                else:
                    settings["env"].pop("NODE_OPTIONS", None)

            os.makedirs(os.path.dirname(_CLAUDE_SETTINGS), exist_ok=True)
            with open(_CLAUDE_SETTINGS, 'w') as f:
                json.dump(settings, f, indent=2, ensure_ascii=False)
        except Exception as e:
            errors.append(f"claude/settings.json: {e}")

    # 2. Gemini: .env
    gemini_cfg = upstreams.get('gemini', {})
    if gemini_cfg.get('api_key') and os.path.isdir(os.path.dirname(_GEMINI_ENV)):
        try:
            base_url = gemini_cfg.get('base_url', '')
            gemini_base = base_url.split("/v1beta")[0] if "/v1beta" in base_url else base_url
            lines = [
                f"GOOGLE_GEMINI_BASE_URL={gemini_base}",
                f"GEMINI_API_KEY={gemini_cfg['api_key']}",
                f"GEMINI_MODEL={gemini_cfg.get('model') or _FALLBACK_MODELS.get('gemini', '')}",
            ]
            with open(_GEMINI_ENV, 'w') as f:
                f.write("\n".join(lines) + "\n")
        except Exception as e:
            errors.append(f".gemini/.env: {e}")

    # 3. Codex: auth.json + config.toml
    gpt_cfg = upstreams.get('gpt', {})
    if gpt_cfg.get('api_key') and os.path.isdir(os.path.dirname(_CODEX_AUTH)):
        try:
            # auth.json
            with open(_CODEX_AUTH, 'w') as f:
                json.dump({"auth_mode": "apikey", "OPENAI_API_KEY": gpt_cfg["api_key"]}, f, indent=2)

            # config.toml
            gpt_base = gpt_cfg.get('base_url', '')
            if gpt_base.endswith('/responses'):
                gpt_base = gpt_base.rsplit('/responses', 1)[0]
            gpt_model = gpt_cfg.get('model') or _FALLBACK_MODELS.get('gpt', '')

            # 保留现有 [projects.*] 和 [notice.*] 段
            preserved = []
            try:
                with open(_CODEX_CONF) as f:
                    in_preserve = False
                    for line in f:
                        s = line.strip()
                        if s.startswith('[projects.') or s.startswith('[notice.'):
                            in_preserve = True
                        elif s.startswith('[') and in_preserve:
                            if not s.startswith('[projects.') and not s.startswith('[notice.'):
                                in_preserve = False
                                continue
                        if in_preserve:
                            preserved.append(line.rstrip('\n'))
            except FileNotFoundError:
                pass

            parts = [
                f'model = "{gpt_model}"',
                'model_provider = "proxy"',
                '',
                '[model_providers.proxy]',
                'name = "Upstream proxy"',
                f'base_url = "{gpt_base}"',
                'env_key = "OPENAI_API_KEY"',
                '',
            ]
            if preserved:
                parts.extend(preserved)
            else:
                parts.append(f'[projects."{os.path.expanduser("~")}"]')
                parts.append('trust_level = "trusted"')
            parts.append('')

            with open(_CODEX_CONF, 'w') as f:
                f.write("\n".join(parts))
        except Exception as e:
            errors.append(f".codex: {e}")

    return len(errors) == 0, errors


def save_upstreams(new_upstreams, *, merge=False):
    """
    保存 upstreams 到 secrets.json 并同步所有下游。

    Args:
        new_upstreams: 新的 upstreams dict
        merge: True=逐服务逐字段合并（空 api_key 保留原值）；
               False=整体替换（GUI 全量保存用）

    Returns:
        (ok: bool, errors: list[str])
    """
    _reload_if_changed()

    if merge:
        existing = _secrets.get('upstreams', {})
        for svc in ('claude', 'gemini', 'gpt'):
            incoming = new_upstreams.get(svc, {})
            if not incoming:
                continue
            current = existing.setdefault(svc, {})
            for field in ('provider', 'base_url', 'model'):
                if field in incoming:
                    current[field] = incoming[field]
            if incoming.get('api_key'):
                current['api_key'] = incoming['api_key']
        final_upstreams = existing
    else:
        final_upstreams = new_upstreams

    _secrets['upstreams'] = final_upstreams

    # 写 secrets.json
    try:
        with open(_SECRETS_PATH, 'w') as f:
            json.dump(_secrets, f, indent=2, ensure_ascii=False)
    except Exception as e:
        return False, [f"secrets.json: {e}"]

    # 同步下游
    ok, errors = sync_downstream(final_upstreams)

    # 刷新内存
    force_reload()

    return ok, errors
