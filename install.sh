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
    git clone --branch "$BRANCH" "$REPO_URL" "$INSTALL_DIR"
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
link_file "$INSTALL_DIR/shared/research-methodology.md" "$HOME/ai/memory/shared/research-methodology.md"
link_file "$INSTALL_DIR/shared/academic-translation-workflow.md" "$HOME/ai/memory/shared/academic-translation-workflow.md"
link_file "$INSTALL_DIR/shared/mathematica-nb-guide.md" "$HOME/ai/memory/shared/mathematica-nb-guide.md"

# 顶层
link_file "$INSTALL_DIR/api-index-academic.md" "$HOME/ai/data/keys/README.md"
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

# ---------- 结尾 ----------
echo
ok "$(c_green '安装完成！')"
echo
cat << 'EOF'
📋 接下来你需要做的：

1. 填写个人信息：
   编辑 ~/.claude/rules/identity.md        （你的身份、研究方向）
   编辑 ~/ai/config/modes/academic.md      （你的研究方向关键词、当前论文）

2. 填写 API keys（按需）：
   编辑 ~/ai/data/keys/api-keys.json

3. 重建 Zotero 标签体系：
   编辑 ~/ai/memory/shared/zotero-guide.md （模板里的数学方向标签换成你自己的）

4. 装推荐 skills：
   进入 claude 后说"按 ~/.claude-academic-config/skills-recommended.md 装推荐的 skills"

5. 以后想拉最新规则，直接在 claude 里说：
   "更新配置"  或  "同步最新规则"

验证：打开一个新的 claude 会话，说"今天心情不好"看是否自动进对话模式。
EOF
