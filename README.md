# Claude Code 学术配置种子包（数学方向）

一套经过实战打磨的 Claude Code 配置，包含：
- 自动加载规则（身份、行为、不确定性处理、会话生命周期等）
- 按需模式（学术、编程、对话、夜间）
- AI 辅助数学研究工作流（三模型分工：Claude + GPT + Gemini）
- 学术 API 速查（arXiv、Semantic Scholar、zbMATH、OpenAlex、Matlas 等）
- 深度调查方法论、文献翻译、Zotero SQLite 直改
- 可选：Archon（Lean 4 自动形式化原型）

---

## 一键安装

```bash
curl -fsSL https://raw.githubusercontent.com/dtq1997/claude-academic-config/main/install.sh | bash
```

安装完后：

1. 填写 `~/.claude/rules/identity.md`（你的身份和研究方向）
2. 填写 `~/ai/config/modes/academic.md`（研究方向关键词、当前论文等）
3. 重建 `~/ai/memory/shared/zotero-guide.md` 的标签体系（模板里的数学方向标签换成你自己的）
4. 填 `~/ai/data/keys/api-keys.json`（按需）
5. 打开 `claude`，说 "按推荐清单装 skills"

## 更新

在任意 `claude` 会话里说 **"更新配置"** 或 **"同步最新规则"**，AI 会：
1. 跑 `update.sh --check` 检查仓库差异
2. 列出变更清单（新增/修改/删除的文件，附 CHANGELOG 说明）
3. 问你要全部接受还是选择性接受
4. 拉取并应用你选中的改动
5. 自动更新版本标记，写日志到 `~/ai/memory/journal/config-updates.md`

## 工作原理

- **通用文件走软链接**（symlink，相当于快捷方式），本体在 `~/.claude-academic-config/`，`git pull` 一次所有地方同步。这些文件你**不要直接改**，改了会被下次 pull 覆盖。
- **模板文件走拷贝**（`*.template` 后缀），填充后存放在目标位置，属于你自己，永远不会被覆盖。包括：
  - `~/.claude/rules/identity.md`（身份）
  - `~/ai/config/modes/academic.md`（研究方向）
  - `~/ai/memory/shared/zotero-guide.md`（标签体系）
- **个人数据目录**（`~/ai/memory/journal/`、`unresolved/`、`dialectics/`）和你的 `api-keys.json` 从不入仓库。

## 我要改通用规则怎么办

**不要直接改软链接指向的文件**（会被 `git pull` 覆盖）。两个选择：

- **小改动**：在对应文件**同目录新建** `<原文件名>_local.md`（如 `behavior_local.md`），Claude 会同时加载两个文件，后者优先。本地文件不被覆盖。
- **觉得通用规则本身有问题**：直接在 `~/.claude-academic-config/` 里改，commit 推回仓库（如果你有写权限），或发 issue/PR 给仓库维护者。

## 目录结构（仓库内）

```
claude-academic-config/
├── install.sh              # 一键安装
├── update.sh               # 差异检查 + 应用更新
├── VERSION                 # 当前版本（日期）
├── CHANGELOG.md            # 变更记录
├── README.md               # 本文件
├── bootstrap.md            # 供 AI 读的流程说明
├── rules/                  # 自动加载层（link 到 ~/.claude/rules/）
│   ├── behavior.md         # 通用：语气、质量、API、记忆淘汰
│   ├── routing.md          # 模式路由 + 配置更新触发词
│   ├── startup.md          # 会话生命周期
│   ├── latex.md            # LaTeX 中英文决策
│   ├── code.md             # 编程兜底
│   ├── config.md           # 配置维护触发器
│   ├── env.md              # 环境约定
│   └── identity.md.template # [模板] 身份
├── modes/                  # 按需加载层（link 到 ~/ai/config/modes/）
│   ├── academic.md.template # [模板] 研究方向
│   ├── academic/
│   │   └── ai-math-workflow.md  # 三模型分工、Ryu/Tao/Nourdin/Litt 方法论
│   ├── programming.md
│   ├── dialogue.md
│   └── overnight.md
├── shared/                 # 共享知识库（link 到 ~/ai/memory/shared/）
│   ├── research-methodology.md       # 深度调查踩坑
│   ├── academic-translation-workflow.md # 文献翻译流程
│   ├── mathematica-nb-guide.md       # .wl ↔ .nb 转换
│   └── zotero-guide.md.template      # [模板] Zotero SQLite 直改
├── api-index-academic.md   # 学术 API 速查（link 到 ~/ai/data/keys/README.md）
├── config-maintenance.md   # 配置维护方法论
├── skills-recommended.md   # 推荐安装的 skills 清单
└── archon-optional/        # [可选] Lean 4 自动形式化原型
    └── README.md
```

## 核心理念（五句话）

1. **两层架构**：`.claude/rules/`（自动加载，全局，≤150 行硬约束）vs `~/ai/config/`（按需加载，不限行数）
2. **SSOT（Single Source of Truth）**：同一条规则只写一处，其他地方用指针引用
3. **记忆三层**：`journal/`（日志）、`unresolved/`（待办）、`shared/`（知识库），各有淘汰规则
4. **痛点驱动迭代**：不定期自审，用不爽才改
5. **三模型分工**：Claude 主线 + GPT 数学推导 + Gemini 视觉/长上下文，关键结论交叉验证

## 来源与致谢

- 原作者：唐乾（清华数学博后）
- 脱敏方向：去除了原作者的身份、论文、journal、人际关系、社交配置、生活工具链
- 学术方法论来源：Ernest Ryu、Terence Tao、Ivan Nourdin、Daniel Litt 等数学家的 AI 使用经验

## 反馈与贡献

发现问题或有改进建议：提 GitHub issue / PR，或直接联系维护者。这套配置本身也是迭代出来的，欢迎把你的经验反哺回仓库。
