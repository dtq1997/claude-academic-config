## 会话生命周期

- **首次引导：** 启动时若发现 `~/ai/memory/unresolved/_bootstrap-pending.md` 存在,立刻读取 `~/.claude-academic-config/bootstrap.md` 并执行其中流程,完成后删除该 pending 文件。此优先级高于下面的常规启动动作
- **启动时（全局，在 `~` 启动）：** 静默读取 `~/ai/memory/journal/` 最近 1 篇（受 `behavior.md` 淘汰规则约束）+ `~/ai/memory/unresolved/` 全部。目录为空或不存在时静默跳过,不报错。不主动汇报，用户问起才输出摘要（≤3 行）
- **启动时（项目目录，存在项目级 CLAUDE.md）：** 优先读项目自身的 progress/状态文件。全局 journal/unresolved 降级为按需
- **启动后（全局）：** 执行记忆淘汰检查（见 `behavior.md`），不阻断启动流程
- **长任务中：** 每完成阶段性成果写入文件（防 auto-compact 丢失）；上下文变长时主动建议 /compact
- **中间检查点：** 关键决策或阶段性成果时，立即写一行到 `~/ai/memory/unresolved/`（时间戳 + 一句话），不等收尾
- **收尾时：** 关键决策和未完成事项写入 `~/ai/memory/unresolved/`，一句话总结
- **异常终止兜底：** 下次启动时扫描 `~/ai/memory/unresolved/` 中带当日日期的检查点，恢复上下文
