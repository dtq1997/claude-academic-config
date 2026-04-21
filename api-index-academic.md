# 学术 API 索引

按领域分类。大多数学术 API **免费、无需注册**，少数要邮箱标识或注册。

状态标记：✅ 推荐使用 | 🔜 值得试 | 📋 备选（小众或需订阅）

## 核心学术库（无需 key）

| 数据库 | API | 需要标识 | 说明 |
|--------|-----|---------|------|
| arXiv | `export.arxiv.org/api` | 否 | 论文搜索、摘要、PDF 链接，返回 Atom XML |
| Semantic Scholar | `api.semanticscholar.org` | 否（限流 1 次/秒） | 引用网络、论文摘要、作者信息、相关论文推荐 |
| CrossRef | `api.crossref.org` | 否 | DOI 元数据查询，引用格式生成 |
| Unpaywall | `api.unpaywall.org/v2/{DOI}` | 邮箱参数 | 判断 OA 状态，返回免费全文 PDF 链接 |
| OpenAlex | `api.openalex.org` | 2026.2 起免费 key | 2.5 亿+论文，作者画像/机构/主题/引用趋势 |

## 数学专属

| 数据库 | API | 需要 key | 说明 |
|--------|-----|---------|------|
| Matlas | `matlas.ai/api` | 否 | **定理级粒度**搜索：807 万条定理/引理/定义，self-contained statement。查"这个定理有没有人做过"最强。全局命令 `matlas "英文 query"`（需单独装 CLI） |
| zbMATH Open | `api.zbmath.org/v1` | 否 | 数学专属：专家评审、MSC 分类、关键词 |
| LMFDB | `lmfdb.org/api` | 否 | L-函数、模形式、椭圆曲线、数域、Galois 表示 |
| OEIS | `oeis.org` | 否 | 整数序列百科，37 万+序列，组合/数论必查 |
| DLMF (NIST) | `dlmf.nist.gov` | 否 | 特殊函数权威参考，无正式 API 用 WebFetch |
| nLab | `ncatlab.org` | 否 | 范畴论/同伦论/高等数学研究级 wiki，无 API 用 WebFetch |
| Numdam | `numdam.org` | 否 | 法国数学期刊数字化，历史文献 |
| EuDML | `eudml.org` | 否 | 欧洲数学数字图书馆 |

## 物理/天文/计算机

| 数据库 | API | 说明 |
|--------|-----|------|
| INSPIRE-HEP | `inspirehep.net/api` | 数学物理核心库，可积系统/gauge theory/Painlevé |
| NASA ADS | `api.adsabs.harvard.edu` | 天文物理文献，需免费 key |
| DBLP | `dblp.org/search/publ/api` | 计算机科学文献，无 key |

## 订阅/需机构授权（备选）

| 数据库 | 说明 |
|--------|------|
| MathSciNet | 清华等高校有校园访问，无公开 API |
| Web of Science / Scopus | 机构订阅，官方 API 需申请 |

## 调用示范（curl）

```bash
# arXiv 搜索
curl "http://export.arxiv.org/api/query?search_query=ti:Stokes+phenomenon&max_results=5"

# Semantic Scholar 按 DOI 查引用
curl "https://api.semanticscholar.org/graph/v1/paper/DOI:10.1007/s00220-020-03866-2?fields=title,authors,citations"

# CrossRef 按 DOI 查元数据
curl "https://api.crossref.org/works/10.1007/s00220-020-03866-2"

# Unpaywall 查 OA 状态
curl "https://api.unpaywall.org/v2/10.1007/s00220-020-03866-2?email=your@email.com"

# zbMATH 搜索（注意 search_string 语法，含连字符的词不要加 ti:）
curl "https://api.zbmath.org/v1/document/_search?search_string=painleve+xu"

# OpenAlex 按作者 ID 查
curl "https://api.openalex.org/authors/A5019142880"

# Matlas（需先装 CLI）
matlas "quantum cohomology Frobenius manifold"
```

## 本地 key 存储约定

需要 key 的 API，写入 `~/ai/data/keys/api-keys.json`：

```json
{
  "openalex": {"email": "your@email.com"},
  "unpaywall": {"email": "your@email.com"},
  "nasa_ads": {"api_key": "..."},
  "anthropic": {"api_key": "sk-ant-...", "model": "claude-sonnet-4-6"},
  "google_gemini": {"api_key": "AIza...", "model": "gemini-3.1-pro-preview"},
  "openai": {"api_key": "sk-...", "model": "gpt-5.4"}
}
```

调用时让 AI 直接 `cat ~/ai/data/keys/api-keys.json | jq -r .openalex.email` 读取。

## 新数据源接入原则

- **先 Bash 直接调用**，验证有用再考虑包装
- **禁止默认建 MCP**：MCP 适合日均 10+ 次高频工具。学术查询多数是偶发，Bash + curl 已经够
- **接入后立即在此文件登记一行**，否则下次会忘
