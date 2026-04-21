#!/bin/bash
# Archon 系统部署脚本 - 第四阶段：MCP 服务器配置

set -e

echo "=== MCP 服务器配置 ==="
echo ""

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

ARCHON_DIR=~/ai/workspace/archon
MCP_DIR=$ARCHON_DIR/tools/mcp-servers

mkdir -p $MCP_DIR

# 1. 安装 Lean LSP MCP
echo "## 1. 安装 Lean LSP MCP"
if [ -d "$MCP_DIR/lean-lsp" ]; then
    echo -e "${YELLOW}!${NC} Lean LSP MCP 已存在"
else
    cd $MCP_DIR
    echo "克隆 Lean LSP MCP..."
    git clone https://github.com/leanprover-community/mcp-lean-lsp.git lean-lsp
    cd lean-lsp
    npm install
    echo -e "${GREEN}✓${NC} Lean LSP MCP 安装完成"
fi
echo ""

# 2. 配置 Claude Desktop MCP
echo "## 2. 配置 Claude Desktop MCP"
CLAUDE_CONFIG=~/Library/Application\ Support/Claude/claude_desktop_config.json

if [ -f "$CLAUDE_CONFIG" ]; then
    echo -e "${YELLOW}!${NC} Claude Desktop 配置文件已存在"
    echo "当前配置:"
    cat "$CLAUDE_CONFIG" | jq '.' 2>/dev/null || cat "$CLAUDE_CONFIG"
else
    echo "创建 Claude Desktop 配置..."
    mkdir -p "$(dirname "$CLAUDE_CONFIG")"

    cat > "$CLAUDE_CONFIG" << 'EOF'
{
  "mcpServers": {
    "lean-lsp": {
      "command": "node",
      "args": [
        "$HOME/ai/workspace/archon/tools/mcp-servers/lean-lsp/build/index.js"
      ],
      "env": {
        "LEANSEARCH_API": "https://leansearch.net/api"
      }
    }
  }
}
EOF
    echo -e "${GREEN}✓${NC} Claude Desktop 配置创建完成"
fi
echo ""

# 3. 配置 Claude Code MCP（如果使用 Claude Code CLI）
echo "## 3. 配置 Claude Code MCP"
CLAUDE_CODE_CONFIG=~/.config/claude/config.json

if [ -f "$CLAUDE_CODE_CONFIG" ]; then
    echo -e "${YELLOW}!${NC} Claude Code 配置文件已存在"
    echo "需要手动添加 MCP 服务器配置"
else
    echo -e "${YELLOW}!${NC} Claude Code 配置文件不存在"
    echo "如果使用 Claude Code CLI，请手动创建配置"
fi
echo ""

# 4. 创建 MCP 测试脚本
cat > $MCP_DIR/test-lean-lsp.sh << 'EOF'
#!/bin/bash
# 测试 Lean LSP MCP 服务器

echo "测试 Lean LSP MCP..."
cd ~/ai/workspace/archon/tools/mcp-servers/lean-lsp

# 启动服务器（后台）
node build/index.js &
PID=$!

sleep 2

# 发送测试请求
echo '{"jsonrpc":"2.0","id":1,"method":"tools/list"}' | nc localhost 3000 || echo "无法连接到 MCP 服务器"

# 清理
kill $PID 2>/dev/null

echo "测试完成"
EOF

chmod +x $MCP_DIR/test-lean-lsp.sh

echo -e "${GREEN}✓${NC} MCP 配置完成"
echo ""
echo "配置文件位置:"
echo "  - Claude Desktop: $CLAUDE_CONFIG"
echo "  - Claude Code: $CLAUDE_CODE_CONFIG"
echo ""
echo "测试脚本: $MCP_DIR/test-lean-lsp.sh"
echo ""
echo "下一步:"
echo "  bash ~/ai/workspace/archon/setup/05-configure-api-keys.sh"
