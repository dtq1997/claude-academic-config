# Archon - 研究级数学形式化智能体系统

## 项目概述

Archon 是一个用于自动形式化研究级数学的双智能体系统，能够将详细的自然语言证明转换为 Lean 4 可验证的形式化代码。

**核心能力：**
- 代码库级别的形式化（数百到数千行 Lean 代码）
- 自动处理复杂的证明结构和依赖关系
- 与 Mathlib 深度集成
- 支持人机协作的形式化工作流

**已验证成果：**
- FirstProof 问题 6：完全自主完成
- FirstProof 问题 4：近乎自主（仅需一句话提示："使用 Vieta 公式"）

## 系统架构

### 三阶段工作流

```
阶段 1: 搭建框架 (Scaffolding)
  ↓ Lean 智能体分析非正式证明，构建模块化文件结构

阶段 2: 证明 (Proving)
  ↓ 规划智能体 ⟷ Lean 智能体 迭代循环
  ↓ 支持并行处理独立的证明义务

阶段 3: 验证与完善 (Verification & Polish)
  ↓ 提取可重用引理，优化证明复杂度，移除 maxHeartbeats 覆盖
```

### 双智能体设计

**规划智能体 (Plan Agent):**
- 全局视角分解任务
- 识别瓶颈并选择干预策略
- 在干净上下文中运行，避免上下文污染

**Lean 智能体:**
- 执行具体的形式化工作
- 接收聚焦的任务指令
- 处理编译错误和技术细节

### 三种干预策略

1. **详细非正式支持**: 调用非正式智能体生成逐步自然语言证明
2. **分解**: 将复杂证明拆分为可独立证明的子引理
3. **非正式路线更改**: 提出替代证明策略以绕过形式化障碍

## 核心工具栈

| 工具 | 用途 | 状态 |
|------|------|------|
| 非正式智能体 | 数学推理和证明生成（Gemini/GPT） | 需配置 |
| LeanSearch | Mathlib 模糊搜索 | 需部署 |
| Lean LSP MCP | 编译反馈和诊断 | 需配置 |
| 网络搜索 | 检索已发表论文和标准结果 | 已有 |
| 内存管理 | 持久化架构推理和失败经验 | 需实现 |

## 本地部署计划

### 依赖检查

- [x] Lean 4.29.0-rc6 已安装
- [x] elan 版本管理器
- [x] Node.js v24.13.1
- [x] Mathlib 已安装（test-theorem 项目）
- [x] API Keys 已配置
- [ ] LeanSearch 本地部署（使用在线 API）
- [ ] MCP 服务器配置

### API Keys 配置

- [x] Anthropic API (Claude Opus 4.6) - 主智能体
- [x] Google Gemini API (3.1 Pro) - 非正式智能体
- [x] OpenAI API (GPT-5.4) - 备用非正式智能体
- [x] LeanSearch 在线 API

配置文件：`~/ai/data/keys/api-keys.json`

### 文件结构

```
~/ai/workspace/archon/
├── CLAUDE.md              # 本文件
├── GEMINI.md              # Gemini 适配层
├── AGENTS.md              # 多智能体协同规则
├── setup/                 # 部署脚本
├── tools/                 # 工具集成
│   ├── leansearch/       # LeanSearch 本地实例
│   ├── informal-agent/   # 非正式智能体
│   └── mcp-servers/      # MCP 配置
├── skills/                # Lean 4 技能文件
├── projects/              # 形式化项目
└── memory/                # 智能体记忆持久化
```

## 关键设计原则

1. **工作流优先于模型选择**: 上下文管理和任务分解比提示工程更重要
2. **分离策略与执行**: 规划智能体在干净上下文中思考，Lean 智能体专注编码
3. **预生成非正式证明**: 避免重复推导，提供稳定的参考
4. **编译不是唯一目标**: 需要专门的完善阶段来提升代码质量
5. **形式化路径规划**: 识别并绕过 Mathlib 的基础设施 gap

## 已知限制

1. **库依赖问题**: 当标准证明需要 Mathlib 中不存在的基础设施时（如路径积分），需要人工指导替代路径
2. **代码重用性**: 智能体倾向于内联证明而非提取可重用引理（需完善阶段纠正）
3. **心跳限制**: 智能体倾向于增加 maxHeartbeats 而非简化证明（需完善阶段纠正）
4. **形式化路径选择**: 模型偏好训练分布中常见的证明方法，可能忽略更适合形式化的替代方案

## 下一步行动

1. 配置 Mathlib 环境
2. 部署 LeanSearch 本地实例
3. 实现非正式智能体（Gemini 后端）
4. 配置 Lean LSP MCP
5. 编写智能体编排脚本
6. 测试简单形式化任务

## 参考资源

### Archon 原始项目

- **作者**: Guoxiong Gao, Bin Wu, Zeming Sun, Jiedong Jiang, Wanyi He, Zichen Wang, Yutong Wang, Peihao Wu, Bin Dong（北大 BICMR / FrenzyMath）
- **代码**: 尚未开源（原文："一旦系统足够稳定以支持可重复使用，我们打算将其开源"）
- **原版调度器**: OpenClaw（我们用 `orchestrator.py` + `claude -p` 替代）

### FrenzyMath 工具链

| 工具 | 论文/仓库 | 与 Archon 的关系 |
|------|----------|-----------------|
| LeanSearch | [arXiv:2403.13310](https://arxiv.org/abs/2403.13310) / [leansearch.net](https://leansearch.net/) | Archon 增强版集成于 Lean LSP MCP |
| Herald | [arXiv:2410.10878](https://arxiv.org/abs/2410.10878) | Lean 4 自然语言标注数据集 |
| REAL-Prover | [arXiv:2505.20613](https://arxiv.org/abs/2505.20613) | 检索增强的 stepwise 证明器 |
| Mozi | [github.com/frenzymath/mozi](https://github.com/frenzymath/mozi) | VS Code Lean Copilot，计划集成 Archon |

### 相关系统

| 系统 | 链接 | 备注 |
|------|------|------|
| Numina-Lean-Agent | [arXiv:2601.14027](https://arxiv.org/abs/2601.14027) / [GitHub](https://github.com/project-numina/numina-lean-agent) | 架构最接近，Putnam 2025 满分 |
| Prover Agent | [arXiv:2506.19923](https://arxiv.org/abs/2506.19923) | 双智能体 informal+formal |
| FirstProof 基准 | [MathSci.ai](https://www.mathsci.ai/post/1stproof/) | 10 道研究级问题，Archon 解决了 #4 和 #6 |
| Mathlib | [leanprover-community.github.io](https://leanprover-community.github.io/mathlib4_docs/) | 263,000+ 定理，126,000+ 定义 |
| Bin Dong 主页 | [faculty.bicmr.pku.edu.cn/~dongbin](http://faculty.bicmr.pku.edu.cn/~dongbin/) | 项目 PI |

## 成本估算

根据论文报告：
- FirstProof 问题 4/6: 每个 < $2000
- 改进变体形式化: ~$50/个

预期本地运行成本主要来自 API 调用（Claude + Gemini）。
