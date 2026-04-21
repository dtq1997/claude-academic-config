# lib/ — 底层库

## multi_ai.py — GPT / Gemini 统一调用

纯 Python 3 标准库实现,无依赖。提供向 GPT (OpenAI/中转) 和 Gemini 发请求的底层函数,支持:
- 配置热重载(检测 secrets.json 的 mtime 变化)
- 流式输出回调 (`on_chunk` / `on_thinking`)
- 多模态输入(Gemini 带图)
- 不吞异常,`raise on error`

### 配置文件

默认从 `~/ai/data/keys/api-keys.json` 读取,可通过环境变量 `CLAUDE_SECRETS_PATH` 覆盖。

配置格式:
```json
{
  "upstreams": {
    "gpt":    { "base_url": "https://...", "api_key": "...", "model": "gpt-5.4" },
    "gemini": { "base_url": "https://...", "api_key": "...", "model": "gemini-3.1-pro" }
  }
}
```

### 典型用法

```python
import os, sys
sys.path.insert(0, os.path.expanduser("~/.claude-academic-config/lib"))
from multi_ai import call_gpt, call_gemini, build_gemini_parts

# GPT: 传 messages 列表（OpenAI 格式）
answer = call_gpt([{"role": "user", "content": "prompt here"}])

# Gemini: 传 contents 列表（Google 格式）
parts = build_gemini_parts("prompt", image_path="/tmp/fig.png")  # 可带图
answer = call_gemini([{"role": "user", "parts": parts}])
```

高层封装(单轮对话、交叉验证)自己按需包一层即可。

### 作为 MCP server 使用

这个库本身不是 MCP,只是底层调用。把它包一层就能做成 MCP server。参考 `~/.claude-academic-config/modes/academic/ai-math-workflow.md`。
