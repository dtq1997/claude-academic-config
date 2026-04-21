# 学术文献翻译工作流

> 创建: 2026-03-04 | 来源: 多源调研 [Claude + GPT] | 状态: v1.1 待实战验证

## 核心原则

1. **别翻译 PDF**——先提取可编辑文本，再翻译
2. **术语表是复利**——一次建表，长期复用，同子领域 5-10 篇后成本骤降
3. **分层处理**——快速浏览 / 精读理解 / 发表级，投入不同
4. **公式能不 OCR 就不 OCR**——截图 + 视觉 LLM 覆盖 90% 精读场景

## 场景分层

| 场景 | 路径 |
|------|------|
| 快速筛选文献 | 沉浸式翻译浏览器插件（多引擎可切换） |
| 精读理解（自用） | LLM 分段翻译 + 术语表 |
| 发表级翻译 | CAT 工具 (OmegaT) + LLM + 人工审校 |

## 工具链

### 文本提取（Step 0）
- LaTeX 源码（arXiv 等）→ 直接翻译 `.tex`，数学环境不动
- Born-digital PDF → GROBID（免费，结构化提取）
- 公式密集型 → Mathpix（公式 OCR 最强，输出 LaTeX/MD）
- 扫描件 → ABBYY FineReader

### 公式不可复制的 PDF：两条路径（Step 0.5）

**路径 A：只需读懂（不需可编辑输出）—— 推荐首选**

截图 + 多模态 LLM（Claude / GPT-4o）直接翻译。零准备、零工具链。

```
[附 PDF 页面截图]
翻译这一页的正文为中文。数学公式保持原样不翻译，
用 $...$ 标记行内公式，用 $$...$$ 标记行间公式。
专业术语首次出现时括注英文原文。
```

大多数精读场景用这条路径就够了。

**路径 B：需要可编辑 LaTeX/Markdown 输出**

先 OCR 提取公式，再翻译文本部分。

| 工具 | 公式精度 | 速度 | 成本 | 适用 |
|------|---------|------|------|------|
| Mathpix | **最高**（手写+印刷） | 快（云） | ~$5/月 | 金标准，公式密集首选 |
| Marker + `--use_llm` | 高 | **极快** | 免费（本地） | 开源批量处理 |
| Pix2Text | 中高 | 中 | 免费（本地） | 免费 Mathpix 替代 |
| Mistral OCR | 高 | 快（API） | 按调用 | 复杂排版强 |
| Nougat (Meta) | 中 | 慢 | 免费 | 整页文档，但有幻觉问题 |

2025 benchmark (arXiv:2512.09874)：Qwen3-VL、Gemini 3 Pro、Mathpix、PaddleOCR-VL >9.6/10，Nougat 已被超越。

路径 B 流程：`PDF → Mathpix/Marker → LaTeX/MD → LLM 翻译正文（跳过公式环境） → 编译验证`

### 术语管理（Step 1）
- 格式：`glossary.csv` — `source_term, approved_translation, field, note`
- 用 LLM 从原文自动提取候选术语，人工确认
- 按学科维护：`physics.csv`, `cs.csv`, `humanities.csv` 等

### 翻译引擎选择（Step 2）

| 语言对 | 主力引擎 | 精修层 |
|--------|----------|--------|
| EN↔DE/FR/ES/IT | DeepL（+ 术语表绑定） | Claude/GPT 困难段落 |
| EN↔中文 | Claude / GPT | DeepL 对比验证 |
| EN↔日韩 | Qwen-MT [待验证] | GPT/Claude 精修 |
| EN↔阿拉伯语 | Gemini | GPT 精修 |
| 小语种兜底 | Meta NLLB (200+ 语言) | — |

学科维度：
- 理工科（公式多）：DeepL 主力 + LLM 精修，保护数学环境
- 人文社科（修辞重）：Claude/GPT 做主力（措辞 > 术语）
- 法律/医学：DeepL（术语严谨度最高）

### LLM 翻译 Prompt 模板（Step 3）

```xml
<system>
你是[学科]领域的专业学术翻译。严格使用提供的术语表。
保持学术语域。不要翻译以下内容：
$...$, \(...\), \[...\], \begin{...}...\end{...},
\cite{}, \ref{}, URL, DOI, 方程编号。
</system>

<glossary>
[术语表内容]
</glossary>

<task>
将以下文本从[源语言]翻译为[目标语言]。保持原文段落结构。
</task>

<source>
[原文章节]
</source>
```

### CAT 工具（发表级路径）
- 免费：OmegaT（翻译记忆 + 术语表匹配 + LaTeX filter）
- 付费：memoQ / SDL Trados
- 在 CAT 中接入 DeepL API 做初译，再精修

### 质量审校（Step 4）

机械 QA：
- LanguageTool（多语言语法）
- CAT 一致性检查（重复片段、术语违规、数字不匹配）

语义 QA（用第二个 LLM 做 reviewer）：
```
给你原文和译文。逐段对比，标记：
1. 意义偏移（否定词、程度词 may/suggests/proves）
2. 术语与术语表不一致
3. 数字/单位错误
4. 遗漏或多译
```
可用便宜模型（Gemini Flash / Haiku）。

## 成本效率法则

1. DeepL 处理 70-90% 文本量，LLM 只用于困难段落（省 3-5x API 费）
2. 按章节批量调用，不逐句调 LLM
3. 数学公式不 OCR 除非必须编辑——翻译时绕过，保留原始 LaTeX/图片
4. 术语表 + 翻译记忆是复利资产

## 待验证项

- [ ] Qwen-MT 日韩学术翻译实际体验
- [ ] OmegaT LaTeX filter 复杂文档成熟度（备选：po4a 转 PO 格式）
- [ ] 具体语言对的最优 prompt 微调
- [ ] Marker + `--use_llm` 本地部署实测公式精度
- [ ] Pix2Text vs Mathpix 在数学物理论文上的实际差距

## 参考来源

- WMT24: Claude 3.5 在 9/11 语言对排名第一
- DeepL 盲测编辑量比 GPT-4 少 2-3 倍
- arXiv 2502.17882: Science Across Languages (2025)
- arXiv 2512.09874: Benchmarking Document Parsers on Math Formula Extraction (2025)
- 沉浸式翻译 + DeepL Next-gen LLM 集成

## 迭代记录

- 2026-03-04: v1 创建，基于多源调研，尚未实战验证
- 2026-03-04: v1.1 新增「公式不可复制 PDF」两条路径（截图+视觉LLM / OCR工具链），补充 2025 benchmark 数据
