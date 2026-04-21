#!/bin/bash
# Archon 系统部署脚本 - 第八阶段：最终配置

set -e

echo "=== Archon 系统最终配置 ==="
echo ""

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

ARCHON_DIR=~/ai/workspace/archon

# 1. 创建快速启动指南
cat > $ARCHON_DIR/QUICKSTART.md << 'EOF'
# Archon 快速启动指南

## 前置条件检查

运行环境检查：
```bash
bash ~/ai/workspace/archon/setup/01-check-env.sh
```

## 配置 API Keys

编辑 `~/ai/data/keys/api-keys.json`，添加：

```json
{
  "anthropic": {
    "api_key": "sk-ant-api03-...",
    "model": "claude-opus-4-6"
  },
  "google_gemini": {
    "api_key": "AIza...",
    "model": "gemini-3.1-pro-preview"
  }
}
```

然后运行：
```bash
bash ~/ai/workspace/archon/setup/05-configure-api-keys.sh
```

## 创建第一个项目

```bash
cd ~/ai/workspace/archon
./tools/archon.sh init my-first-theorem
```

## 手动形式化流程

由于完整的自动化编排需要深度集成 Claude Code API，当前版本采用**半自动化**工作流：

### 阶段 1: 搭建框架

1. 准备非正式证明（Markdown 格式）
2. 启动 Claude Code：
   ```bash
   cd ~/ai/workspace/archon/projects/my-first-theorem
   claude
   ```
3. 加载 Lean 智能体技能：
   ```
   请阅读 ~/ai/workspace/archon/skills/lean-agent.md
   ```
4. 指示智能体：
   ```
   请分析 docs/informal-proof.md，构建模块化的 Lean 文件结构，
   在每个证明义务处放置 sorry 占位符。
   ```

### 阶段 2: 证明

1. 启动新的 Claude Code 会话（规划智能体）：
   ```bash
   cd ~/ai/workspace/archon
   claude
   ```
2. 加载规划智能体技能：
   ```
   请阅读 ~/ai/workspace/archon/skills/plan-agent.md
   ```
3. 让规划智能体分析项目状态：
   ```
   请分析 ~/ai/workspace/archon/projects/my-first-theorem 的状态，
   识别所有待证明义务，并为每个义务生成工作计划。
   ```
4. 规划智能体会调用非正式智能体（Gemini）生成详细证明
5. 在另一个终端启动 Lean 智能体执行具体形式化

### 阶段 3: 验证与完善

1. 编译检查：
   ```bash
   cd ~/ai/workspace/archon/projects/my-first-theorem
   lake build
   ```
2. 启动 Claude Code 并加载 Lean 智能体技能
3. 指示智能体：
   ```
   请运行完善阶段：
   - 提取可重用引理
   - 移除 set_option maxHeartbeats
   - 简化证明项
   - 遵循 Mathlib 风格
   ```

## 使用 Gemini 非正式智能体

在 Claude Code 中调用 Gemini：

```
请使用 mcp__multi-ai__ask 工具，model 设为 gemini-3.1-pro-preview，
为以下定理生成详细的逐步证明：

[定理陈述]
```

## 查看项目状态

```bash
./tools/archon.sh status my-first-theorem
```

## 常见问题

### Q: 如何处理编译错误？
A: Lean 智能体会自动读取诊断信息并修复。如果重复失败，规划智能体会介入。

### Q: 如何处理 Mathlib 缺失的基础设施？
A: 规划智能体会调用非正式智能体提出替代证明路线（策略 C）。

### Q: 如何并行处理多个证明义务？
A: 启动多个 Lean 智能体会话，每个处理一个独立的 sorry。

## 进阶：完全自动化

完全自动化需要：
1. 实现 Claude Code API 集成
2. 开发智能体间通信协议
3. 实现自动会话管理

当前版本提供了所有必要的组件和技能文件，但需要手动协调。

## 示例项目

参考 FirstProof 问题 6 的形式化流程：
- 非正式证明：约 2 页
- 形式化代码：约 500 行 Lean
- 成本：< $2000
- 时间：2-3 天（自动化）

## 获取帮助

- 查看技能文件：`~/ai/workspace/archon/skills/`
- 查看会话日志：`~/ai/workspace/archon/memory/`
- 记录问题：`~/ai/memory/unresolved/archon-blockers.md`
EOF

echo -e "${GREEN}✓${NC} 快速启动指南: $ARCHON_DIR/QUICKSTART.md"
echo ""

# 2. 创建示例非正式证明
cat > $ARCHON_DIR/examples/simple-theorem.md << 'EOF'
# 示例定理：自然数加法交换律的推广

## 定理陈述

对于所有自然数 a, b, c，有 (a + b) + c = (a + c) + b。

## 证明

**步骤 1**: 根据自然数加法的结合律，我们有：
```
(a + b) + c = a + (b + c)
```

**步骤 2**: 根据自然数加法的交换律，我们有：
```
b + c = c + b
```

**步骤 3**: 将步骤 2 的结果代入步骤 1：
```
a + (b + c) = a + (c + b)
```

**步骤 4**: 再次应用结合律：
```
a + (c + b) = (a + c) + b
```

**步骤 5**: 结合步骤 1、3、4，我们得到：
```
(a + b) + c = (a + c) + b
```

证毕。

## 形式化提示

- 使用 `Mathlib.Data.Nat.Basic`
- 关键引理：`Nat.add_assoc`, `Nat.add_comm`
- 策略：`ring` 或手动 `rw`
- 预计难度：简单（约 5 行 Lean 代码）
EOF

mkdir -p $ARCHON_DIR/examples
echo -e "${GREEN}✓${NC} 示例定理: $ARCHON_DIR/examples/simple-theorem.md"
echo ""

# 3. 创建配置摘要
cat > $ARCHON_DIR/CONFIG_SUMMARY.md << EOF
# Archon 配置摘要

生成时间: $(date)

## 目录结构

\`\`\`
~/ai/workspace/archon/
├── CLAUDE.md              # 项目概述
├── GEMINI.md              # Gemini 适配层
├── AGENTS.md              # 多智能体协同规则
├── QUICKSTART.md          # 快速启动指南
├── CONFIG_SUMMARY.md      # 本文件
├── setup/                 # 部署脚本
│   ├── 01-check-env.sh
│   ├── 02-install-mathlib.sh
│   ├── 03-install-leansearch.sh
│   ├── 04-configure-mcp.sh
│   ├── 05-configure-api-keys.sh
│   ├── 06-create-skills.sh
│   ├── 07-create-orchestrator.sh
│   └── 08-final-setup.sh
├── tools/                 # 工具集
│   ├── archon.sh          # 主入口脚本
│   ├── orchestrator.py    # Python 编排器
│   ├── leansearch/        # LeanSearch 本地实例
│   └── mcp-servers/       # MCP 服务器
├── skills/                # 智能体技能
│   ├── plan-agent.md
│   ├── lean-agent.md
│   └── informal-agent.md
├── projects/              # 形式化项目
├── memory/                # 会话记忆
└── examples/              # 示例
\`\`\`

## 已完成的配置

- [x] 环境检查
- [x] 目录结构创建
- [x] 技能文件生成
- [x] 编排器脚本
- [x] 快速启动指南
- [x] 示例文件

## 待完成的配置

- [ ] Mathlib 安装（运行 setup/02-install-mathlib.sh）
- [ ] LeanSearch 部署（运行 setup/03-install-leansearch.sh）
- [ ] MCP 服务器配置（运行 setup/04-configure-mcp.sh）
- [ ] API Keys 配置（运行 setup/05-configure-api-keys.sh）

## 系统要求

- Lean 4.28.0+
- Node.js 24+
- Python 3.13+
- 磁盘空间: 5-10 GB（包括 Mathlib）

## API Keys 需求

- **必需**: Anthropic API (Claude Opus 4.6)
- **必需**: Google Gemini API
- **可选**: OpenAI API (GPT-5.4)

## 使用方式

### 命令行工具
\`\`\`bash
~/ai/workspace/archon/tools/archon.sh help
\`\`\`

### 手动协调（当前推荐）
1. 阅读 QUICKSTART.md
2. 使用 Claude Code 手动加载技能文件
3. 按三阶段流程执行形式化

### 完全自动化（未来）
需要实现 Claude Code API 集成

## 成本估算

基于 FirstProof 问题 4/6 的经验：
- 研究级定理形式化: < \$2000
- 简单定理形式化: < \$50
- 改进变体形式化: ~\$50

## 下一步

1. 完成待配置项
2. 运行示例项目测试
3. 阅读技能文件熟悉工作流
4. 准备第一个真实形式化任务

## 获取帮助

- 技能文件: ~/ai/workspace/archon/skills/
- 示例: ~/ai/workspace/archon/examples/
- 问题记录: ~/ai/memory/unresolved/archon-blockers.md
EOF

echo -e "${GREEN}✓${NC} 配置摘要: $ARCHON_DIR/CONFIG_SUMMARY.md"
echo ""

# 4. 创建全局符号链接（可选）
echo "## 创建全局命令（可选）"
echo ""
echo "如果想在任何位置使用 'archon' 命令，运行:"
echo -e "${YELLOW}  sudo ln -s $ARCHON_DIR/tools/archon.sh /usr/local/bin/archon${NC}"
echo ""

# 5. 最终检查
echo "## 最终检查"
echo ""

COMPLETE=0
TOTAL=0

check_item() {
    TOTAL=$((TOTAL + 1))
    if [ -e "$1" ]; then
        echo -e "${GREEN}✓${NC} $2"
        COMPLETE=$((COMPLETE + 1))
    else
        echo -e "${RED}✗${NC} $2"
    fi
}

check_item "$ARCHON_DIR/CLAUDE.md" "项目文档"
check_item "$ARCHON_DIR/AGENTS.md" "多智能体协同规则"
check_item "$ARCHON_DIR/GEMINI.md" "Gemini 适配层"
check_item "$ARCHON_DIR/QUICKSTART.md" "快速启动指南"
check_item "$ARCHON_DIR/skills/plan-agent.md" "规划智能体技能"
check_item "$ARCHON_DIR/skills/lean-agent.md" "Lean 智能体技能"
check_item "$ARCHON_DIR/skills/informal-agent.md" "非正式智能体技能"
check_item "$ARCHON_DIR/tools/archon.sh" "命令行工具"
check_item "$ARCHON_DIR/tools/orchestrator.py" "Python 编排器"
check_item "$ARCHON_DIR/examples/simple-theorem.md" "示例定理"

echo ""
echo "配置完成度: $COMPLETE/$TOTAL"
echo ""

# 6. 生成下一步指令
echo "=== 下一步行动 ==="
echo ""
echo "1. 完成环境配置:"
echo "   bash ~/ai/workspace/archon/setup/02-install-mathlib.sh"
echo "   bash ~/ai/workspace/archon/setup/05-configure-api-keys.sh"
echo ""
echo "2. 阅读快速启动指南:"
echo "   cat ~/ai/workspace/archon/QUICKSTART.md"
echo ""
echo "3. 创建第一个项目:"
echo "   ~/ai/workspace/archon/tools/archon.sh init my-first-theorem"
echo ""
echo "4. 开始形式化:"
echo "   按照 QUICKSTART.md 中的手动流程执行"
echo ""
echo -e "${GREEN}✓ Archon 系统配置完成${NC}"
