#!/bin/bash
# Archon 完全自动化测试脚本

set -e

PROJECT_DIR="$HOME/ai/workspace/archon/projects/test-theorem"
INFORMAL_PROOF="$PROJECT_DIR/docs/informal-proof.md"

echo "╔════════════════════════════════════════════════════════════╗"
echo "║        Archon 完全自动化形式化系统 - 测试运行             ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# 检查项目目录
if [ ! -d "$PROJECT_DIR" ]; then
    echo "❌ 项目目录不存在: $PROJECT_DIR"
    exit 1
fi

# 检查非正式证明
if [ ! -f "$INFORMAL_PROOF" ]; then
    echo "❌ 非正式证明文件不存在: $INFORMAL_PROOF"
    exit 1
fi

echo "✓ 项目目录: $PROJECT_DIR"
echo "✓ 非正式证明: $INFORMAL_PROOF"
echo ""

# 运行编排器
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "启动 Archon 编排器..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

cd "$HOME/ai/workspace/archon/tools"
python3 orchestrator.py "$INFORMAL_PROOF" "$PROJECT_DIR"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "形式化完成！"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
