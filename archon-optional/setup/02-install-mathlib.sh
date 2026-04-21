#!/bin/bash
# Archon 系统部署脚本 - 第二阶段：Mathlib 配置

set -e

echo "=== Archon Mathlib 配置 ==="
echo ""

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

ARCHON_DIR=~/ai/workspace/archon
TEST_PROJECT_DIR=$ARCHON_DIR/projects/mathlib-test

# 1. 创建测试项目
echo "## 1. 创建 Lean 测试项目"
if [ -d "$TEST_PROJECT_DIR" ]; then
    echo -e "${YELLOW}!${NC} 测试项目已存在，跳过创建"
else
    mkdir -p $TEST_PROJECT_DIR
    cd $TEST_PROJECT_DIR

    echo "初始化 Lean 项目..."
    lake init mathlib-test

    echo -e "${GREEN}✓${NC} 项目创建完成"
fi
echo ""

# 2. 添加 Mathlib 依赖
echo "## 2. 配置 Mathlib 依赖"
cd $TEST_PROJECT_DIR

if grep -q "mathlib" lakefile.lean 2>/dev/null; then
    echo -e "${YELLOW}!${NC} Mathlib 依赖已配置"
else
    echo "添加 Mathlib 到 lakefile.lean..."
    lake exe cache get
    lake update
    echo -e "${GREEN}✓${NC} Mathlib 依赖配置完成"
fi
echo ""

# 3. 测试 Mathlib 可用性
echo "## 3. 测试 Mathlib"
cat > $TEST_PROJECT_DIR/MathLibTest/Test.lean << 'EOF'
import Mathlib.Data.Nat.Basic
import Mathlib.Tactic

-- 简单测试：证明 0 + n = n
example (n : ℕ) : 0 + n = n := by
  simp

-- 测试 Mathlib 策略
example (n m : ℕ) : n + m = m + n := by
  ring

#check Nat.add_comm
EOF

echo "编译测试文件..."
cd $TEST_PROJECT_DIR
if lake build MathLibTest.Test 2>&1 | tee /tmp/archon-mathlib-test.log; then
    echo -e "${GREEN}✓${NC} Mathlib 测试通过"
else
    echo -e "${RED}✗${NC} Mathlib 测试失败，查看日志: /tmp/archon-mathlib-test.log"
    exit 1
fi
echo ""

# 4. 检查 Mathlib 版本
echo "## 4. Mathlib 信息"
if [ -f "$TEST_PROJECT_DIR/lake-manifest.json" ]; then
    echo "Mathlib 版本信息:"
    cat $TEST_PROJECT_DIR/lake-manifest.json | jq -r '.packages[] | select(.name=="mathlib") | "  版本: \(.rev[0:8])\n  URL: \(.url)"' 2>/dev/null || echo "  (无法解析版本信息)"
fi
echo ""

# 5. 生成配置摘要
echo "=== 配置摘要 ==="
echo ""
echo "测试项目位置: $TEST_PROJECT_DIR"
echo "Mathlib 缓存位置: ~/.cache/mathlib4"
echo ""
echo -e "${GREEN}✓ Mathlib 配置完成${NC}"
echo ""
echo "下一步:"
echo "  bash ~/ai/workspace/archon/setup/03-install-leansearch.sh"
