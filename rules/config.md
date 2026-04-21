---
globs: ["CLAUDE.md", "ai/config/modes/**/*.md", "ai/config/config-maintenance.md", ".claude/rules/*.md", ".claude/settings.json"]
---

编辑配置文件前必须加载 `~/ai/config/config-maintenance.md` 并按变更规模分级执行工作流（轻量/标准/重型）。
- SSOT：同一规则不在两个文件中重复，子文件用指针
- CLAUDE.md 仅作目录索引（<30 行），通用规则写入 `.claude/rules/behavior.md`
