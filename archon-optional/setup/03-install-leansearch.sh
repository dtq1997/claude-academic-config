#!/bin/bash
# Archon 系统部署脚本 - 第三阶段：LeanSearch 部署

set -e

echo "=== LeanSearch 本地部署 ==="
echo ""

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

ARCHON_DIR=~/ai/workspace/archon
LEANSEARCH_DIR=$ARCHON_DIR/tools/leansearch

# 1. 克隆 LeanSearch 仓库
echo "## 1. 获取 LeanSearch"
if [ -d "$LEANSEARCH_DIR" ]; then
    echo -e "${YELLOW}!${NC} LeanSearch 目录已存在"
    cd $LEANSEARCH_DIR
    echo "更新代码..."
    git pull || echo -e "${YELLOW}!${NC} 无法更新，使用现有版本"
else
    echo "克隆 LeanSearch 仓库..."
    git clone https://github.com/leanprover-community/leansearch.git $LEANSEARCH_DIR
    cd $LEANSEARCH_DIR
    echo -e "${GREEN}✓${NC} LeanSearch 克隆完成"
fi
echo ""

# 2. 安装依赖
echo "## 2. 安装 Node.js 依赖"
cd $LEANSEARCH_DIR
if [ -f "package.json" ]; then
    npm install
    echo -e "${GREEN}✓${NC} 依赖安装完成"
else
    echo -e "${RED}✗${NC} 未找到 package.json，仓库结构可能已变化"
    echo "请手动检查: $LEANSEARCH_DIR"
fi
echo ""

# 3. 配置说明
echo "## 3. 配置 LeanSearch"
echo ""
echo "LeanSearch 有两种使用方式:"
echo ""
echo "方式 1: 在线 API (推荐用于开始)"
echo "  - 直接使用 https://leansearch.net/api"
echo "  - 无需本地部署"
echo "  - 已集成到 Lean LSP MCP"
echo ""
echo "方式 2: 本地部署"
echo "  - 需要下载 Mathlib 索引数据"
echo "  - 占用约 2-5 GB 磁盘空间"
echo "  - 启动命令: cd $LEANSEARCH_DIR && npm start"
echo ""

# 4. 创建快捷脚本
cat > $ARCHON_DIR/tools/start-leansearch.sh << 'EOF'
#!/bin/bash
# 启动 LeanSearch 本地服务

LEANSEARCH_DIR=~/ai/workspace/archon/tools/leansearch

if [ ! -d "$LEANSEARCH_DIR" ]; then
    echo "错误: LeanSearch 未安装"
    echo "请先运行: bash ~/ai/workspace/archon/setup/03-install-leansearch.sh"
    exit 1
fi

cd $LEANSEARCH_DIR
echo "启动 LeanSearch 服务..."
echo "访问地址: http://localhost:3000"
echo "API 端点: http://localhost:3000/api/search"
echo ""
npm start
EOF

chmod +x $ARCHON_DIR/tools/start-leansearch.sh

echo -e "${GREEN}✓${NC} LeanSearch 配置完成"
echo ""
echo "快捷启动脚本: $ARCHON_DIR/tools/start-leansearch.sh"
echo ""
echo "下一步:"
echo "  bash ~/ai/workspace/archon/setup/04-configure-mcp.sh"
