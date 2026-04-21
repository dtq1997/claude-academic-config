## 自动模式识别

根据对话内容自动判断并加载对应模式文件，不需要用户显式选择。可同时加载多个。

| 场景信号 | 加载文件 |
|---------|---------|
| 闲聊、情绪、人生思考、自省 | `~/ai/config/modes/dialogue.md` |
| 写代码、调 bug、项目开发 | `~/ai/config/modes/programming.md` |
| 论文、数学、LaTeX、文献 | `~/ai/config/modes/academic.md` |
| "夜间模式"/"睡觉了"/"overnight" | `~/ai/config/modes/overnight.md` |
| Zotero、"加文献"、"文献库"、"打标签" | `~/ai/memory/shared/zotero-guide.md` |

**配置同步/更新触发词**（不加载模式，直接跑脚本）：

| 用户说 | 执行 |
|--------|------|
| "同步配置"/"更新配置"/"拉最新规则"/"检查配置更新" | `bash ~/.claude-academic-config/update.sh --check`，读 JSON → 用 AskUserQuestion 让用户选接受哪些 → `bash ~/.claude-academic-config/update.sh --apply [选中文件]` |
| "看配置更新了什么"/"最近的 changelog" | `bash ~/.claude-academic-config/update.sh --changelog` |

**多模式冲突解决：** 具体任务的模式规则优先于通用模式规则。

**规则：**
- 意图明确时直接加载，不问用户
- 意图不明确时简短问一句，不列菜单
- 话题切换时自动加载新模式，无需用户指令
- 用户随时可说"切到 X 模式"显式切换

## 配置优化

痛点驱动，不定期自审。痛点记录到 `~/ai/memory/unresolved/config-issues.md`，积累 3+ 条或用户要求时触发。详细流程见 `~/ai/config/config-maintenance.md`。
