# 数学综述项目模板（三 AI 协作）

这是一套经过实战打磨的**长篇数学综述**项目脚手架。三家 AI（Claude / Gemini / Codex / GPT）协作撰写，配套了：

- 方法论（LLM 写数学的 10 大失败模式与防护）
- 认识论分级（定理/猜想/形式论证/folklore/物理论证）
- 三 AI 并行协调机制（章节认领、共享文件追加规则、执行者标注）
- 符号注册表、依赖图、交叉引用登记
- 零信任原则 + 计算验证流水线

## 适用场景

- ≥10 章的数学综述（<10 章走传统单人工作流即可）
- 需要跨章节符号一致性的主题（代数几何、表示论、可积系统等）
- 希望多家 AI 接力/互审，而不是单家一气呵成

## 快速启动

```bash
# 1. 复制模板到你的项目位置
cp -R ~/.claude-academic-config/project-templates/math-survey ~/ai/workspace/my-survey
cd ~/ai/workspace/my-survey

# 2. 替换模板占位符
mv outline.md.template outline.md       # 填你的大纲
mv status.md.template status.md         # 按大纲列章节

# 3. 编辑三家 AI 的入口（如果只用 Claude，只留 CLAUDE.md 即可）
#    - AGENTS.md    — Codex/GPT 适配
#    - CLAUDE.md    — Claude Code 适配
#    - GEMINI.md    — Gemini CLI 适配

# 4. 在 claude 会话里说：
#    "读 methodology.md 和 status.md，然后开始第 1 章"
```

## 文件索引

| 文件 | 作用 |
|------|------|
| `methodology.md` | 方法论核心：LLM 失败模式防护、认识论分级、调研数据源、计算验证、必引基线书目、单章写作流程 |
| `outline.md.template` | 章节大纲模板（必须定制） |
| `status.md.template` | 进度表模板（必须定制） |
| `parallel.md` | 多 AI 并行协调机制（文件隔离、追加规则、锁协议） |
| `capability-assessment.md` | 三家 AI 能力评估与分工建议 |
| `notation-registry.md` | 全局符号注册表（只追加） |
| `dependency-dag.md` | 定理依赖图（只追加） |
| `cross-refs.md` | 跨章交叉引用登记（只追加） |
| `references.md` | 参考文献（只追加） |
| `AGENTS.md` / `CLAUDE.md` / `GEMINI.md` | 各家 AI 的专属启动说明（工具映射） |

## 核心哲学

1. **零信任**：模型记忆中的数学"事实"均视为未验证，写入正式文件前必须有外部来源
2. **增量持久化**：做一点写一点，防意外中断丢失成果
3. **调研先行**：写正文前必须接入 arXiv/zbMATH/OEIS 等做文献检索和事实核实
4. **认识论分级**：每个非平凡声明标注级别（定理/猜想/形式论证/folklore/...）
5. **计算验证**：关键恒等式用 SymPy/mpmath 程序验证
6. **文件隔离**：各 AI 只改自己负责的章节，共享文件只追加
7. **执行者标注**：向共享文件追加内容时标注 `[Claude]`、`[Gemini]`、`[Codex]`

## 来源

这套模板来自唐乾的 "发散级数·哑运算·拉马努金" 综述项目（22 章，三 AI 协作）。
