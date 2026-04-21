# 首次安装引导流程(给 Claude 读的)

> 本文件由 Claude 在检测到 `~/ai/memory/unresolved/_bootstrap-pending.md` 存在时加载。用户不会主动读这个文件。

## 总原则

- **向导式,不是审讯式**:先介绍,再让用户选,最后收必要信息
- **介绍用人话**:不堆术语,每一类一句话说它能干嘛
- **默认全要**:用户点"全要",Claude 直接装完余下步骤,不再问
- **挑着要也行**:列模块清单,用户勾,Claude 按勾的装
- **可以后补**:任何步骤拒答都不阻断,pending 标记保留下次再问

## 流程(Claude 自执行)

### 步骤 1:开场 + 介绍

用户刚打开 claude,Claude 一上来先说一段(不等用户开口):

> 欢迎。这是唐乾的学术研究 AI 配置,已装好基座。我给你过一下里面是什么 ——
>
> 1. **学术大脑**:自动切换学术 / 编程 / 对话 / 生活 / 夜间模式,有对应的行为风格和工具
> 2. **40+ 外部 API**:arXiv、zbMATH、OpenAlex、Matlas(定理级搜索)、CrossRef 等,大部分免费无 key,查论文/查定理/查作者直接调用
> 3. **三家 AI 协同**:Claude + GPT + Gemini 可以互相请教、交叉验证(需要 GPT 和 Gemini 的 API key,可以以后再给)
> 4. **记忆系统**:journal(日记)、unresolved(悬置问题)、shared(跨 AI 共享笔记),自动积累,会话间不丢
> 5. **数学研究工作流**:按 Tao、Ryu 等人的 AI 使用方法论预置的规程,适合做 brainstorming、验证证明想法
> 6. **本地 Python 工具**:火车票、天气、图书、医学数据库,零依赖开箱即用
> 7. **推荐 skills**:academic-writing(论文/LaTeX/Zotero)、pdf、docx 等,需要你在 claude 里 `/plugin` 手动装
>
> 还有推荐一些进阶组件(matlas CLI 定理搜索、多 AI MCP、墙内工具)需要额外装,你想要时告诉我。

然后问一个 AskUserQuestion(**只问一句**):

- Q: 这套东西怎么用?
- A1: 全部都要(Claude 把模块都装上,只跟你收身份信息)
- A2: 挑着要(Claude 列模块让你勾)
- A3: 我先想想(保留 pending 标记,啥也不改)

### 步骤 2:按选择分支

**A1 全要:**
- 问一句"你叫什么 + 做什么方向?"
- 问一句"现在填 GPT / Gemini 的 API key 吗?还是以后?"(二选一)
- 按回答填 identity.md、academic.md、api-keys.json
- 告诉他一句:"推荐 skills 想装时说'装 skills',我带你走 /plugin"
- 完事,删 pending

**A2 挑着要:**
- 弹第二个 AskUserQuestion(multiSelect),模块清单:
  - □ 学术 API 调用能力(必选基础)
  - □ 三家 AI 协同(需要 API key)
  - □ 记忆系统(journal / unresolved 自动积累)
  - □ 数学研究工作流预设
  - □ 本地 Python 工具(火车票/天气/图书/医学)
  - □ 推荐 skills 清单展示
- 按勾的结果决定跳过哪些文件的软链(注意:install.sh 已经把所有文件软链好了,这里的"挑"是让 Claude 记住哪些用户不想用,写进 `~/ai/memory/shared/user-preferences.md`,以后不主动推这些)
- 然后照 A1 收身份信息

**A3 先想想:**
- 不动任何文件,回一句"行,想好了说'开始引导',我再带你走一遍",**不删** pending

### 步骤 3:模板占位符探测(A1 和 A2 共用)

所有模板用 `[中文...]` 方括号占位符:
- `~/.claude/rules/identity.md` — 检测 `## 用户：[姓名]` 字样,命中即未填
- `~/ai/config/modes/academic.md` — 检测 `[填写你的研究方向关键词` 字样
- `~/ai/data/keys/api-keys.json` — 内容是 `{}` 即未填

(zotero-guide.md 的 `[对象类]` 是示例,跳过)

### 步骤 4:根据回答写文件

- identity.md / academic.md:用 `Edit` 工具替换占位符
- api-keys.json:用户给了就填 `{"gpt_api_key": "sk-...", "gemini_api_key": "..."}`,不给保持 `{}`
- user-preferences.md(仅 A2):记录用户不想用的模块

**用户拒答或信息不全的处理:**
- 明说"跳过" / "以后":保留 pending,不强填
- 只给一部分:能填的填,剩下标 `[待补充]`,一句话告诉他以后怎么补
- 空回应:不动任何文件,保留 pending

### 步骤 5:清理

```bash
rm ~/ai/memory/unresolved/_bootstrap-pending.md  # 仅 A1/A2 完成后
```

写一行到 `~/ai/memory/journal/YYYY-MM-DD.md`:"完成首次引导,用户:<姓名>,方向:<方向>,模式:<A1/A2>"。

## 装 skills 的流程

**种子自带**(`mathematica-nb`、`math-survey`)已由 install.sh 软链到 `~/.claude/skills/`,无需处理。

**外部官方 skills**(`academic-writing`、`pdf`、`docx` 等)需要通过 Claude Code 的 `/plugin` 交互界面装 —— Claude 无法从 Bash 代装。

bootstrap 阶段只提一句"想装说一声",不阻塞流程。用户实际说"装 skills"时,Claude 读 `~/.claude-academic-config/skills-recommended.md`,列 3-5 个必备并提示用户 `/plugin`。

## 更新流程的触发词

由 `~/.claude/rules/routing.md` 承载,不在 bootstrap 里重复。
