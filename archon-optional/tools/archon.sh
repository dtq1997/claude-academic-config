#!/bin/bash
# Archon 系统主入口脚本

set -e

ARCHON_DIR=~/ai/workspace/archon

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

usage() {
    cat << USAGE
Archon - 研究级数学形式化智能体系统

用法:
  archon init <项目名>              创建新的形式化项目
  archon formalize <非正式证明>     开始形式化流程
  archon status <项目名>            查看项目状态
  archon polish <项目名>            运行完善阶段
  archon help                       显示此帮助信息

示例:
  archon init firstproof-problem6
  archon formalize ~/papers/theorem.md
  archon status firstproof-problem6

环境变量:
  ARCHON_PROJECT_DIR    项目目录（默认: ~/ai/workspace/archon/projects）
  ARCHON_MEMORY_DIR     记忆目录（默认: ~/ai/workspace/archon/memory）
USAGE
}

init_project() {
    PROJECT_NAME=$1
    if [ -z "$PROJECT_NAME" ]; then
        echo -e "${RED}错误: 请提供项目名${NC}"
        exit 1
    fi

    PROJECT_DIR=${ARCHON_PROJECT_DIR:-$ARCHON_DIR/projects}/$PROJECT_NAME

    if [ -d "$PROJECT_DIR" ]; then
        echo -e "${YELLOW}警告: 项目已存在: $PROJECT_DIR${NC}"
        exit 1
    fi

    echo "创建项目: $PROJECT_NAME"
    mkdir -p $PROJECT_DIR/{src,docs,tests}

    cd $PROJECT_DIR
    lake init $PROJECT_NAME

    cat > $PROJECT_DIR/README.md << README
# $PROJECT_NAME

Archon 形式化项目

## 结构

- \`src/\`: Lean 源代码
- \`docs/\`: 非正式证明和文档
- \`tests/\`: 测试文件

## 状态

- 创建时间: $(date)
- 阶段: 初始化
README

    echo -e "${GREEN}✓${NC} 项目创建完成: $PROJECT_DIR"
}

formalize() {
    INFORMAL_PROOF=$1
    if [ -z "$INFORMAL_PROOF" ]; then
        echo -e "${RED}错误: 请提供非正式证明文件路径${NC}"
        exit 1
    fi

    if [ ! -f "$INFORMAL_PROOF" ]; then
        echo -e "${RED}错误: 文件不存在: $INFORMAL_PROOF${NC}"
        exit 1
    fi

    echo "开始形式化流程..."
    echo "非正式证明: $INFORMAL_PROOF"
    echo ""
    echo -e "${YELLOW}注意: 完整的编排器实现需要与 Claude Code 集成${NC}"
    echo "当前版本提供框架，实际执行需要手动协调智能体"
    echo ""

    # 创建会话目录
    SESSION_ID=$(date +%Y%m%d_%H%M%S)
    SESSION_DIR=${ARCHON_MEMORY_DIR:-$ARCHON_DIR/memory}/session-$SESSION_ID
    mkdir -p $SESSION_DIR

    echo "会话 ID: $SESSION_ID"
    echo "会话目录: $SESSION_DIR"
    echo ""

    # 复制非正式证明
    cp $INFORMAL_PROOF $SESSION_DIR/informal-proof.md

    # 生成工作计划
    cat > $SESSION_DIR/plan.md << PLAN
# 形式化工作计划

## 非正式证明
$(basename $INFORMAL_PROOF)

## 阶段

### 1. 搭建框架
- [ ] 分析非正式证明结构
- [ ] 创建模块化文件结构
- [ ] 定义定理签名
- [ ] 放置 sorry 占位符

### 2. 证明
- [ ] 识别所有待证明义务
- [ ] 逐个填充 sorry
- [ ] 处理失败和重试

### 3. 验证与完善
- [ ] 验证编译通过
- [ ] 提取可重用引理
- [ ] 优化证明复杂度
- [ ] 遵循 Mathlib 风格

## 记录

$(date): 会话开始
PLAN

    echo -e "${GREEN}✓${NC} 工作计划创建: $SESSION_DIR/plan.md"
    echo ""
    echo "下一步: 手动启动 Claude Code 并加载规划智能体技能"
}

status() {
    PROJECT_NAME=$1
    if [ -z "$PROJECT_NAME" ]; then
        echo -e "${RED}错误: 请提供项目名${NC}"
        exit 1
    fi

    PROJECT_DIR=${ARCHON_PROJECT_DIR:-$ARCHON_DIR/projects}/$PROJECT_NAME

    if [ ! -d "$PROJECT_DIR" ]; then
        echo -e "${RED}错误: 项目不存在: $PROJECT_NAME${NC}"
        exit 1
    fi

    echo "项目状态: $PROJECT_NAME"
    echo "位置: $PROJECT_DIR"
    echo ""

    # 统计 sorry 数量
    SORRY_COUNT=$(find $PROJECT_DIR -name "*.lean" -exec grep -c "sorry" {} + 2>/dev/null | awk '{s+=$1} END {print s}')
    echo "待证明义务 (sorry): ${SORRY_COUNT:-0}"

    # 检查编译状态
    cd $PROJECT_DIR
    if lake build 2>&1 | grep -q "error"; then
        echo -e "编译状态: ${RED}失败${NC}"
    else
        echo -e "编译状态: ${GREEN}通过${NC}"
    fi
}

polish() {
    PROJECT_NAME=$1
    if [ -z "$PROJECT_NAME" ]; then
        echo -e "${RED}错误: 请提供项目名${NC}"
        exit 1
    fi

    PROJECT_DIR=${ARCHON_PROJECT_DIR:-$ARCHON_DIR/projects}/$PROJECT_NAME

    if [ ! -d "$PROJECT_DIR" ]; then
        echo -e "${RED}错误: 项目不存在: $PROJECT_NAME${NC}"
        exit 1
    fi

    echo "运行完善阶段: $PROJECT_NAME"
    echo ""
    echo -e "${YELLOW}注意: 需要手动启动 Claude Code 并加载 Lean 智能体技能${NC}"
    echo ""
    echo "完善任务:"
    echo "  1. 提取可重用引理"
    echo "  2. 移除 set_option maxHeartbeats"
    echo "  3. 简化证明项"
    echo "  4. 遵循 Mathlib 风格"
}

# 主逻辑
case "${1:-help}" in
    init)
        init_project "$2"
        ;;
    formalize)
        formalize "$2"
        ;;
    status)
        status "$2"
        ;;
    polish)
        polish "$2"
        ;;
    help|--help|-h)
        usage
        ;;
    *)
        echo -e "${RED}错误: 未知命令: $1${NC}"
        echo ""
        usage
        exit 1
        ;;
esac
