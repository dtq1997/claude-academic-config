# Archon：Lean 4 自动形式化双智能体（可选模块）

## 这是什么

Archon 是原作者（唐乾）做的 Lean 4 自动形式化原型，用来把自然语言数学证明自动转成 Lean 4 的可验证代码。

**核心能力**：
- 研究级数学的代码库级形式化（数百到数千行 Lean 代码）
- 与 Mathlib 深度集成
- 人机协作的形式化工作流

**已验证**：FirstProof 问题 4、6 已能（近乎）自主完成。

## 适合谁

- 做 Lean/Mathlib 形式化的人
- 想实验"AI 自动化证明工作流"的人
- 对多智能体（multi-agent）编排感兴趣的人

**不适合**：从没接触过 Lean 的人。这东西假设你已经会写 Lean 4 并装好 Mathlib。

## 架构（双智能体 + 三阶段）

```
阶段 1: 搭建框架 (Scaffolding)
  Lean 智能体分析非正式证明 → 构建模块化 Lean 文件结构，sorry 占位

阶段 2: 证明 (Proving)
  规划智能体 ↔ Lean 智能体 迭代循环
  规划智能体: 全局分解任务、选择干预策略
  Lean 智能体: 执行具体形式化、处理编译错误

阶段 3: 验证与完善 (Verification & Polish)
  提取引理、移除 maxHeartbeats、遵循 Mathlib 风格
```

**三种干预策略**（规划智能体调用）：
1. 调用 Gemini 生成详细非正式逐步证明
2. 拆分复杂证明为可独立证明的子引理
3. 提出替代证明策略绕过形式化障碍

## 依赖

- Lean 4（`elan` 版本管理器）
- Mathlib（通过 `lake` 安装）
- Node.js（MCP server 要用）
- API keys：Anthropic (主智能体) + Gemini 或 OpenAI (非正式智能体) + LeanSearch 在线 API

## 当前状态（原作者注）

**半自动化** — 完整自动编排需要深度集成 Claude Code API，当前版本需要手动启动多个 Claude Code 会话并互相协调。核心组件和 skill 文件齐全，但自动会话管理尚未实现。

## 怎么用

1. 复制本目录下所有内容到 `~/ai/workspace/archon/`
2. 配置 `~/ai/data/keys/api-keys.json` 里的 Anthropic + Gemini 或 OpenAI key
3. 读 `QUICKSTART.md` 走第一个项目
4. Setup 脚本：`setup/01-check-env.sh` 开始逐步跑

## 原型状态

这是一个**原型**（prototype），不是成熟工具。适合想自己魔改和学习思路的人，不适合直接用在生产研究中。

真实源码路径在原作者的 `~/ai/archive/archon-prototype-2026-03/`。本模块只是把它打包成独立目录，代码原样。

## 替代方案

如果你只想体验 AI 辅助 Lean 证明但不想折腾架构，试试：
- LeanSearch（直接网页用）
- LeanDojo（学术工具，有 Python 接口）
- 单纯用 Claude Code + Lean LSP MCP
