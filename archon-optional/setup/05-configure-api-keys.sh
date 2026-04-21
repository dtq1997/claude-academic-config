#!/bin/bash
# Archon 系统部署脚本 - 第五阶段：API Keys 配置

set -e

echo "=== API Keys 配置 ==="
echo ""

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

API_KEYS_FILE=~/ai/data/keys/api-keys.json

# 1. 检查现有配置
echo "## 1. 检查现有 API Keys"
if [ -f "$API_KEYS_FILE" ]; then
    echo "当前已配置的 API keys:"
    cat $API_KEYS_FILE | jq -r 'keys[]' | grep -v "^_" | while read key; do
        echo "  - $key"
    done
else
    echo -e "${RED}✗${NC} API keys 文件不存在"
    exit 1
fi
echo ""

# 2. 检查 Archon 所需的 keys
echo "## 2. Archon 所需 API Keys"
echo ""

MISSING=0

# 检查 Anthropic
if cat $API_KEYS_FILE | jq -e '.anthropic' > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Anthropic API (Claude Opus 4.6)"
else
    echo -e "${RED}✗${NC} Anthropic API (Claude Opus 4.6) - 必需"
    echo "  用途: 规划智能体 + Lean 智能体"
    echo "  获取: https://console.anthropic.com/"
    MISSING=1
fi

# 检查 Google Gemini
if cat $API_KEYS_FILE | jq -e '.google_gemini' > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Google Gemini API"
else
    echo -e "${RED}✗${NC} Google Gemini API - 必需"
    echo "  用途: 非正式智能体（数学推理）"
    echo "  获取: https://makersuite.google.com/app/apikey"
    MISSING=1
fi

# 检查 OpenAI（可选）
if cat $API_KEYS_FILE | jq -e '.openai' > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} OpenAI API (可选)"
else
    echo -e "${YELLOW}○${NC} OpenAI API - 可选"
    echo "  用途: 备用非正式智能体"
fi
echo ""

# 3. 生成配置模板
if [ $MISSING -eq 1 ]; then
    echo "## 3. 配置模板"
    echo ""
    echo "请编辑 $API_KEYS_FILE，添加以下字段:"
    echo ""
    cat << 'EOF'
{
  "anthropic": {
    "api_key": "sk-ant-api03-...",
    "model": "claude-opus-4-6"
  },
  "google_gemini": {
    "api_key": "AIza...",
    "model": "gemini-3.1-pro-preview"
  },
  "openai": {
    "api_key": "sk-proj-...",
    "model": "gpt-5.4"
  }
}
EOF
    echo ""
    echo -e "${RED}请配置缺失的 API keys 后重新运行此脚本${NC}"
    exit 1
fi

# 4. 创建环境变量文件
echo "## 4. 创建环境变量文件"
ENV_FILE=~/ai/workspace/archon/.env

cat > $ENV_FILE << EOF
# Archon 系统环境变量
# 自动生成于 $(date)

# Anthropic API
ANTHROPIC_API_KEY=$(cat $API_KEYS_FILE | jq -r '.anthropic.api_key // empty')

# Google Gemini API
GOOGLE_API_KEY=$(cat $API_KEYS_FILE | jq -r '.google_gemini.api_key // empty')

# OpenAI API (可选)
OPENAI_API_KEY=$(cat $API_KEYS_FILE | jq -r '.openai.api_key // empty')

# LeanSearch API
LEANSEARCH_API=https://leansearch.net/api
EOF

echo -e "${GREEN}✓${NC} 环境变量文件创建: $ENV_FILE"
echo ""

# 5. 测试 API 连接
echo "## 5. 测试 API 连接"
echo ""

# 测试 Anthropic
echo -n "测试 Anthropic API... "
ANTHROPIC_KEY=$(cat $API_KEYS_FILE | jq -r '.anthropic.api_key // empty')
if [ -n "$ANTHROPIC_KEY" ]; then
    if curl -s -o /dev/null -w "%{http_code}" \
        -H "x-api-key: $ANTHROPIC_KEY" \
        -H "anthropic-version: 2023-06-01" \
        https://api.anthropic.com/v1/messages | grep -q "200\|400"; then
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "${RED}✗ (连接失败)${NC}"
    fi
else
    echo -e "${YELLOW}跳过${NC}"
fi

# 测试 Gemini
echo -n "测试 Google Gemini API... "
GEMINI_KEY=$(cat $API_KEYS_FILE | jq -r '.google_gemini.api_key // empty')
if [ -n "$GEMINI_KEY" ]; then
    if curl -s -o /dev/null -w "%{http_code}" \
        "https://generativelanguage.googleapis.com/v1beta/models?key=$GEMINI_KEY" | grep -q "200"; then
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "${RED}✗ (连接失败)${NC}"
    fi
else
    echo -e "${YELLOW}跳过${NC}"
fi

echo ""
echo -e "${GREEN}✓ API Keys 配置完成${NC}"
echo ""
echo "下一步:"
echo "  bash ~/ai/workspace/archon/setup/06-create-skills.sh"
