# 发散级数 · 哑运算 · 拉马努金：综述项目（Gemini 适配）

## 元要求（最高优先级）

> **本项目由三家 AI（Claude、Gemini、Codex/GPT）共同参与维护。你不是唯一的执行者。其他 AI 可能在你工作期间修改了共享文件。每次读共享文件时预期内容可能已更新。**

## 项目定位

图书馆级别的深度综述，覆盖发散级数、哑运算、拉马努金三个紧密关联的数学领域及其交叉。中文撰写，术语保留英文。Markdown 格式，按章节组织。

核心主线：**形式操作（formal manipulation）何时、为何能给出正确结果？**

## 启动检查清单

每次启动时按顺序执行：
1. 读 `methodology.md`——首次启动通读全文；后续启动至少读第〇节（LLM 缺陷防护）+ 第八节（必引基线书目）+ 第九节（单章写作流程）
2. 读 `status.md`——了解全局进度和各 AI 的章节分配
3. 读 `notation-registry.md`——当前已注册的符号
4. 读 `parallel.md`——多 AI 协调规则
5. 认领章节 → 更新 `status.md`（执行者填 `Gemini`）→ 按阶段流程开始

## Gemini 专属工具映射

以下是 `methodology.md` 中通用意图在 Gemini CLI 中的具体实现方式：

| 通用意图 | Gemini CLI 实现 |
|---------|----------------|
| 学术 API 调用 | `run_shell_command` 执行 `curl` 命令（zbMATH/arXiv/Semantic Scholar/OEIS/LMFDB） |
| 计算验证 | `run_shell_command` 执行 `python3 -c "from sympy import *; ..."` |
| 文件编辑 | `edit`（精确替换）或 `write_file`（整文件写入） |
| 交叉验证 | 在 `.research.md` 中标注 `[待交叉验证]` 并告知用户。**注意：Gemini CLI 无法主动调用其他 AI，交叉验证需用户手动转交给 Claude 或 Codex** |
| 文献 PDF 阅读 | `read_file` 可直接读 PDF（多模态）；备选 `run_shell_command` 执行 `~/.local/bin/pdf2img` 转图片 |
| 搜索 | `google_web_search`（内置）或 `run_shell_command` 执行 `curl` |
| 网页抓取 | `web_fetch` 工具直接获取 URL 内容 |

## 项目文件索引

| 文件 | 用途 | 读写规则 |
|------|------|---------|
| `methodology.md` | 方法论核心：LLM 缺陷防护、认识论分级、调研数据源、计算验证、写作规范 | 只读 |
| `outline.md` | 22 章 + 附录完整大纲 | 只读 |
| `parallel.md` | 多 AI 并行协调机制 | 只读 |
| `capability-assessment.md` | 三家 AI 能力评估与分工缓冲 | 只追加试跑结果 |
| `status.md` | **每次启动必读**——章节进度与 AI 分配 | 只改自己的行 |
| `notation-registry.md` | 全局符号注册表 | 只追加，标注 `[Gemini]` |
| `dependency-dag.md` | 定理/结果之间的逻辑依赖图 | 只追加，标注 `[Gemini]` |
| `cross-refs.md` | 跨章交叉引用记录 | 只追加，标注 `[Gemini]` |
| `references.md` | 参考文献 | 只追加，标注 `[Gemini]` |
| `chapters/` | 各章正文 + `.research.md` 调研笔记 + `.review.md` 审校意见 | 只改自己认领的章节 |
| `verify/` | 计算验证脚本 | 按章节命名 |

## 关键约束（违反任何一条视为质量事故）

- **零信任**：模型记忆中的数学"事实"均视为未验证，写入正式文件前必须有外部来源
- **增量持久化**：做一点写一点，防意外中断丢失成果
- **调研先行**：写正文前必须先接入数据库做文献检索和事实核实
- **认识论分级**：每个非平凡声明标注级别（定理/猜想/形式论证/folklore/...）
- **计算验证**：关键恒等式和数值用 SymPy/mpmath 程序验证
- **符号管控**：新符号先查 `notation-registry.md`，无碰撞后注册
- **依赖追踪**：依赖其他结果的定理写完后立刻更新 `dependency-dag.md`
- **文件隔离**：只改自己负责的章节，共享文件只追加
- **执行者标注**：向共享文件追加内容时标注 `[Gemini]`

## Gemini 特有优势的发挥建议

- **长上下文**：适合文献综合型任务（将多篇论文要点整合为叙事段落）
- **内置搜索**：`google_web_search` 适合历史考证、人物年表、优先权争议的多源交叉验证
- **PDF 直读**：`read_file` 可直接读 PDF，无需额外转换工具，适合核实文献原文
- **多语言**：法语/德语原始文献（Borel、Cesàro、Euler 原始论文）的阅读和翻译
