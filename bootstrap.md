# 首次安装引导流程(给 Claude 读的)

> 本文件由 Claude 在检测到 `~/ai/memory/unresolved/_bootstrap-pending.md` 存在时加载。用户不会主动读这个文件。

## 总原则

- **自己判断优先**:能推断的别问
- **问就只问一次**:把必要信息合并成一两个问题,用 AskUserQuestion
- **介绍只给大概**:"要不要填一下 API keys(可选)"而非列 40 个 API 让对方挑
- **全程无阻塞**:用户拒绝任何一步都不影响正常使用,跳过即可

## 流程(Claude 自执行)

### 步骤 1:探测当前状态

```bash
[[ -f ~/ai/memory/unresolved/_bootstrap-pending.md ]] || exit 0  # 不是首次
```

检测这几个文件是否仍是模板原样(用关键词 grep):
- `~/.claude/rules/identity.md` — 是否还有 `[填写你的姓名]` / `[填写研究方向]`
- `~/ai/config/modes/academic.md` — 是否还有 `[填写你的研究方向关键词]`
- `~/ai/memory/shared/zotero-guide.md` — 是否还有 `[你的领域示例]`
- `~/ai/data/keys/api-keys.json` — 是否是 `{}`

### 步骤 2:一次性收信息

用一个 `AskUserQuestion`,**只给大概描述**,例如:

- 身份 + 研究方向(必须)
- 要不要现在填 API keys(可选,随时可后填)
- 要不要现在装推荐 skills(默认推荐装)

不要让对方填 Zotero 标签 —— 那是首次用 Zotero 时才需要的,改到那个时候再问。

### 步骤 3:根据回答自动写文件

- identity.md / academic.md:Claude 用 `Edit` 工具把模板占位符替换成用户答案
- api-keys.json:用户如果现在给就填,不给就保持 `{}`,并告诉他以后说"填 GPT key"之类再处理
- skills:读 `~/.claude-academic-config/skills-recommended.md`,按清单自动装(见下方"装 skills"段)

### 步骤 4:清理

```bash
rm ~/ai/memory/unresolved/_bootstrap-pending.md
```

写一行到 `~/ai/memory/journal/YYYY-MM-DD.md`:"完成首次引导,用户:<姓名>,方向:<方向>"。

## 装 skills 的自动流程

Claude 直接按 `~/.claude-academic-config/skills-recommended.md` 的清单装。每个 skill 的目录结构很简单:`~/.claude/skills/<name>/skill.md`。种子包自带的两个 skill(`mathematica-nb`、`math-survey`)通过 install.sh 软链,不用再装。

外部 skills(`academic-writing`、`pdf`、`docx` 等)的安装方式:
- 如果是 Anthropic 官方 skill collection:`claude skill install <name>`(若 CLI 支持)
- 否则直接建个目录写 skill.md,按 `skills-recommended.md` 的描述填内容

Claude 应该先问"要装吗",用户说"装"再批量处理。装完列一行"已装:X, Y, Z"即可。

## 更新流程的触发词(给 routing.md 参考)

这部分由 `~/.claude/rules/routing.md` 承载,不在 bootstrap 里重复写。
