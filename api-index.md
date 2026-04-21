# 开放数据库接入索引

按领域分类，标注接入难度和优先级。
状态：✅ 已接入 | 🔜 推荐优先接入 | 📋 备选

---

## 1. 地理与地图

| 数据库 | API | 需要Key | 状态 | 说明 |
|--------|-----|---------|------|------|
| 高德地图 | restapi.amap.com/v3 | 是（免费5000次/天） | ✅ 已建MCP | POI搜索、地理编码、周边查询（无评分） |
| 百度地图 | api.map.baidu.com | 是（免费） | ✅ 已填Key | POI检索含评分/人均/评论数，弥补高德无评价数据的短板 |
| OpenStreetMap/Nominatim | nominatim.openstreetmap.org | 否 | 🔜 | 全球地理编码，无需注册，限1次/秒 |
| GeoNames | api.geonames.org | 是（免费） | 📋 | 全球地名数据库，1100万条 |

## 1.5 生活与消费（围墙花园 CDP 直连）

所有工具通过 `~/ai/data/chrome_cdp.py` 连接 headless Chrome，共用 debug profile。

| 平台 | 需登录 | 状态 | 工具脚本 | 说明 |
|------|--------|------|---------|------|
| 大众点评 | 是 | ✅ 已验证 | `dianping/dianping_search.py` | 商户评分/评价数/人均/商圈 |
| 小红书 | 是 | ❌ 已封号移除 | ~~`xhs/xhs_search.py`~~ | 2026-03-30 账号被封，工具已删 |
| B站 | 部分 | ✅ 已验证 | `bilibili/bilibili_search.py` | 视频搜索/播放量/UP主 |
| 豆瓣影视 | 否 | ✅ 已验证 | `douban/douban_search.py` | 电影评分/短评/评价人数 |
| 12306 | 否 | ✅ 已验证 | `12306/train_search.py` | 余票查询（纯 API） |
| 知乎 | 是 | ⏳ 待登录 | `zhihu/zhihu_search.py` | 问答/专栏/文章 |
| 美团外卖 | 是 | ⏳ 待登录 | `meituan/meituan_search.py` | 外卖搜索/满减/配送 |
| 淘宝 | 是 | ⏳ 待登录 | `taobao/taobao_search.py` | 商品/价格/销量 |
| 京东 | 是 | ⏳ 待登录 | `jd/jd_search.py` | 商品/比价/评论 |
| 携程 | 是 | ⏳ 待登录 | `ctrip/ctrip_search.py` | 酒店/航班 |
| 链家 | 是 | ⏳ 待登录 | `lianjia/lianjia_search.py` | 租房/二手房 |
| 闲鱼 | 是 | ⏳ 待登录 | `xianyu/xianyu_search.py` | 二手商品 |
| 微信公众号 | 否 | ⏳ 搜狗入口 | `weixin/weixin_search.py` | 公众号文章搜索 |

## 2. 学术与科研

| 数据库 | API | 需要Key | 状态 | 说明 |
|--------|-----|---------|------|------|
| Matlas | matlas.ai/api | 否 | ✅ 已验证 | **定理级粒度**搜索：807 万条定理/引理/定义的 self-contained statement，来自 435K 篇 ICM 高引期刊论文 + 1.9K 教材。查"这个定理有没有人做过"优先用它。全局命令 `matlas "英文 query"` |
| arXiv | export.arxiv.org/api | 否 | ✅ 已验证 | 论文搜索、摘要、PDF链接，返回Atom XML |
| Semantic Scholar | api.semanticscholar.org | 否（有限流1次/秒） | ✅ 已验证 | 引用网络、论文摘要、作者信息、相关论文推荐 |
| CrossRef | api.crossref.org | 否 | ✅ 已验证 | DOI元数据查询，引用格式生成 |
| zbMATH Open | api.zbmath.org/v1 | 否 | ✅ 已验证 | 数学专属：专家评审、MSC分类、关键词，N 篇相关作者 |
| OpenAlex | api.openalex.org | 是（免费，2026.2起） | ✅ 已验证 | 2.5亿+论文，作者画像/机构/主题/引用趋势，你的导师=A... |
| Unpaywall | api.unpaywall.org/v2 | 否（需邮箱标识） | ✅ 已验证 | 按DOI查免费全文PDF链接，判断OA状态 |
| LMFDB | lmfdb.org/api | 否 | ✅ 已验证 | L-函数、模形式、椭圆曲线、数域、Galois表示 |
| OEIS | oeis.org | 否 | ✅ 已验证 | 整数序列百科，37万+序列，组合/数论必查 |
| INSPIRE-HEP | inspirehep.net/api | 否 | ✅ 已验证 | 数学物理文献核心库，可积系统/gauge theory/Painlevé |
| DLMF (NIST) | dlmf.nist.gov | 否 | ✅ 已验证 | 特殊函数权威参考，Painlevé专章(Ch.32)，无正式API用WebFetch |
| nLab | ncatlab.org | 否 | ✅ 已验证 | 范畴论/同伦论/高等数学研究级wiki，无API用WebFetch |
| MathSciNet | mathscinet.ams.org | 是（机构订阅） | 📋 | 与zbMATH并列的数学评审库，清华有校园访问，无公开API |
| Numdam | numdam.org | 否 | 📋 | 法国数学期刊数字化，历史文献，无正式API |
| EuDML | eudml.org | 否 | 📋 | 欧洲数学数字图书馆，历史文献，无正式API |
| Project Euclid | projecteuclid.org | 否 | 📋 | 数学/统计期刊平台 |
| PubMed/NCBI | eutils.ncbi.nlm.nih.gov | 否（建议注册） | ✅ 已接入 | 生物医学文献，工具见 §6.5 |
| NASA ADS | api.adsabs.harvard.edu | 是（免费） | ✅ 已接入 | 天文物理文献核心数据库，引用网络、bibcode查询 |
| DBLP | dblp.org/search/publ/api | 否 | 📋 | 计算机科学文献 |

## 3. 金融与经济

| 数据库 | API | 需要Key | 状态 | 说明 |
|--------|-----|---------|------|------|
| Yahoo Finance | yfinance (Python库) | 否 | 🔜 | 股票行情、历史数据、财报 |
| Alpha Vantage | alphavantage.co | 是（免费25次/天） | 📋 | 股票、外汇、加密货币 |
| FRED | api.stlouisfed.org | 是（免费） | 📋 | 美联储经济数据，宏观指标 |
| World Bank | api.worldbank.org/v2 | 否 | 📋 | 全球发展指标 |
| 国家统计局 | data.stats.gov.cn | 否 | 📋 | 中国官方统计数据，接口不稳定 |

## 4. 天气与环境

| 数据库 | API | 需要Key | 状态 | 说明 |
|--------|-----|---------|------|------|
| Open-Meteo | api.open-meteo.com | 否（完全免费） | ✅ 已接入 | 全球天气：实况/16天预报/逐时/历史/空气质量。工具：`weathertools.py` |
| OpenWeatherMap | api.openweathermap.org | 是（免费1000次/天） | 📋 备选 | Open-Meteo 已覆盖，降级为备选 |
| Visual Crossing | weather.visualcrossing.com | 是（免费1000次/天） | 📋 | 历史天气数据 |
| NOAA | ncdc.noaa.gov/cdo-web/api | 是（免费） | 📋 | 美国气象历史数据 |
| AQI (aqicn.org) | aqicn.org/api | 是（免费） | 📋 | 全球空气质量指数 |

## 5. 视频与内容平台

| 数据库 | API | 需要Key | 状态 | 说明 |
|--------|-----|---------|------|------|
| YouTube Data API v3 | googleapis.com/youtube/v3 | 是（免费10000单位/天） | 🔜 | 视频搜索、频道信息、字幕 |
| Bilibili | 非官方API | 否 | 📋 | 视频信息、弹幕、评论，接口不稳定 |
| Spotify Web API | api.spotify.com/v1 | 是（OAuth） | 📋 | 音乐搜索、播放列表、音频特征 |
| TMDB | api.themoviedb.org/3 | 是（免费） | 📋 | 电影电视剧数据库 |
| IGDB | api.igdb.com/v4 | 是（Twitch OAuth） | 📋 | 游戏数据库 |
| Steam Web API | api.steampowered.com | 是（免费） | 📋 | Steam游戏数据、玩家信息 |

## 6. 食品与健康

| 数据库 | API | 需要Key | 状态 | 说明 |
|--------|-----|---------|------|------|
| USDA FoodData Central | fdc.nal.usda.gov/fdc-app.html | 是（免费） | 🔜 | 美国农业部食品营养数据，最权威 |
| Open Food Facts | world.openfoodfacts.org/api | 否 | 🔜 | 全球食品条形码数据库，众包 |
| OpenFDA | api.fda.gov | 否 | ✅ 已接入 | 药品不良反应、说明书、召回信息。工具：`medtools.py openfda-*` |
| DrugBank | 本地 SQLite（CC0 数据集） | 已注册学术版 | ✅ 已接入 | 19830种药物本地查询，`medtools.py drugbank` |

## 6.5 医学与生物医学

| 数据库 | API | 需要Key | 状态 | 说明 |
|--------|-----|---------|------|------|
| PubMed/NCBI E-utilities | eutils.ncbi.nlm.nih.gov | 否（建议注册提速） | ✅ 已接入 | 3600万+生物医学文献，搜索+摘要+全文链接。工具：`medtools.py pubmed*` |
| ClinicalTrials.gov v2 | clinicaltrials.gov/api/v2 | 否 | ✅ 已接入 | 50万+临床试验，含状态/干预/入组/终点。工具：`medtools.py trials*` |
| MeSH (NLM) | id.nlm.nih.gov/mesh | 否 | ✅ 已接入 | 医学主题词表，术语映射与层级分类。工具：`medtools.py mesh` |
| Semantic Scholar | api.semanticscholar.org | 否 | ✅ 已验证 | 引用网络（也覆盖生物医学），学术三件套已有 |
| UMLS (NLM) | uts.nlm.nih.gov | 是（免费注册） | 📋 | 统一医学语言系统，概念映射，需注册 |

## 7. 知识与百科

| 数据库 | API | 需要Key | 状态 | 说明 |
|--------|-----|---------|------|------|
| Wikipedia/MediaWiki | en.wikipedia.org/w/api.php | 否 | ✅ 已验证 | 百科全书，支持中英文，搜索+摘要+分类+链接 |
| Wiktionary | en.wiktionary.org/w/api.php | 否 | ✅ 已验证 | 词典，词源、发音、释义 |
| OpenLibrary | openlibrary.org/api | 否 | ✅ 已验证 | 图书元数据、主题、版本、ISBN，2000万+著作 |
| Project Gutenberg | gutendex.com | 否 | ✅ 已验证 | 公版电子书全文，7万+书，含txt/html格式直链 |
| Stanford Encyclopedia | plato.stanford.edu | 否 | ✅ 已验证 | 哲学百科，学术级条目，WebFetch直接抓 |
| Marxists Internet Archive | marxists.org | 否 | ✅ 已验证 | 马恩列毛经典全文，多语言，WebFetch直接抓 |
| 豆瓣读书 | book.douban.com/j/subject_suggest | 否 | ✅ 已接入 | 中文图书元数据（评分/ISBN/简介），本地工具 `booktools.py` |
| Anna's Archive | annas-archive.gl（域名常变） | 否 | ✅ 已接入 | 电子书元搜索（聚合 LibGen/Z-Library），本地工具 `booktools.py` |

## 8. 法律与政策

| 数据库 | API | 需要Key | 状态 | 说明 |
|--------|-----|---------|------|------|
| 国家法律法规数据库 | flk.npc.gov.cn | 否（无正式API） | 📋 | 中国法律法规，需爬取 |
| 中国裁判文书网 | wenshu.court.gov.cn | 否（反爬严格） | 📋 | 裁判文书，接入难度高 |
| EUR-Lex | eur-lex.europa.eu/api | 否 | 📋 | 欧盟法律 |

## 8.5 植物识别

| 数据库 | API | 需要Key | 状态 | 说明 |
|--------|-----|---------|------|------|
| PlantNet | my-api.plantnet.org/v2 | 是（免费500次/天） | ⏳ 待填Key | 拍照识花，1-5张图返回物种+置信度，覆盖全球植物 |
| iNaturalist | api.inaturalist.org/v1 | 否 | 📋 | 物种观察记录，众包，含视觉识别但需OAuth |

## 9. 生物与生态

| 数据库 | API | 需要Key | 状态 | 说明 |
|--------|-----|---------|------|------|
| GBIF | api.gbif.org/v1 | 否 | 📋 | 全球生物多样性，物种分布 |
| iNaturalist | api.inaturalist.org/v1 | 否 | 📋 | 物种观察记录，众包 |
| UniProt | rest.uniprot.org | 否 | 📋 | 蛋白质序列与功能 |

## 10. 汉字与中文语言

| 数据库 | API | 需要Key | 状态 | 说明 |
|--------|-----|---------|------|------|
| 萌典 (MoeDict) | www.moedict.tw/uni/ | 否 | ✅ 已验证 | 台湾教育部辞典，16万条，部首/笔画/注音/拼音/释义，CC0 |
| Chinese Text Project | api.ctext.org | 否（基础功能） | ✅ 已验证 | 先秦至清代古籍全文+汉字属性（部首/读音/异体字），哈佛维护 |
| Unicode API (Unihan) | unicode-api.aaronluna.dev/v1 | 否 | ✅ 已验证 | Unicode 17.0 Unihan 数据库，6语言读音/异体字/笔画，个人项目 |
| Hanzi Writer Data | cdn.jsdelivr.net/npm/hanzi-writer-data | 否 | ✅ 已验证 | 9000+字笔画SVG路径，CDN分发，配套动画渲染库 |

## 11. AI 模型与推理服务

| 数据库 | API | 需要Key | 状态 | 说明 |
|--------|-----|---------|------|------|
| HuggingFace Hub | huggingface.co | 是（Read token 免费） | ✅ 已接入 | 下载模型/数据集，部分 gated 模型需先网页同意条款。用法：环境变量 `HF_TOKEN=$(jq -r .huggingface.token ~/ai/data/keys/api-keys.json)` |

---

## 接入优先级建议

第一批（实用性高、接入简单、免费无Key或Key易得）：
1. ✅ 高德地图 — MCP Server 已建，含路线规划
2. ✅ arXiv + Semantic Scholar + CrossRef — 学术三件套，已验证可直接调用
3. ✅ zbMATH Open + OpenAlex + Unpaywall — 学术扩展三件套，已验证（2026-03-01）
4. ✅ LMFDB + OEIS + INSPIRE-HEP — 数学研究三件套，已验证（2026-03-02）
5. ✅ DLMF + nLab — 数学参考/wiki，WebFetch直接用（2026-03-02）
6. ✅ Wikipedia + Wiktionary — 通用知识+词典，已验证（2026-03-03）
7. ✅ OpenLibrary + Gutendex — 图书元数据+公版全文，已验证（2026-03-03）
8. ✅ Stanford Encyclopedia + Marxists Archive — 哲学+马克思主义原典，已验证（2026-03-03）
9. ✅ PubMed + ClinicalTrials.gov + OpenFDA + MeSH — 医学四件套，本地工具（2026-03-04）
10. ✅ 豆瓣读书 + Anna's Archive — 图书搜索+电子书查找，本地工具（2026-03-04）
11. ✅ Open-Meteo — 天气全套（实况/预报/历史/空气质量），本地工具（2026-03-07）
12. 🔜 USDA / Open Food Facts — 营养查询
12. ✅ 企业微信 Webhook — 每日学术简报推送通道（2026-03-04）
13. ✅ 萌典 + ctext.org + Unicode API + Hanzi Writer — 汉字四件套，已验证（2026-03-08）
14. ✅ 大众点评 — Playwright + Chrome cookies/stealth，本地工具（2026-03-08）。小红书已封号移除（2026-03-30）

第二批（需OAuth或接口复杂）：
- YouTube、Spotify、Steam、Yahoo Finance

第三批（无公开API，需机构权限或爬取）：
- MathSciNet（清华校园网访问）、Numdam、EuDML、Project Euclid

## MCP Server 位置

仅高频工具建 MCP，其余直接 Bash 调用（见下方速查）。
- 高德地图：`~/ai/mcp-servers/amap/server.py`（7个工具：POI/周边/地理编码/驾车/步行/公交）
- API Key 统一存储：`~/ai/data/keys/api-keys.json`

---

## API 调用速查（直接 Bash 调用）

### Matlas（数学定理级检索）

全局命令已安装，优先于 arXiv/Semantic Scholar 做定理/陈述级检索。

```bash
matlas "英文 query"           # 默认 10 条
matlas "query" -n 30          # 最多 200，最少 10
matlas "query" --save NAME    # 存到 ~/ai/workspace/matlas/results/NAME.json

# 直接 POST（需要脚本集成时）
curl -s -X POST https://matlas.ai/api/search \
  -H "Content-Type: application/json" \
  -d '{"query":"Stokes matrix Dubrovin","num_results":10}'
```

返回字段：`type` (paper|book) / `title` / `authors` / `journal` / `year` / `doi` / `statement`（展开后的完整陈述）/ `entity_name`（如 "Theorem 1.1"）/ `candidate_id`。详见 `~/ai/workspace/matlas/CLAUDE.md`。

### arXiv

返回 Atom XML，需解析。限流：3秒间隔。

```
# 按关键词搜索
https://export.arxiv.org/api/query?search_query=all:{关键词}&max_results=10

# 按作者搜索
https://export.arxiv.org/api/query?search_query=au:{作者名}&max_results=10

# 按arXiv ID获取
https://export.arxiv.org/api/query?id_list=2501.01419

# 组合查询（AND/OR/ANDNOT）
https://export.arxiv.org/api/query?search_query=au:Gavrylenko+AND+ti:Painleve&max_results=5

# 字段：ti(标题) au(作者) abs(摘要) cat(分类) all(全部)
```

### Semantic Scholar

返回 JSON。限流：1次/秒（无Key），申请Key可提高。

```
# 搜索论文
https://api.semanticscholar.org/graph/v1/paper/search?query={关键词}&limit=10&fields=title,year,citationCount,authors,abstract,externalIds

# 按DOI/arXiv ID查单篇
https://api.semanticscholar.org/graph/v1/paper/DOI:{doi}?fields=title,authors,citationCount,references,citations
https://api.semanticscholar.org/graph/v1/paper/ARXIV:{arxiv_id}?fields=title,authors,citationCount

# 查引用（谁引了这篇）
https://api.semanticscholar.org/graph/v1/paper/{paper_id}/citations?fields=title,year,authors&limit=20

# 查参考文献（这篇引了谁）
https://api.semanticscholar.org/graph/v1/paper/{paper_id}/references?fields=title,year,authors&limit=20

# 查作者
https://api.semanticscholar.org/graph/v1/author/search?query={作者名}&fields=name,hIndex,paperCount
```

### CrossRef

返回 JSON。无限流，建议带 `mailto` 参数进入 polite pool。

```
# 按DOI查元数据
https://api.crossref.org/works/{doi}

# 搜索论文
https://api.crossref.org/works?query={关键词}&rows=10&select=DOI,title,author,published-print

# 带邮箱进入优先队列（更快）
https://api.crossref.org/works?query={关键词}&rows=10&mailto=你的邮箱
```

### zbMATH Open

数学专属数据库。返回 JSON。无需Key，无硬性限流。含专家评审、MSC分类。

```
# 按关键词搜索（ti=标题, au=作者, cc=MSC分类码, py=年份）
https://api.zbmath.org/v1/document/_search?search_string=ti:isomonodromy+AND+au:Xu&results_per_page=10

# 按作者搜索
https://api.zbmath.org/v1/document/_search?search_string=au:Xu+Xiaomeng&results_per_page=10

# 作者信息
https://api.zbmath.org/v1/author/_search?search_string=au:Xu+Xiaomeng

# 返回字段：title, contributors.authors, year, keywords, editorial_contributions(专家评审), links(DOI/arXiv), document_type, msc(分类码)
```

### OpenAlex

2.5亿+论文的开放学术图谱。返回 JSON。2026.2起需免费API Key（https://openalex.org/settings/api）。

```
# 搜索论文
https://api.openalex.org/works?search={关键词}&per_page=10&select=id,title,publication_year,cited_by_count,authorships,doi

# 按作者ID查论文（你的导师=A...）
https://api.openalex.org/works?filter=author.id:A5019142880&per_page=50&select=id,title,publication_year,cited_by_count,doi

# 作者画像
https://api.openalex.org/authors/A5019142880?select=id,display_name,works_count,cited_by_count,last_known_institutions,topics,summary_stats

# 按DOI查单篇
https://api.openalex.org/works/doi:{doi}

# 注意：中文名搜索不准，先搜论文标题获取作者ID再反查
```

### Unpaywall

按DOI查免费全文。返回 JSON。无需Key，需邮箱标识（不验证）。

```
# 查OA状态和PDF链接
https://api.unpaywall.org/v2/{doi}?email={你的邮箱}

# 关键返回字段：
# is_oa - 是否开放获取
# oa_status - green/gold/hybrid/bronze/closed
# best_oa_location.url_for_pdf - 最佳免费PDF链接
# oa_locations[] - 所有可用的免费版本
```

### Wikipedia

返回 JSON。无需Key，无硬性限流。支持中英文（换域名前缀）。

```
# 搜索条目
https://en.wikipedia.org/w/api.php?action=query&list=search&srsearch={关键词}&format=json&utf8=1&srlimit=10
# 中文版
https://zh.wikipedia.org/w/api.php?action=query&list=search&srsearch={关键词}&format=json&utf8=1&srlimit=10

# 获取页面摘要（纯文本，仅引言段）
https://en.wikipedia.org/w/api.php?action=query&titles={页面标题}&prop=extracts&exintro=1&explaintext=1&format=json

# 获取完整页面内容（wikitext）
https://en.wikipedia.org/w/api.php?action=query&titles={页面标题}&prop=revisions&rvprop=content&format=json

# 获取分类和链接
https://en.wikipedia.org/w/api.php?action=query&titles={页面标题}&prop=categories|links&cllimit=20&pllimit=20&format=json
```

### 百度地图（待填Key）

返回 JSON。注册：https://lbsyun.baidu.com/apiconsole/key
核心价值：POI 检索返回 detail_info 含评分、人均、评论数（高德无此数据）。

```
# 关键词搜索（含评分详情）
# scope=2 返回 detail_info（评分、人均等）
https://api.map.baidu.com/place/v2/search?query={关键词}&region={城市}&scope=2&output=json&ak={key}

# 周边搜索（含评分详情）
https://api.map.baidu.com/place/v2/search?query={关键词}&location={纬度},{经度}&radius={半径米}&scope=2&output=json&ak={key}

# 地点详情（单个POI）
https://api.map.baidu.com/place/v2/detail?uid={poi_uid}&scope=2&output=json&ak={key}

# detail_info 关键字段：
# overall_rating - 总评分(1-5)
# taste_rating - 口味评分
# service_rating - 服务评分
# environment_rating - 环境评分
# price - 人均价格(元)
# comment_num - 评论数
# tag - 标签(如"川菜 火锅")
```

注意：百度地图坐标系为 BD-09，高德/GPS 为 GCJ-02/WGS-84，混用会偏移数百米。

### OpenWeatherMap（待注册Key）

返回 JSON。免费1000次/天。注册：https://openweathermap.org/api

```
# 当前天气（按城市名）
https://api.openweathermap.org/data/2.5/weather?q={城市名}&appid={key}&units=metric&lang=zh_cn

# 当前天气（按坐标，可配合高德地理编码）
https://api.openweathermap.org/data/2.5/weather?lat={纬度}&lon={经度}&appid={key}&units=metric&lang=zh_cn

# 5天预报（每3小时）
https://api.openweathermap.org/data/2.5/forecast?q={城市名}&appid={key}&units=metric&lang=zh_cn
```

### LMFDB

L-函数与模形式数据库。返回 JSON。免费无Key。涵盖椭圆曲线、数域、模形式、Galois表示、Maass形式等。

```
# Swagger文档
https://www.lmfdb.org/api/swagger

# 椭圆曲线搜索（按conductor范围）
https://www.lmfdb.org/api/ec_curvedata/?conductor=11&_format=json

# 按label查单条椭圆曲线
https://www.lmfdb.org/api/ec_curvedata/?label=11.a1&_format=json

# 模形式搜索（按level和weight）
https://www.lmfdb.org/api/mf_newforms/?level=1&weight=12&_format=json

# 数域搜索（按degree）
https://www.lmfdb.org/api/nf_fields/?degree=3&_format=json

# L-函数
https://www.lmfdb.org/api/lfunc_lfunctions/?degree=2&_format=json

# 通用参数：_format=json, _max_count=50, _offset=0
```

### OEIS

整数序列百科。返回 JSON。免费无Key。37万+序列。

```
# 按关键词搜索
https://oeis.org/search?fmt=json&q={关键词}&start=0

# 按序列号查
https://oeis.org/search?fmt=json&q=id:A000108

# 按序列值搜索（逗号分隔）
https://oeis.org/search?fmt=json&q=1,1,2,3,5,8,13

# 返回字段：number(序列号), name(名称), formula, comment, reference, link, example
# start参数控制偏移，每页默认10条
```

### INSPIRE-HEP

数学物理文献核心库。返回 JSON。免费无Key。覆盖可积系统、gauge theory、弦论、Painlevé等。

```
# 搜索论文
https://inspirehep.net/api/literature?sort=mostrecent&size=10&q={关键词}

# 按作者搜索
https://inspirehep.net/api/literature?sort=mostrecent&size=10&q=a%20Author.Name

# 按arXiv ID查
https://inspirehep.net/api/arxiv/2501.01419

# 查作者profile
https://inspirehep.net/api/authors?q={作者名}&size=5

# 查引用
https://inspirehep.net/api/literature?q=refersto:recid:{record_id}&size=20

# 搜索语法：t(标题) a(作者) eprint(arXiv号) j(期刊) topcite(高引)
# 例：高引Painlevé论文
https://inspirehep.net/api/literature?q=t%20Painleve%20and%20topcite%20100%2B&size=10
```

### DLMF (NIST)

特殊函数权威参考。无正式API，结构化URL直接WebFetch。Painlevé transcendents = Ch.32。

```
# 章节直接访问（WebFetch抓取）
https://dlmf.nist.gov/32  — Painlevé Transcendents
https://dlmf.nist.gov/15  — Hypergeometric Function
https://dlmf.nist.gov/10  — Bessel Functions
https://dlmf.nist.gov/18  — Orthogonal Polynomials
https://dlmf.nist.gov/25  — Zeta and Related Functions
https://dlmf.nist.gov/5   — Gamma Function

# 子节访问
https://dlmf.nist.gov/32.2  — Painlevé: Differential Equations
https://dlmf.nist.gov/32.7  — Painlevé: Bäcklund Transformations
https://dlmf.nist.gov/32.11 — Painlevé: Asymptotic Approximations

# 全部章节索引
https://dlmf.nist.gov/contents/
```

### nLab

范畴论/同伦论/高等数学研究级wiki。无API，WebFetch直接抓页面。

```
# 页面直接访问（WebFetch抓取）
https://ncatlab.org/nlab/show/{页面名}

# 示例
https://ncatlab.org/nlab/show/monodromy
https://ncatlab.org/nlab/show/Painlev%C3%A9+property
https://ncatlab.org/nlab/show/integrable+system
https://ncatlab.org/nlab/show/moduli+space
https://ncatlab.org/nlab/show/Riemann-Hilbert+correspondence

# 搜索（返回HTML，需解析）
https://ncatlab.org/nlab/search?query={关键词}
```

### Open Library

图书元数据、主题、版本信息。返回 JSON。免费无Key。2000万+著作。

```
# 搜索图书
https://openlibrary.org/search.json?q={关键词}&limit=10&fields=key,title,author_name,first_publish_year,isbn,number_of_pages_median,subject

# 按作者搜索
https://openlibrary.org/search.json?author={作者名}&limit=10&fields=key,title,first_publish_year

# 获取著作详情（主题、描述、相关版本）
https://openlibrary.org/works/{work_key}.json
# 例：https://openlibrary.org/works/OL628450W.json (Das Kapital)

# 获取具体版本（含出版社、页数、ISBN）
https://openlibrary.org/books/{edition_key}.json

# 按ISBN查
https://openlibrary.org/isbn/{isbn}.json

# 按主题浏览
https://openlibrary.org/subjects/{主题}.json?limit=10
# 例：https://openlibrary.org/subjects/marxism.json?limit=10
```

### Gutendex (Project Gutenberg)

公版电子书全文。返回 JSON。免费无Key。7万+书，含 txt/html 格式直链。

```
# 搜索图书
https://gutendex.com/books/?search={关键词}

# 按作者搜索
https://gutendex.com/books/?search={作者名}

# 按ID获取单本书（含所有格式下载链接）
https://gutendex.com/books/{id}/

# 已知 Marx 作品ID：
# 61 - The Communist Manifesto
# 1346 - The Eighteenth Brumaire of Louis Bonaparte
# 46423 - A Contribution to the Critique of Political Economy

# 获取全文（从 formats 字段取 text/plain 链接）：
# https://www.gutenberg.org/cache/epub/61/pg61.txt
# 格式规律：https://www.gutenberg.org/cache/epub/{id}/pg{id}.txt

# 按主题筛选
https://gutendex.com/books/?topic={主题}

# 按语言筛选（en/de/fr/zh）
https://gutendex.com/books/?languages={语言代码}&search={关键词}
```

### Wiktionary

词典、词源、发音、释义。返回 JSON。免费无Key。支持中英文。

```
# 获取词条内容（英文）
https://en.wiktionary.org/w/api.php?action=query&titles={单词}&prop=extracts&explaintext=1&format=json

# 搜索词条
https://en.wiktionary.org/w/api.php?action=query&list=search&srsearch={关键词}&format=json&srlimit=10

# 中文版
https://zh.wiktionary.org/w/api.php?action=query&titles={词}&prop=extracts&explaintext=1&format=json

# 推荐用 Free Dictionary API（更结构化）：
https://api.dictionaryapi.dev/api/v2/entries/en/{word}
# 返回：定义、词性、音标、例句、近义词、反义词
```

### Stanford Encyclopedia of Philosophy

学术级哲学百科。无API，WebFetch直接抓。条目由领域专家撰写和维护。

```
# 条目直接访问（WebFetch抓取）
https://plato.stanford.edu/entries/{条目名}/

# 示例
https://plato.stanford.edu/entries/marx/
https://plato.stanford.edu/entries/dialectical-materialism/
https://plato.stanford.edu/entries/karl-marx/
https://plato.stanford.edu/entries/socialism/
https://plato.stanford.edu/entries/hegel-dialectics/
https://plato.stanford.edu/entries/critical-theory/
https://plato.stanford.edu/entries/lukacs/

# 目录
https://plato.stanford.edu/contents.html

# 搜索（WebFetch抓取结果页）
https://plato.stanford.edu/search/searcher.py?query={关键词}
```

### Marxists Internet Archive

马恩列毛经典著作全文。无API，WebFetch直接抓。多语言（英/中/德/法/俄）。

```
# 马克思著作索引
https://www.marxists.org/archive/marx/works/index.htm
# 中文版
https://www.marxists.org/chinese/marx/index.htm

# 恩格斯著作索引
https://www.marxists.org/archive/marx/works/subject/Engels/index.htm
# 中文版
https://www.marxists.org/chinese/engels/index.htm

# 列宁著作索引
https://www.marxists.org/archive/lenin/works/index.htm

# 毛泽东著作索引
https://www.marxists.org/chinese/maozedong/index.htm

# 常用直链（WebFetch抓取）
# 共产党宣言（中文）
https://www.marxists.org/chinese/marx/01.htm
# 资本论第一卷（中文）
https://www.marxists.org/chinese/marx/erta/index.htm
# 雇佣劳动与资本（中文）
https://www.marxists.org/chinese/marx/marxist.org-chinese-marx-1849.htm
# 哥达纲领批判（中文）
https://www.marxists.org/chinese/marx/marxist.org-chinese-marx-1875.htm

# 哲学类
# 德意志意识形态（中文）
https://www.marxists.org/chinese/marx/marxist.org-chinese-marx-1Mo846.htm
# 费尔巴哈论（中文）
https://www.marxists.org/chinese/engels/marxist.org-chinese-erta-1888.htm
# 反杜林论（中文）
https://www.marxists.org/chinese/engels/erta14/index.htm
```

### 医学四件套（本地工具）

工具路径：`~/ai/data/medical/medtools.py`
纯 Python 3，无第三方依赖。SSL 自动处理。

```
# PubMed 文献搜索
python3 ~/ai/data/medical/medtools.py pubmed "femoroacetabular impingement treatment" --max 10

# PubMed 单篇详情（含完整摘要、MeSH、关键词）
python3 ~/ai/data/medical/medtools.py pubmed-detail 14646708

# ClinicalTrials.gov 临床试验搜索
python3 ~/ai/data/medical/medtools.py trials "hip arthroscopy" --max 10

# 临床试验详情（含入组标准、干预、终点）
python3 ~/ai/data/medical/medtools.py trial-detail NCT06823089

# OpenFDA 药品不良反应（按频率排序）
python3 ~/ai/data/medical/medtools.py openfda-adverse ibuprofen --max 20

# OpenFDA 药品说明书（适应症/用量/禁忌/相互作用/机制）
python3 ~/ai/data/medical/medtools.py openfda-label celecoxib

# OpenFDA 药品基本信息
python3 ~/ai/data/medical/medtools.py openfda-drug aspirin

# MeSH 医学主题词查询（含定义、树号层级）
python3 ~/ai/data/medical/medtools.py mesh "osteoarthritis"

# Europe PMC 文献搜索（含开放获取全文链接）
python3 ~/ai/data/medical/medtools.py europmc "hip labral tear" --max 10

# RxNorm 药品标准化名称（品牌/通用名/剂型/NDC编码）
python3 ~/ai/data/medical/medtools.py rxnorm ibuprofen

# DailyMed 药品说明书（NIH/NLM，含链接）
python3 ~/ai/data/medical/medtools.py dailymed celecoxib --max 5

# DrugBank 本地药物查询（19830种，支持名称/同义词/CAS/DrugBank ID）
python3 ~/ai/data/medical/medtools.py drugbank ibuprofen
python3 ~/ai/data/medical/medtools.py drugbank DB00945
python3 ~/ai/data/medical/medtools.py drugbank 50-78-2

# UMLS 概念查询（需 API Key，注册见下方）
python3 ~/ai/data/medical/medtools.py umls "osteoarthritis"
```

### 图书搜索工具（本地工具）

工具路径：`~/ai/data/books/booktools.py`
纯 Python 3，无第三方依赖。

```
# 豆瓣图书搜索（书名/作者）
python3 ~/ai/data/books/booktools.py douban "三体"
python3 ~/ai/data/books/booktools.py douban "刘慈欣"

# 豆瓣图书详情（评分、ISBN、简介）
python3 ~/ai/data/books/booktools.py douban-detail 2567698

# Anna's Archive 电子书搜索
python3 ~/ai/data/books/booktools.py anna "三体" --ext epub --max 5
python3 ~/ai/data/books/booktools.py anna "Erta Getzler" --ext pdf --lang en

# Anna's Archive 电子书详情
python3 ~/ai/data/books/booktools.py anna-detail 1473ae1eb74edc729090dd180783aee4

# 典型工作流：豆瓣查 ISBN → Anna's Archive 找电子书
# 1. python3 booktools.py douban "资本论" → 拿到 ISBN
# 2. python3 booktools.py anna "9787010009186" --ext epub → 精确搜索

# Anna's Archive 参数：
# --ext: epub, pdf, mobi, azw3, djvu
# --lang: zh, en, de, fr, ja, ru 等
# --max: 返回结果数（默认10）
# --content: book_fiction, book_nonfiction, book_unknown, book_comic, magazine

# 注意：Anna's Archive 域名经常变化，当前 .gl 可用（2026-03-04）
# 工具内置多域名自动切换（gl → pm → li）
```

### 天气查询工具（本地工具）

工具路径：`~/ai/data/weather/weathertools.py`
纯 Python 3，无第三方依赖。数据源：Open-Meteo（免费无Key）+ 高德地理编码。
覆盖全中国内地所有城市，支持区县级地名。

```
# 实况天气（温度/体感/湿度/风/气压/云量）
python3 ~/ai/data/weather/weathertools.py now 北京

# 未来N天预报（默认7天，最多16天）
python3 ~/ai/data/weather/weathertools.py forecast 上海 10

# 逐小时预报（默认48h，最多168h）
python3 ~/ai/data/weather/weathertools.py hourly 成都 72

# 历史天气（日级+小时级湿度/能见度）
python3 ~/ai/data/weather/weathertools.py history 北京 2025-04-02 2025-04-06

# 空气质量（PM2.5/PM10/O₃/NO₂/SO₂/CO/AQI）
python3 ~/ai/data/weather/weathertools.py aqi 北京

# 出行综合评估（温度/降水/UV/风力/湿度/穿衣建议/问题预警）
# 超出预报范围时自动用去年同期数据
python3 ~/ai/data/weather/weathertools.py travel 北京 2026-04-02 2026-04-06

# 历年同期对比（默认近3年，最多可查更多）
python3 ~/ai/data/weather/weathertools.py compare 北京 04-02 5

# 支持区县级地名（首次查询自动缓存坐标）
python3 ~/ai/data/weather/weathertools.py now 延庆
python3 ~/ai/data/weather/weathertools.py now 威海

# 数据字段覆盖：
# 温度、体感温度、湿度、露点、降水量、降水概率、雨量、雪量
# 云量、风速、风向、阵风、UV指数、能见度、气压
# 日出日落、日照时长
# 空气质量：PM2.5/PM10/O₃/NO₂/SO₂/CO/US AQI
```

### 萌典 (MoeDict)

中文词典。返回 JSON。免费无Key无限流。16万条。基于台湾教育部《重编国语辞典修订本》，CC0 公有领域。

```
# 查单字（部首/笔画/注音/拼音/释义/引文/例句）
curl 'https://www.moedict.tw/uni/道'

# 查词语
curl 'https://www.moedict.tw/uni/天下'

# 注意：必须用 www.moedict.tw 域名（moedict.org 没开 CORS）
# 返回字段：title, radical, stroke_count, heteronyms[].bopomofo/pinyin/definitions[]
# definitions 含：type(词性), def(释义), quote(引文), example(例句)
```

### Chinese Text Project (ctext.org)

先秦至清代古籍数字图书馆 + 汉字属性查询。返回 JSON。免费（基础功能无需Key）。哈佛大学维护。

```
# 查汉字属性（部首/笔画/多语言读音/异体字）
curl 'https://api.ctext.org/getcharacter?char=仁'
# 返回：radical, totalstrokes, mandarinpinyin, cantonese, 异体字列表

# 获取古籍章节全文（如《论语·学而》）
curl 'https://api.ctext.org/gettext?urn=ctp:analects/xue-er'

# 简体输出
curl 'https://api.ctext.org/gettext?urn=ctp:analects/xue-er&remap=gb'

# 搜索书名
curl 'https://api.ctext.org/searchtexts?title=論語'

# 朝代列表
curl 'https://api.ctext.org/getdynasties'

# 全部可用方法
curl 'https://api.ctext.org/getcapabilities'

# 注意：有速率限制（ERR_REQUEST_LIMIT），子节数据需注册账户
# 可选参数：if=en|zh（界面语言）、remap=gb（简体化）
```

### Unicode API (Unihan)

Unicode 17.0 Unihan 数据库 REST API。返回 JSON。免费无Key。个人项目（a-luna）。

```
# 查汉字读音和变体
curl 'https://unicode-api.aaronluna.dev/v1/characters/-/水?show_props=CJK%20Readings&show_props=CJK%20Variants'
# 返回：mandarin, cantonese, japaneseKun, japaneseOn, hangul, vietnamese, semanticVariant

# 按码点查全部属性（33个字段）
curl 'https://unicode-api.aaronluna.dev/v1/codepoints/6C34?show_props=all'

# show_props 可选值：Minimum, Basic, CJK Readings, CJK Variants, CJK Numeric, all
# Swagger 文档：https://unicode-api.aaronluna.dev/v1/docs
```

### Hanzi Writer Data (CDN)

笔画 SVG 数据。CDN 分发，免费无Key。9000+ 字。基于 Make Me a Hanzi 项目。

```
# 查单字笔画数据（SVG路径 + 中线坐标）
curl 'https://cdn.jsdelivr.net/npm/hanzi-writer-data@latest/我.json'
# 返回：strokes(SVG路径), medians(中线坐标), radStrokes(部首笔画索引)

# 坐标系：1024x1024，左上(0,900)，右下(1024,-124)
# 配套渲染库：https://github.com/chanind/hanzi-writer

# 字源数据需从原始仓库获取：
# https://github.com/skishore/makemeahanzi → dictionary.txt
# 含 etymology 字段：type(pictophonetic/ideographic/pictographic), phonetic, semantic
```

### PlantNet 植物识别

拍照识花。免费500次/天。注册：https://my.plantnet.org → Settings → API Key。

```
# POST 本地图片识别（推荐，最准）
curl -X POST "https://my-api.plantnet.org/v2/identify/all?api-key={key}&lang=zh" \
  -F "images=@/path/to/flower.jpg" \
  -F "organs=flower"

# POST 多张图（最多5张，花+叶组合更准）
curl -X POST "https://my-api.plantnet.org/v2/identify/all?api-key={key}&lang=zh" \
  -F "images=@flower.jpg" -F "organs=flower" \
  -F "images=@leaf.jpg" -F "organs=leaf"

# GET 远程图片URL识别
curl "https://my-api.plantnet.org/v2/identify/all?images={图片URL}&organs=auto&lang=zh&api-key={key}"

# organs 可选值：flower(花), leaf(叶), fruit(果), bark(树皮), auto(AI自动判断)
# lang: zh(中文), en(英文), fr(法文) 等
# include-related-images=true 返回相似图片URL（辅助人工确认）
# no-reject=true 强制返回结果（即使AI认为不是植物）

# 返回字段：
# results[].species.scientificNameWithoutAuthor — 学名
# results[].species.commonNames — 常见名（多语言）
# results[].species.family.scientificName — 科名
# results[].species.genus.scientificName — 属名
# results[].score — 置信度(0-1)
# results[].images[] — 最相似的参考图片
```

### 大众点评搜索工具（本地工具）

工具路径：`~/ai/data/dianping/dianping_search.py`
依赖：playwright, cryptography（均已安装）。数据源：Playwright + Chrome 登录态 cookies。
前提：用户需在 Chrome 中登录过 www.dianping.com（cookies 过期需重新登录）。

```
# 搜索商户（默认北京，15条）
python3 ~/ai/data/dianping/dianping_search.py "omakase"
python3 ~/ai/data/dianping/dianping_search.py "古风写真"
python3 ~/ai/data/dianping/dianping_search.py "直升机观光"

# 指定城市（北京=2 上海=1 深圳=7 广州=4 杭州=3 成都=8 厦门=57）
python3 ~/ai/data/dianping/dianping_search.py "女仆咖啡" --city 上海

# 更多结果
python3 ~/ai/data/dianping/dianping_search.py "铁板烧" --max 20

# JSON 输出（供程序解析）
python3 ~/ai/data/dianping/dianping_search.py "omakase" --json

# 返回字段：店名、评价数、人均价格、分类、商圈
# 注意：每次调用 = 1次页面访问，避免短时间内连续大量调用
```

### ~~小红书搜索工具~~（已移除）

2026-03-30 账号被封，工具已删除。
