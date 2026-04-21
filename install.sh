#!/usr/bin/env bash
# 一键安装 Claude Code 学术配置种子包
#
# 使用方法：
#   curl -fsSL https://raw.githubusercontent.com/USER/REPO/main/install.sh | bash
# 或本地测试：
#   bash install.sh [--repo-url URL] [--branch BRANCH] [--local SOURCE_DIR]

set -euo pipefail

# ---------- 配置 ----------
REPO_URL="${REPO_URL:-https://github.com/dtq1997/claude-academic-config.git}"
BRANCH="${BRANCH:-main}"
LOCAL_SOURCE=""   # --local 模式用本地目录代替 git clone（调试用）
INSTALL_DIR="${HOME}/.claude-academic-config"
VERSION_MARKER="${HOME}/.claude/.seed-version"

# GitHub 镜像前缀列表（国内网络直连 github 不稳时逐个尝试）
# 空串 = 直连;其余是公共代理,把原 URL 前缀拼在它们后面即可
GH_MIRRORS=(
  ""
  "https://ghfast.top/"
  "https://gh-proxy.com/"
  "https://ghproxy.com/"
)

# ---------- 参数解析 ----------
while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo-url) REPO_URL="$2"; shift 2 ;;
    --branch) BRANCH="$2"; shift 2 ;;
    --local) LOCAL_SOURCE="$2"; shift 2 ;;
    -h|--help)
      echo "Usage: install.sh [--repo-url URL] [--branch BRANCH] [--local SOURCE_DIR]"
      exit 0 ;;
    *) echo "未知参数: $1"; exit 1 ;;
  esac
done

# ---------- 彩色输出 ----------
c_red()   { printf "\033[31m%s\033[0m" "$1"; }
c_green() { printf "\033[32m%s\033[0m" "$1"; }
c_yellow(){ printf "\033[33m%s\033[0m" "$1"; }
c_cyan()  { printf "\033[36m%s\033[0m" "$1"; }

say()  { printf "%s %s\n" "$(c_cyan '»')" "$1"; }
ok()   { printf "%s %s\n" "$(c_green '✓')" "$1"; }
warn() { printf "%s %s\n" "$(c_yellow '!')" "$1"; }
die()  { printf "%s %s\n" "$(c_red '✗')" "$1" >&2; exit 1; }

# ---------- 环境检查 ----------
say "检查依赖"
command -v git >/dev/null 2>&1 || die "需要 git，请先安装"
command -v python3 >/dev/null 2>&1 || die "需要 python3"
ok "依赖检查通过"

# ---------- 获取源 ----------
if [[ -n "$LOCAL_SOURCE" ]]; then
  say "从本地目录安装: $LOCAL_SOURCE"
  [[ -d "$LOCAL_SOURCE" ]] || die "本地目录不存在: $LOCAL_SOURCE"
  if [[ -d "$INSTALL_DIR" ]]; then
    warn "目标已存在，删除后重建: $INSTALL_DIR"
    rm -rf "$INSTALL_DIR"
  fi
  cp -R "$LOCAL_SOURCE" "$INSTALL_DIR"
else
  say "克隆种子仓库到 $INSTALL_DIR"
  if [[ -d "$INSTALL_DIR/.git" ]]; then
    warn "仓库已存在，执行 git pull"
    git -C "$INSTALL_DIR" fetch origin "$BRANCH"
    git -C "$INSTALL_DIR" checkout "$BRANCH"
    git -C "$INSTALL_DIR" pull --ff-only origin "$BRANCH"
  else
    [[ -d "$INSTALL_DIR" ]] && die "$INSTALL_DIR 已存在但不是 git 仓库，请先处理"
    # 依次尝试直连和各镜像
    cloned=0
    for mirror in "${GH_MIRRORS[@]}"; do
      url="${mirror}${REPO_URL}"
      say "尝试: ${mirror:-直连 github}"
      if git clone --depth 1 --branch "$BRANCH" "$url" "$INSTALL_DIR" 2>&1; then
        # 把 remote 改回原始 URL(未来 pull 从同镜像取,或直连)
        git -C "$INSTALL_DIR" remote set-url origin "$REPO_URL"
        # 写入可用镜像,供 update.sh 复用
        echo "${mirror}" > "$INSTALL_DIR/.mirror"
        cloned=1
        break
      fi
      warn "失败,尝试下一个"
      [[ -d "$INSTALL_DIR" ]] && rm -rf "$INSTALL_DIR"
    done
    [[ $cloned -eq 1 ]] || die "所有镜像都失败,请检查网络或手动下载仓库 zip"
  fi
fi
ok "种子源就绪"

# ---------- 创建本地目录 ----------
say "创建本地配置目录"
mkdir -p \
  "$HOME/.claude/rules" \
  "$HOME/ai/config/modes/academic" \
  "$HOME/ai/data/keys" \
  "$HOME/ai/memory/journal" \
  "$HOME/ai/memory/unresolved" \
  "$HOME/ai/memory/dialectics" \
  "$HOME/ai/memory/shared" \
  "$HOME/ai/workspace" \
  "$HOME/ai/archive"
ok "目录创建完成"

# ---------- 软链接通用文件（会被自动更新）----------
# 软链接 = 快捷方式。文件本体在 $INSTALL_DIR，git pull 一次所有地方同步更新
# 模板文件（*.template）走拷贝，用户填充后属于自己

link_file() {
  local src="$1" dst="$2"
  [[ -f "$src" ]] || { warn "源文件不存在，跳过: $src"; return; }
  mkdir -p "$(dirname "$dst")"
  if [[ -e "$dst" || -L "$dst" ]]; then
    if [[ -L "$dst" ]] && [[ "$(readlink "$dst")" == "$src" ]]; then
      return  # 已经是正确软链
    fi
    local bak="${dst}.backup-$(date +%Y%m%d-%H%M%S)"
    mv "$dst" "$bak"
    warn "已备份原文件到 $(basename "$bak")"
  fi
  ln -s "$src" "$dst"
}

say "建立软链接（通用规则文件，自动随仓库更新）"

# rules/
for f in behavior routing startup latex code config env; do
  link_file "$INSTALL_DIR/rules/${f}.md" "$HOME/.claude/rules/${f}.md"
done

# modes/
link_file "$INSTALL_DIR/modes/academic/ai-math-workflow.md" "$HOME/ai/config/modes/academic/ai-math-workflow.md"
link_file "$INSTALL_DIR/modes/programming.md" "$HOME/ai/config/modes/programming.md"
link_file "$INSTALL_DIR/modes/dialogue.md" "$HOME/ai/config/modes/dialogue.md"
link_file "$INSTALL_DIR/modes/overnight.md" "$HOME/ai/config/modes/overnight.md"

# shared/
for f in research-methodology academic-translation-workflow mathematica-nb-guide ai-usage-knowledge-base math-trivia multi-agent-collaboration; do
  link_file "$INSTALL_DIR/shared/${f}.md" "$HOME/ai/memory/shared/${f}.md"
done

# skills/（种子包自带）
mkdir -p "$HOME/.claude/skills"
for s in mathematica-nb math-survey; do
  link_file "$INSTALL_DIR/skills/${s}/skill.md" "$HOME/.claude/skills/${s}/skill.md"
done

# 顶层
link_file "$INSTALL_DIR/api-index.md" "$HOME/ai/data/keys/README.md"
link_file "$INSTALL_DIR/config-maintenance.md" "$HOME/ai/config/config-maintenance.md"

ok "通用文件软链完成"

# ---------- 拷贝模板（用户填充后属于自己，不会被覆盖）----------

copy_template_if_missing() {
  local src="$1" dst="$2"
  [[ -f "$src" ]] || { warn "模板不存在，跳过: $src"; return; }
  if [[ -f "$dst" ]]; then
    warn "已存在，跳过（不覆盖用户填写）: $dst"
    return
  fi
  mkdir -p "$(dirname "$dst")"
  cp "$src" "$dst"
  ok "拷贝模板: $(basename "$dst")"
}

say "拷贝模板文件（需你填写内容，不随仓库更新）"
copy_template_if_missing "$INSTALL_DIR/rules/identity.md.template" "$HOME/.claude/rules/identity.md"
copy_template_if_missing "$INSTALL_DIR/modes/academic.md.template" "$HOME/ai/config/modes/academic.md"
copy_template_if_missing "$INSTALL_DIR/shared/zotero-guide.md.template" "$HOME/ai/memory/shared/zotero-guide.md"

# ---------- 创建初始空文件 ----------
[[ -f "$HOME/ai/data/keys/api-keys.json" ]] || echo '{}' > "$HOME/ai/data/keys/api-keys.json"
[[ -f "$HOME/ai/memory/unresolved/config-issues.md" ]] || cat > "$HOME/ai/memory/unresolved/config-issues.md" << 'EOF'
# 配置痛点收集

格式：日期 + 现象 + 期望行为。积累 3+ 条触发优化。
EOF

# ---------- 顶层 CLAUDE.md ----------
if [[ ! -f "$HOME/CLAUDE.md" ]]; then
  cat > "$HOME/CLAUDE.md" << 'EOF'
## ~/ai/ 目录结构

| 目录 | 用途 |
|------|------|
| `archive/` | 已结束项目 + 已解决的 unresolved 归档 |
| `config/` | 行为规则：modes/、config-maintenance.md |
| `data/` | 原始数据、API key 等 |
| `memory/` | 跨会话知识：journal/、unresolved/、shared/ |
| `workspace/` | 活跃项目工作区 |

自动加载层（`.claude/rules/`）承载通用规则。按需加载层（`~/ai/config/`）按 routing.md 触发。
EOF
  ok "已创建 ~/CLAUDE.md"
fi

# ---------- 记录版本 ----------
cp "$INSTALL_DIR/VERSION" "$VERSION_MARKER"
ok "版本已记录: $(cat "$VERSION_MARKER")"

# ---------- 标记未完成的引导任务（供 claude 启动时自检） ----------
mkdir -p "$HOME/ai/memory/unresolved"
cat > "$HOME/ai/memory/unresolved/_bootstrap-pending.md" << 'EOF'
# [bootstrap] 首次安装引导

此文件由 install.sh 在 $(date '+%Y-%m-%d %H:%M:%S') 创建。

Claude 下次启动时应检测此文件,按 `~/.claude-academic-config/bootstrap.md` 流程:
- 问用户身份/研究方向,填充 ~/.claude/rules/identity.md 和 ~/ai/config/modes/academic.md
- 问是否填写 API keys(~/ai/data/keys/api-keys.json)
- 问是否现在装推荐 skills(见 ~/.claude-academic-config/skills-recommended.md)
- 全部完成后删除本文件

原则:Claude 自己判断、全自动,只在必须人类决定时问,问也只给大略描述。
EOF

# ---------- 结尾 ----------
echo
ok "$(c_green '安装完成！打开 claude 即可,会自动完成余下配置。')"
