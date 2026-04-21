# 推荐 skills 清单

Claude Code 的 skill 是按需加载的能力模块。以下是对做学术的人有用的 skills。

## 安装方式

大部分是官方 plugin 市场的 skill，进入 `claude` 后用 `/plugin` 打开界面装；或直接：

```bash
claude plugin install <skill-name>
```

（实际命令以 Claude Code 当前版本为准，必要时问你的 Claude "怎么装 pdf skill"）

## 推荐装（学术必备）

| Skill | 用途 | 学术场景 |
|-------|------|---------|
| `academic-writing` | 学术 LaTeX 写作、Zotero 文献管理、arXiv/Semantic Scholar/CrossRef/zbMATH/OpenAlex API 快速调用 | **最核心**。论文、课题本子、文献查找 |
| `pdf` | 读取/提取/合并/拆分/水印/OCR PDF | 读论文、处理扫描件 |
| `docx` | 创建/编辑 Word，处理表格、目录、页码、追踪修改 | 写报告、填表、回复审稿意见 |
| `xlsx` | 读写电子表格 | 处理实验数据、表格类清单 |
| `pptx` | 幻灯片创建、读取、编辑 | 做 talk、seminar |
| `deep-research` | 深度调查方法论：论文反向追踪、StackExchange API 盲区、综述优先 | 追某结果的起源、找文献 |
| `code-quality` | 写代码时自动质量检查 | 写数值实验、Mathematica 代码、脚本 |

## 视情况装

| Skill | 用途 | 场景 |
|-------|------|---------|
| `book-search` | 豆瓣/Anna's Archive 找书 | 找教材电子版 |
| `med-search` | PubMed/ClinicalTrials/FDA 等医学库 | 跨学科或医学相关 |
| `walled-garden-content` | 知乎/B站/豆瓣/微信 | 看中文社区资料、科普视频 |
| `claude-api` | Claude/Anthropic SDK 开发 | 自己写 AI 小工具 |
| `loop` | 周期性任务 | 监控 arXiv 新论文等 |

## 不推荐装（针对学术用户）

- `walled-garden-life`、`walled-garden-shopping`、`life-advisor` — 生活类，和学术无关
- `keybindings-help`、`update-config`、`less-permission-prompts` — Claude Code 配置类，会用再装
- `statusline-setup` — 可选，纯美化

## 自定义 skill

如果做出自己的 skill（比如"自动查今天 arXiv 新论文并翻译"），放 `~/.claude/skills/<name>/` 下，每个 skill 一个目录，含 `SKILL.md` 描述和入口。通过 `skill-creator` skill 可以引导你创建。
