# 发散级数 · 哑运算 · 拉马努金：综述项目（Codex/GPT 适配）

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
5. 认领章节 → 更新 `status.md`（执行者填 `Codex`）→ 按阶段流程开始

## Codex/GPT 专属工具映射

以下是 `methodology.md` 中通用意图在 Codex CLI 中的具体实现方式：

| 通用意图 | Codex CLI 实现 |
|---------|---------------|
| 学术 API 调用 | `shell` 工具执行 `curl` 命令（zbMATH/arXiv/Semantic Scholar/OEIS/LMFDB） |
| 计算验证 | `shell` 工具执行 `python3 -c "from sympy import *; ..."` |
| 文件编辑 | `apply_patch` 工具（结构化 diff 格式） |
| 交叉验证 | 在 `.research.md` 中标注 `[待交叉验证]` 并告知用户。**注意：Codex CLI 无法主动调用其他 AI，交叉验证需用户手动转交给 Claude 或 Gemini** |
| 文献 PDF 阅读 | `shell` 执行 `~/.local/bin/pdf2img` 转图片后查看 |
| 搜索 | `web_search` 工具（需通过 `--search` flag 或配置 `web_search = "live"` 启用）或 `shell` 执行 `curl` |

## 项目文件索引

| 文件 | 用途 | 读写规则 |
|------|------|---------|
| `methodology.md` | 方法论核心：LLM 缺陷防护、认识论分级、调研数据源、计算验证、写作规范 | 只读 |
| `outline.md` | 22 章 + 附录完整大纲 | 只读 |
| `parallel.md` | 多 AI 并行协调机制 | 只读 |
| `capability-assessment.md` | 三家 AI 能力评估与分工缓冲 | 只追加试跑结果 |
| `status.md` | **每次启动必读**——章节进度与 AI 分配 | 只改自己的行 |
| `notation-registry.md` | 全局符号注册表 | 只追加，标注 `[Codex]` |
| `dependency-dag.md` | 定理/结果之间的逻辑依赖图 | 只追加，标注 `[Codex]` |
| `cross-refs.md` | 跨章交叉引用记录 | 只追加，标注 `[Codex]` |
| `references.md` | 参考文献 | 只追加，标注 `[Codex]` |
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
- **执行者标注**：向共享文件追加内容时标注 `[Codex]`

## Codex/GPT 特有优势的发挥建议

- **严格推理**：GPT-5 系列在形式化数学推理上表现强，适合证明验证和逻辑链检查
- **代码生成**：适合编写 `verify/` 目录下的计算验证脚本
- **结构化输出**：适合生成格式规范的参考文献条目和符号注册表条目
