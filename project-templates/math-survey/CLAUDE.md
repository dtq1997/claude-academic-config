# 发散级数 · 哑运算 · 拉马努金：综述项目（Claude 适配）

## 元要求（最高优先级）

> **本项目由三家 AI（Claude、Gemini、Codex/GPT）共同参与维护。你不是唯一的执行者。其他 AI 可能在你工作期间修改了共享文件。每次读共享文件时预期内容可能已更新。**

## 项目定位

图书馆级别的深度综述，覆盖发散级数、哑运算、拉马努金三个紧密关联的数学领域及其交叉。中文撰写，术语保留英文。Markdown 格式，按章节组织。

核心主线：**形式操作（formal manipulation）何时、为何能给出正确结果？**

## 启动检查清单

每次启动时按顺序执行：
1. 读 `methodology.md`——首次启动通读全文；后续启动至少读 §〇（LLM 缺陷防护）+ §八（必引基线书目）+ §九（单章写作流程）
2. 读 `status.md`——了解全局进度和各 AI 的章节分配
3. 读 `notation-registry.md`——当前已注册的符号
4. 读 `parallel.md`——多 AI 协调规则
5. 认领章节 → 更新 `status.md`（执行者填 `Claude`）→ 按阶段流程开始

## Claude 专属工具映射

以下是 `methodology.md` 中通用意图在 Claude Code 中的具体实现方式：

| 通用意图 | Claude Code 实现 |
|---------|-----------------|
| 学术 API 调用 | `Bash` 工具执行 `curl` 命令（zbMATH/arXiv/Semantic Scholar/OEIS/LMFDB） |
| 计算验证 | `Bash` 工具执行 `python3 -c "from sympy import *; ..."` |
| 文件编辑 | `Edit` 工具（精确替换）或 `Write` 工具 |
| 交叉验证 | MCP 工具 `ask_gpt` / `ask_gemini` / `ask_both`（调用其他两家 AI） |
| 文献 PDF 阅读 | `Read` 工具可直接读 PDF；备选 `~/.local/bin/pdf2img` 转图片 |
| 搜索 | `WebSearch` 工具或 `Bash` 执行 `curl` |

## Claude 特有优势的发挥建议

- **MCP 交叉验证**：Claude 是三家中唯一可以**主动**调用其他两家 AI 的（通过 `ask_gpt` / `ask_gemini` / `ask_both`），适合承担交叉验证密集型的章节
- **精确文件编辑**：`Edit` 工具支持精确字符串替换，适合符号注册表、依赖图等需要精确修改的共享文件
- **多模态**：`Read` 工具可直接读取 PDF 和图片，适合核实文献中的公式和图表

## 项目文件索引

| 文件 | 用途 | 读写规则 |
|------|------|---------|
| `methodology.md` | 方法论核心：LLM 缺陷防护、认识论分级、调研数据源、计算验证、写作规范 | 只读 |
| `outline.md` | 22 章 + 附录完整大纲 | 只读 |
| `parallel.md` | 多 AI 并行协调机制 | 只读 |
| `capability-assessment.md` | 三家 AI 能力评估与分工缓冲 | 只追加试跑结果 |
| `status.md` | **每次启动必读**——章节进度与 AI 分配 | 只改自己的行 |
| `notation-registry.md` | 全局符号注册表 | 只追加，标注 `[Claude]` |
| `dependency-dag.md` | 定理/结果之间的逻辑依赖图 | 只追加，标注 `[Claude]` |
| `cross-refs.md` | 跨章交叉引用记录 | 只追加，标注 `[Claude]` |
| `references.md` | 参考文献 | 只追加，标注 `[Claude]` |
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
- **执行者标注**：向共享文件追加内容时标注 `[Claude]`
