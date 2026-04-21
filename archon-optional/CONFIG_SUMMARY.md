# Archon 配置摘要

生成时间: 2026年 3月16日 星期一 08时41分32秒 CST

## 目录结构

```
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
```

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
```bash
~/ai/workspace/archon/tools/archon.sh help
```

### 手动协调（当前推荐）
1. 阅读 QUICKSTART.md
2. 使用 Claude Code 手动加载技能文件
3. 按三阶段流程执行形式化

### 完全自动化（未来）
需要实现 Claude Code API 集成

## 成本估算

基于 FirstProof 问题 4/6 的经验：
- 研究级定理形式化: < $2000
- 简单定理形式化: < $50
- 改进变体形式化: ~$50

## 下一步

1. 完成待配置项
2. 运行示例项目测试
3. 阅读技能文件熟悉工作流
4. 准备第一个真实形式化任务

## 获取帮助

- 技能文件: ~/ai/workspace/archon/skills/
- 示例: ~/ai/workspace/archon/examples/
- 问题记录: ~/ai/memory/unresolved/archon-blockers.md
