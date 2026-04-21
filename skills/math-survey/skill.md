---
name: math-survey
description: 启动长篇数学综述项目(≥10 章)的三 AI 协作脚手架。触发:用户说"写数学综述"/"开个综述项目"/"多 AI 协作写书"。提供方法论、认识论分级、符号注册表、章节分工、LLM 写数学的十大失败模式防护。
---

# 数学综述项目 Skill

项目模板位于 `~/.claude-academic-config/project-templates/math-survey/`。

## 触发场景

- 用户要启动 ≥10 章的数学综述(< 10 章走普通学术写作流程)
- 用户希望多家 AI 接力/互审而不是单家一气呵成
- 需要跨章节符号一致性、定理依赖追踪

## 启动流程(全自动)

1. 问用户三件事:项目主题、章节数估算、存放目录(默认 `~/ai/workspace/<slug>`)
2. `cp -R ~/.claude-academic-config/project-templates/math-survey/ <目标目录>`
3. 把 `outline.md.template` 打开,根据主题帮用户起草初稿大纲(再让用户审一遍)
4. 把 `status.md.template` 按大纲章节填好
5. 告诉用户下一步:"认领第一章就开始写"

## 核心原则(对 AI 自己的约束)

加载 skill 时必须同时读 `methodology.md` 的 §〇(LLM 写数学的十大失败模式):
- 假设条件漂移 / 幽灵引用 / 证明跳步 / 近似对象混淆 / 符号碰撞 / 编造引用 / 过度泛化 / 认识论扁平化 / 历史归属错误 / 采样偏差

**零信任原则:模型记忆中的数学"事实"均视为未验证,写入正式文件前必须有外部来源。**

## 认识论分级标记

每个非平凡声明必须标注:`[定理]` / `[命题/引理]` / `[猜想]` / `[形式论证]` / `[启发式]` / `[数值证据]` / `[folklore]` / `[物理论证]`。

## 共享文件写入规则

向 `notation-registry.md` / `dependency-dag.md` / `cross-refs.md` / `references.md` 追加内容时:
- 只追加,不修改已有条目
- 标注执行者:`[Claude]` / `[Gemini]` / `[Codex]`
- 新符号先 grep 查碰撞再注册

## 调研数据源

一级(每章必查):arXiv / Semantic Scholar / zbMATH Open / OEIS / INSPIRE-HEP / DLMF / LMFDB。详细 API 调用方式见 `~/.claude-academic-config/api-index.md`。
