# Changelog

本文件记录种子包的版本变更。**新版本放顶部**（紧接下面的 `---` 之后）。用户运行 `update.sh` 时，会展示他当前版本到最新版本之间的条目。

格式约定：每个版本一个 `## YYYY-MM-DD` 标题，条目用 `- 文件路径：一句话说人话的变更原因`。

---

## 2026-04-22

- `api-index.md`：替换原 `api-index-academic.md`，从 13 个学术 API 扩到 40+(含地图/天气/医学/图书/汉字/法律/植物等,去除个人 ID 脱敏)
- `lib/multi_ai.py`：GPT/Gemini 统一调用底层库,secrets 路径用 `CLAUDE_SECRETS_PATH` 环境变量(默认 `~/ai/data/keys/api-keys.json`)
- `tools/{books,medical,train,weather}/`：四个自包含 Python 工具(无第三方依赖),覆盖图书搜索、医学四件套(PubMed/ClinicalTrials/OpenFDA/MeSH)、12306 余票、天气全套
- `shared/ai-usage-knowledge-base.md`：AI 使用哲学(自举特性、批判性对话模式、配置即进化)
- `shared/math-trivia.md`：20 条数学深度冷知识(Borwein 积分、Monstrous Moonshine、Heegner、Painlevé 等),和方向相关/无关各一半
- `shared/multi-agent-collaboration.md`：三 AI 共管协议(Codex/Claude/Gemini 对等,shared 文件只追加等)
- `project-templates/math-survey/`:三 AI 协作数学综述项目脚手架(方法论、认识论分级、符号注册表、LLM 十大失败模式防护)
- `skills/mathematica-nb/`:新 skill,触发于 `.wl`/`.nb` 编辑和 Mathematica 排版
- `skills/math-survey/`:新 skill,触发于"写数学综述"等,自动搭脚手架
- `bootstrap.md`:首次安装后 claude 的自动引导流程(detect 模板未填 → 一次性收信息 → 自动填充 → 装 skills)
- `install.sh`:结尾说教改为"打开 claude 即可,会自动完成余下配置",埋 `_bootstrap-pending.md` 标记
- `rules/startup.md`:启动时先检查 bootstrap pending
- `rules/routing.md`:更新流程改为 Claude 自主判断,只在覆盖用户自定义时才 AskUserQuestion

## 2026-04-21

- 首发版本
- 包含 rules/（8 个自动加载规则）、modes/（academic/programming/dialogue/overnight）、shared/（research-methodology, academic-translation-workflow, mathematica-nb-guide, zotero 模板）、api-index-academic.md、skills-recommended.md、config-maintenance.md
- 可选模块：archon-optional/（Lean 4 自动形式化原型）
- 首个用户：杨成浪（数学学术方向）
