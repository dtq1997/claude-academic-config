# Archon — Lean 4 形式化项目

这是一个 Lean 4 + Mathlib 形式化项目，由 Archon 智能体系统管理。

## 形式化工作流

当用户要求形式化定理时，使用 `plan-agent` subagent 执行完整工作流：

1. **搭建框架**: plan-agent 分析非正式证明 → 调用 lean-agent 创建 Lean 文件 + sorry
2. **证明**: plan-agent 协调 lean-agent 逐个填充 sorry，失败时按类型选策略（Gemini 辅助 / 分解 / 路线更改）
3. **完善**: lean-agent 提取引理、优化风格

**触发词**: "形式化"、"证明"、"Lean"、"sorry"、任何数学定理陈述

## 项目结构

```
TestTheorem/          Lean 源码
docs/                 非正式证明（Markdown）
memory/               运行日志和进度记录
.claude/agents/       plan-agent + lean-agent 定义
```

## 可用工具

- **Lean LSP MCP**: lean_diagnostic_messages, lean_goal, lean_leansearch, lean_loogle 等
- **Gemini/GPT**: mcp__multi-ai__ask（数学推理）
- **LeanSearch**: 内置于 lean-lsp MCP

## 快捷用法

用户可以直接说：
- "形式化这个定理: ..."
- "帮我证明 xxx"
- "把 docs/xxx.md 里的证明形式化"

也可以用编排脚本无人值守运行：
```bash
python3 ~/ai/workspace/archon/tools/orchestrator.py docs/informal-proof.md .
```

## 注意事项

- 非正式证明放在 `docs/` 下（Markdown 格式）
- 进度记录在 `memory/progress.md`
- 阻塞问题记录到 `~/ai/memory/unresolved/archon-blockers.md`
- Lean 版本: 见 `lean-toolchain`
