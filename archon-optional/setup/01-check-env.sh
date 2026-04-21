#!/bin/bash
# Archon 系统部署脚本 - 第一阶段：环境检查

set -e

echo "=== Archon 系统环境检查 ==="
echo ""

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

check_command() {
    if command -v $1 &> /dev/null; then
        echo -e "${GREEN}✓${NC} $1 已安装: $(command -v $1)"
        return 0
    else
        echo -e "${RED}✗${NC} $1 未安装"
        return 1
    fi
}

check_version() {
    echo -e "${YELLOW}→${NC} $1 版本: $($2)"
}

# 1. 检查 Lean 环境
echo "## 1. Lean 环境"
check_command lean && check_version "Lean" "lean --version"
check_command elan && check_version "elan" "elan --version"
echo ""

# 2. 检查 Node.js（MCP 需要）
echo "## 2. Node.js 环境"
check_command node && check_version "Node.js" "node --version"
check_command npm && check_version "npm" "npm --version"
echo ""

# 3. 检查 Mathlib
echo "## 3. Mathlib 状态"
if [ -d ~/.elan/toolchains ]; then
    echo -e "${GREEN}✓${NC} Lean toolchains 目录存在"
    ls -1 ~/.elan/toolchains | head -5
else
    echo -e "${RED}✗${NC} Lean toolchains 目录不存在"
fi
echo ""

# 4. 检查 API Keys
echo "## 4. API Keys 配置"
if [ -f ~/ai/data/keys/api-keys.json ]; then
    echo -e "${GREEN}✓${NC} API keys 文件存在"
    echo "可用的 API keys:"
    cat ~/ai/data/keys/api-keys.json | jq -r 'keys[]' | grep -v "^_" | while read key; do
        echo "  - $key"
    done
else
    echo -e "${RED}✗${NC} API keys 文件不存在"
fi
echo ""

# 5. 检查 Python（用于工具脚本）
echo "## 5. Python 环境"
check_command python3 && check_version "Python" "python3 --version"
if python3 -c "import requests" 2>/dev/null; then
    echo -e "${GREEN}✓${NC} requests 库已安装"
else
    echo -e "${YELLOW}!${NC} requests 库未安装（可选）"
fi
echo ""

# 6. 检查 Git
echo "## 6. Git 环境"
check_command git && check_version "Git" "git --version"
echo ""

# 7. 检查磁盘空间
echo "## 7. 磁盘空间"
df -h ~ | tail -1 | awk '{print "可用空间: " $4}'
echo ""

# 8. 生成配置建议
echo "=== 下一步行动 ==="
echo ""

MISSING=0

if ! command -v lean &> /dev/null; then
    echo -e "${RED}[必需]${NC} 安装 Lean 4:"
    echo "  curl https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh -sSf | sh"
    MISSING=1
fi

if ! command -v node &> /dev/null; then
    echo -e "${RED}[必需]${NC} 安装 Node.js:"
    echo "  brew install node"
    MISSING=1
fi

if [ ! -f ~/ai/data/keys/api-keys.json ]; then
    echo -e "${YELLOW}[推荐]${NC} 配置 API keys:"
    echo "  需要添加 Anthropic 和 Google Gemini API keys"
    MISSING=1
fi

if [ $MISSING -eq 0 ]; then
    echo -e "${GREEN}✓ 所有必需组件已就绪${NC}"
    echo ""
    echo "可以继续执行:"
    echo "  bash ~/ai/workspace/archon/setup/02-install-mathlib.sh"
else
    echo ""
    echo "请先完成上述安装，然后重新运行此脚本"
fi
