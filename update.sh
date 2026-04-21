#!/usr/bin/env bash
# 同步 Claude Code 学术配置种子包到最新版本
#
# 用法：
#   update.sh --check           检查更新，输出 JSON 差异清单（给 AI 读）
#   update.sh --apply [files...] 应用更新。不指定文件则全部应用，指定则只应用这些
#   update.sh --changelog       展示从当前版本到最新的所有 CHANGELOG 条目

set -euo pipefail

INSTALL_DIR="${HOME}/.claude-academic-config"
VERSION_MARKER="${HOME}/.claude/.seed-version"
BRANCH="${BRANCH:-main}"

[[ -d "$INSTALL_DIR/.git" ]] || {
  echo "错误：未找到种子仓库 $INSTALL_DIR" >&2
  echo "请先跑 install.sh" >&2
  exit 1
}

# ---------- 子命令分发 ----------
mode="${1:---check}"
shift || true

# ---------- 工具函数 ----------
current_version() {
  [[ -f "$VERSION_MARKER" ]] && cat "$VERSION_MARKER" | tr -d '[:space:]' || echo "未知"
}

latest_version() {
  cat "$INSTALL_DIR/VERSION" | tr -d '[:space:]'
}

fetch_remote() {
  # 优先用首次 clone 成功的镜像(写在 .mirror 文件里),失败再试其他
  local mirror=""
  [[ -f "$INSTALL_DIR/.mirror" ]] && mirror=$(cat "$INSTALL_DIR/.mirror")
  local orig_url
  orig_url=$(git -C "$INSTALL_DIR" remote get-url origin)
  local mirrors=("$mirror" "" "https://ghfast.top/" "https://gh-proxy.com/" "https://ghproxy.com/")
  for m in "${mirrors[@]}"; do
    local try_url="${m}${orig_url}"
    if git -C "$INSTALL_DIR" fetch "$try_url" "$BRANCH:refs/remotes/origin/$BRANCH" 2>&1 | tail -3 >&2; then
      echo "${m}" > "$INSTALL_DIR/.mirror"
      return 0
    fi
  done
  echo "错误: 所有镜像 fetch 均失败" >&2
  return 1
}

# ---------- --check 模式：生成 JSON 差异清单 ----------
cmd_check() {
  fetch_remote

  local cur_ver; cur_ver=$(current_version)
  local remote_ver; remote_ver=$(git -C "$INSTALL_DIR" show "origin/$BRANCH:VERSION" 2>/dev/null | tr -d '[:space:]')
  local local_ver; local_ver=$(latest_version)

  if [[ "$cur_ver" == "$remote_ver" ]] && [[ "$local_ver" == "$remote_ver" ]]; then
    cat << EOF
{"up_to_date": true, "current_version": "$cur_ver", "latest_version": "$remote_ver", "changes": []}
EOF
    return 0
  fi

  # 提取 changelog 差异：新版本在顶部，从第一个 YYYY-MM-DD 标题开始打印，
  # 遇到当前版本的标题就停止（不含当前版本）
  local changelog_excerpt
  changelog_excerpt=$(git -C "$INSTALL_DIR" show "origin/$BRANCH:CHANGELOG.md" 2>/dev/null \
    | awk -v cur="$cur_ver" '
        /^## [0-9]{4}-[0-9]{2}-[0-9]{2}$/ {
          if ($2 == cur) { exit }
          printing = 1
        }
        printing { print }
      ')

  # 列出有变更的文件（本地仓库 vs origin/branch）
  local changed_files
  changed_files=$(git -C "$INSTALL_DIR" diff --name-status "HEAD..origin/$BRANCH" 2>/dev/null || true)

  # 生成 JSON (用 python 保证转义正确)
  python3 - "$cur_ver" "$remote_ver" "$changelog_excerpt" "$changed_files" << 'PYEOF'
import json, sys
cur, latest, changelog, files_raw = sys.argv[1:5]
changes = []
for line in files_raw.strip().splitlines():
    if not line: continue
    parts = line.split('\t')
    if len(parts) < 2: continue
    status, path = parts[0], parts[1]
    type_map = {'A': 'new', 'M': 'modified', 'D': 'deleted', 'R': 'renamed'}
    changes.append({
        'file': path,
        'type': type_map.get(status[0], status),
    })
print(json.dumps({
    'up_to_date': False,
    'current_version': cur,
    'latest_version': latest,
    'changelog_excerpt': changelog.strip(),
    'changes': changes,
}, ensure_ascii=False, indent=2))
PYEOF
}

# ---------- --apply 模式：实际拉取并应用 ----------
cmd_apply() {
  fetch_remote

  if [[ $# -eq 0 ]]; then
    echo "» 全部应用：merge origin/$BRANCH" >&2
    # fetch_remote 已经把 origin/$BRANCH 更新到最新,直接 merge
    git -C "$INSTALL_DIR" merge --ff-only "origin/$BRANCH"
  else
    echo "» 部分应用：指定文件 $*" >&2
    # checkout 指定文件到最新版本（其他不动）
    for f in "$@"; do
      git -C "$INSTALL_DIR" checkout "origin/$BRANCH" -- "$f"
    done
    echo "⚠ 警告：部分应用会让本地仓库和 origin/$BRANCH 不一致。下次 --apply 会提示冲突。" >&2
  fi

  # 更新版本标记
  cp "$INSTALL_DIR/VERSION" "$VERSION_MARKER"
  echo "✓ 版本已更新: $(cat "$VERSION_MARKER")" >&2

  # 追加日志到 journal（方便以后回查）
  local log="$HOME/ai/memory/journal/config-updates.md"
  mkdir -p "$(dirname "$log")"
  {
    echo ""
    echo "## $(date '+%Y-%m-%d %H:%M:%S') 配置更新"
    echo "- 新版本: $(cat "$VERSION_MARKER")"
    if [[ $# -eq 0 ]]; then
      echo "- 范围: 全部"
    else
      echo "- 范围: $*"
    fi
  } >> "$log"
  echo "✓ 已记录到 $log" >&2
}

# ---------- --changelog 模式 ----------
cmd_changelog() {
  fetch_remote
  local cur_ver; cur_ver=$(current_version)
  git -C "$INSTALL_DIR" show "origin/$BRANCH:CHANGELOG.md" 2>/dev/null \
    | awk -v cur="$cur_ver" '
        /^## [0-9]{4}-[0-9]{2}-[0-9]{2}$/ {
          if ($2 == cur) { exit }
          printing = 1
        }
        printing { print }
      '
}

# ---------- 入口 ----------
case "$mode" in
  --check)     cmd_check "$@" ;;
  --apply)     cmd_apply "$@" ;;
  --changelog) cmd_changelog "$@" ;;
  -h|--help)
    cat << EOF
update.sh — Claude Code 学术配置种子包更新工具

  --check           输出 JSON 差异清单
  --apply [files]   应用更新。不指定则全部；指定则只拉那些文件
  --changelog       打印从当前版本到最新的 CHANGELOG 片段

例：
  update.sh --check
  update.sh --apply
  update.sh --apply rules/behavior.md shared/zotero-guide.md.template
EOF
    ;;
  *) echo "未知模式: $mode，用 --help" >&2; exit 1 ;;
esac
