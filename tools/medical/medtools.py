#!/usr/bin/env python3
"""
医学数据库本地查询工具集
用法: python3 medtools.py <command> [args...]

Commands:
  pubmed <query> [--max N]           搜索 PubMed 文献
  pubmed-detail <pmid>               获取单篇文献详情（含摘要）
  europmc <query> [--max N]          搜索 Europe PMC（含全文开放获取）
  trials <query> [--max N]           搜索 ClinicalTrials.gov 临床试验
  trial-detail <nctid>               获取单个试验详情
  openfda-drug <query>               FDA 药品信息查询
  openfda-adverse <query> [--max N]  FDA 药品不良反应报告
  openfda-label <query>              FDA 药品说明书搜索
  dailymed <query> [--max N]         DailyMed 药品说明书搜索（NIH/NLM）
  rxnorm <drug_name>                 RxNorm 药品标准化名称查询
  mesh <term>                        MeSH 医学主题词查询
  umls <term>                        UMLS 概念查询（需 API Key）
  drugbank <name>                    DrugBank 本地药物查询（19830种）

环境: 纯 Python 3，无需第三方依赖
API Key: ~/ai/data/keys/api-keys.json 自动读取
  - ncbi_api_key: PubMed 提速（3→10 req/s），可选
  - umls_api_key: UMLS 查询必需，免费注册
"""

import os
import sys
import json
import ssl
import sqlite3
import urllib.request
import urllib.parse
import xml.etree.ElementTree as ET
from textwrap import dedent

# macOS Python SSL 证书修复
if not os.environ.get("SSL_CERT_FILE"):
    for cert_path in ["/etc/ssl/cert.pem", "/etc/ssl/certs/ca-certificates.crt"]:
        if os.path.exists(cert_path):
            os.environ["SSL_CERT_FILE"] = cert_path
            break

# ── API Keys (auto-load from ~/ai/data/keys/api-keys.json) ───────────

KEYS_FILE = os.path.expanduser("~/ai/data/keys/api-keys.json")
_keys_cache = None

def _load_keys():
    global _keys_cache
    if _keys_cache is None:
        try:
            with open(KEYS_FILE, "r") as f:
                _keys_cache = json.load(f)
        except (FileNotFoundError, json.JSONDecodeError):
            _keys_cache = {}
    return _keys_cache

def _get_key(name: str) -> str:
    keys = _load_keys()
    entry = keys.get(name, {})
    if isinstance(entry, dict):
        return entry.get("key", "")
    return str(entry) if entry else ""


# ── PubMed / NCBI E-utilities ────────────────────────────────────────

PUBMED_BASE = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils"
PUBMED_API_KEY = ""  # auto-loaded below

def _pubmed_params(extra: dict) -> str:
    global PUBMED_API_KEY
    if not PUBMED_API_KEY:
        PUBMED_API_KEY = _get_key("ncbi")
    params = {"retmode": "json", "tool": "medtools", "email": "claude-code@local"}
    if PUBMED_API_KEY:
        params["api_key"] = PUBMED_API_KEY
    params.update(extra)
    return urllib.parse.urlencode(params)

def pubmed_search(query: str, max_results: int = 10):
    """搜索 PubMed，返回 PMID 列表及摘要信息"""
    # Step 1: esearch
    url = f"{PUBMED_BASE}/esearch.fcgi?{_pubmed_params({'db': 'pubmed', 'term': query, 'retmax': str(max_results), 'sort': 'relevance'})}"
    with urllib.request.urlopen(url, timeout=30) as resp:
        data = json.loads(resp.read())

    result = data.get("esearchresult", {})
    id_list = result.get("idlist", [])
    total = result.get("count", "0")

    if not id_list:
        print(f"未找到相关文献 (query: {query})")
        return

    print(f"共找到 {total} 篇，显示前 {len(id_list)} 篇:\n")

    # Step 2: esummary for details
    ids = ",".join(id_list)
    url2 = f"{PUBMED_BASE}/esummary.fcgi?{_pubmed_params({'db': 'pubmed', 'id': ids})}"
    with urllib.request.urlopen(url2, timeout=30) as resp:
        summary = json.loads(resp.read())

    results_data = summary.get("result", {})
    for pmid in id_list:
        info = results_data.get(pmid, {})
        title = info.get("title", "N/A")
        authors_list = info.get("authors", [])
        authors = ", ".join([a.get("name", "") for a in authors_list[:3]])
        if len(authors_list) > 3:
            authors += " et al."
        source = info.get("source", "")
        pubdate = info.get("pubdate", "")
        doi_list = [eid["value"] for eid in info.get("articleids", []) if eid.get("idtype") == "doi"]
        doi = doi_list[0] if doi_list else ""

        print(f"PMID: {pmid}")
        print(f"  标题: {title}")
        print(f"  作者: {authors}")
        print(f"  来源: {source} ({pubdate})")
        if doi:
            print(f"  DOI: {doi}")
        print(f"  链接: https://pubmed.ncbi.nlm.nih.gov/{pmid}/")
        print()


def pubmed_detail(pmid: str):
    """获取单篇 PubMed 文献的完整摘要"""
    # efetch with XML for abstract
    url = f"{PUBMED_BASE}/efetch.fcgi?db=pubmed&id={pmid}&rettype=xml&retmode=xml"
    if PUBMED_API_KEY:
        url += f"&api_key={PUBMED_API_KEY}"

    with urllib.request.urlopen(url, timeout=30) as resp:
        xml_data = resp.read()

    root = ET.fromstring(xml_data)
    article = root.find(".//PubmedArticle")
    if article is None:
        print(f"PMID {pmid} 未找到")
        return

    # Title
    title_el = article.find(".//ArticleTitle")
    title = "".join(title_el.itertext()) if title_el is not None else "N/A"

    # Authors
    authors = []
    for author in article.findall(".//Author"):
        last = author.findtext("LastName", "")
        fore = author.findtext("ForeName", "")
        if last:
            authors.append(f"{last} {fore}".strip())

    # Journal
    journal = article.findtext(".//Journal/Title", "N/A")
    year = article.findtext(".//PubDate/Year", "")
    month = article.findtext(".//PubDate/Month", "")

    # Abstract
    abstract_parts = []
    for abs_text in article.findall(".//AbstractText"):
        label = abs_text.get("Label", "")
        text = "".join(abs_text.itertext())
        if label:
            abstract_parts.append(f"[{label}] {text}")
        else:
            abstract_parts.append(text)
    abstract = "\n".join(abstract_parts) if abstract_parts else "无摘要"

    # MeSH terms
    mesh_terms = [mh.findtext("DescriptorName", "") for mh in article.findall(".//MeshHeading")]

    # DOI
    doi_el = article.find(".//ArticleId[@IdType='doi']")
    doi = doi_el.text if doi_el is not None else ""

    # Keywords
    keywords = [kw.text for kw in article.findall(".//Keyword") if kw.text]

    print(f"PMID: {pmid}")
    print(f"标题: {title}")
    print(f"作者: {', '.join(authors)}")
    print(f"期刊: {journal} ({year} {month})")
    if doi:
        print(f"DOI: {doi}")
    print(f"链接: https://pubmed.ncbi.nlm.nih.gov/{pmid}/")
    if keywords:
        print(f"关键词: {', '.join(keywords)}")
    if mesh_terms:
        print(f"MeSH: {', '.join(mesh_terms[:10])}")
    print(f"\n{'='*60}")
    print(f"摘要:\n{abstract}")
    print(f"{'='*60}")


# ── ClinicalTrials.gov v2 API ────────────────────────────────────────

TRIALS_BASE = "https://clinicaltrials.gov/api/v2"

def trials_search(query: str, max_results: int = 10):
    """搜索 ClinicalTrials.gov 临床试验"""
    params = urllib.parse.urlencode({
        "query.term": query,
        "pageSize": str(max_results),
        "format": "json",
        "fields": "NCTId,BriefTitle,OverallStatus,Phase,StartDate,Condition,InterventionName,LocationCity,LocationCountry,EnrollmentCount",
        "sort": "LastUpdatePostDate:desc"
    })
    url = f"{TRIALS_BASE}/studies?{params}"

    req = urllib.request.Request(url)
    with urllib.request.urlopen(req, timeout=30) as resp:
        data = json.loads(resp.read())

    studies = data.get("studies", [])
    total = data.get("totalCount", 0)

    if not studies:
        print(f"未找到相关临床试验 (query: {query})")
        return

    print(f"共找到 {total} 项试验，显示前 {len(studies)} 项:\n")

    for study in studies:
        proto = study.get("protocolSection", {})
        ident = proto.get("identificationModule", {})
        status_mod = proto.get("statusModule", {})
        design = proto.get("designModule", {})
        cond_mod = proto.get("conditionsModule", {})
        interv_mod = proto.get("armsInterventionsModule", {})

        nctid = ident.get("nctId", "N/A")
        title = ident.get("briefTitle", "N/A")
        status = status_mod.get("overallStatus", "N/A")
        start = status_mod.get("startDateStruct", {}).get("date", "N/A")
        phases = design.get("phases", [])
        phase = ", ".join(phases) if phases else "N/A"
        conditions = cond_mod.get("conditions", [])

        interventions = []
        for arm in interv_mod.get("interventions", []):
            interventions.append(f"{arm.get('type', '')}: {arm.get('name', '')}")

        enrollment = design.get("enrollmentInfo", {}).get("count", "N/A")

        print(f"NCT ID: {nctid}")
        print(f"  标题: {title}")
        print(f"  状态: {status} | 阶段: {phase} | 入组: {enrollment}")
        print(f"  开始: {start}")
        if conditions:
            print(f"  病症: {', '.join(conditions[:3])}")
        if interventions:
            print(f"  干预: {'; '.join(interventions[:3])}")
        print(f"  链接: https://clinicaltrials.gov/study/{nctid}")
        print()


def trial_detail(nctid: str):
    """获取单个临床试验详情"""
    url = f"{TRIALS_BASE}/studies/{nctid}?format=json"

    req = urllib.request.Request(url)
    with urllib.request.urlopen(req, timeout=30) as resp:
        data = json.loads(resp.read())

    proto = data.get("protocolSection", {})
    ident = proto.get("identificationModule", {})
    status_mod = proto.get("statusModule", {})
    desc = proto.get("descriptionModule", {})
    design = proto.get("designModule", {})
    cond_mod = proto.get("conditionsModule", {})
    elig = proto.get("eligibilityModule", {})
    interv_mod = proto.get("armsInterventionsModule", {})
    outcome_mod = proto.get("outcomesModule", {})

    print(f"NCT ID: {ident.get('nctId', nctid)}")
    print(f"标题: {ident.get('officialTitle', ident.get('briefTitle', 'N/A'))}")
    print(f"状态: {status_mod.get('overallStatus', 'N/A')}")
    print(f"阶段: {', '.join(design.get('phases', ['N/A']))}")
    print(f"开始: {status_mod.get('startDateStruct', {}).get('date', 'N/A')}")
    print(f"完成: {status_mod.get('completionDateStruct', {}).get('date', 'N/A')}")
    print(f"入组: {design.get('enrollmentInfo', {}).get('count', 'N/A')}")

    conditions = cond_mod.get("conditions", [])
    if conditions:
        print(f"病症: {', '.join(conditions)}")

    # Interventions
    interventions = interv_mod.get("interventions", [])
    if interventions:
        print(f"\n干预措施:")
        for inv in interventions:
            print(f"  - [{inv.get('type', '')}] {inv.get('name', '')}: {inv.get('description', '')[:200]}")

    # Eligibility
    print(f"\n入组标准:")
    print(f"  年龄: {elig.get('minimumAge', 'N/A')} - {elig.get('maximumAge', 'N/A')}")
    print(f"  性别: {elig.get('sex', 'N/A')}")
    criteria = elig.get("eligibilityCriteria", "")
    if criteria:
        print(f"  详细:\n{criteria[:1000]}")

    # Brief summary
    brief = desc.get("briefSummary", "")
    if brief:
        print(f"\n研究摘要:\n{brief[:2000]}")

    # Primary outcomes
    primary = outcome_mod.get("primaryOutcomes", [])
    if primary:
        print(f"\n主要终点:")
        for po in primary:
            print(f"  - {po.get('measure', '')} ({po.get('timeFrame', '')})")

    print(f"\n链接: https://clinicaltrials.gov/study/{nctid}")


# ── OpenFDA API ──────────────────────────────────────────────────────

OPENFDA_BASE = "https://api.fda.gov"

def openfda_drug(query: str):
    """查询 FDA 药品信息"""
    params = urllib.parse.urlencode({
        "search": f'openfda.brand_name:"{query}"+openfda.generic_name:"{query}"',
        "limit": "5"
    })
    url = f"{OPENFDA_BASE}/drug/drugsfda.json?{params}"

    try:
        with urllib.request.urlopen(url, timeout=30) as resp:
            data = json.loads(resp.read())
    except urllib.error.HTTPError:
        # 尝试更宽松的搜索
        params2 = urllib.parse.urlencode({"search": query, "limit": "5"})
        url2 = f"{OPENFDA_BASE}/drug/drugsfda.json?{params2}"
        with urllib.request.urlopen(url2, timeout=30) as resp:
            data = json.loads(resp.read())

    results = data.get("results", [])
    total = data.get("meta", {}).get("results", {}).get("total", 0)

    if not results:
        print(f"未找到药品信息 (query: {query})")
        return

    print(f"找到 {total} 条记录，显示前 {len(results)} 条:\n")

    for r in results:
        openfda = r.get("openfda", {})
        brand = openfda.get("brand_name", ["N/A"])
        generic = openfda.get("generic_name", ["N/A"])
        manufacturer = openfda.get("manufacturer_name", ["N/A"])
        route = openfda.get("route", ["N/A"])
        substance = openfda.get("substance_name", [])

        products = r.get("products", [])

        print(f"品牌名: {', '.join(brand) if isinstance(brand, list) else brand}")
        print(f"  通用名: {', '.join(generic) if isinstance(generic, list) else generic}")
        print(f"  制造商: {', '.join(manufacturer) if isinstance(manufacturer, list) else manufacturer}")
        print(f"  给药途径: {', '.join(route) if isinstance(route, list) else route}")
        if substance:
            print(f"  活性成分: {', '.join(substance)}")
        if products:
            for p in products[:2]:
                print(f"  产品: {p.get('brand_name', '')} - {p.get('dosage_form', '')} {p.get('active_ingredients', [{}])[0].get('strength', '') if p.get('active_ingredients') else ''}")
        print()


def openfda_adverse(query: str, max_results: int = 10):
    """查询 FDA 药品不良反应报告"""
    params = urllib.parse.urlencode({
        "search": f'patient.drug.medicinalproduct:"{query}"',
        "count": "patient.reaction.reactionmeddrapt.exact",
        "limit": str(max_results)
    })
    url = f"{OPENFDA_BASE}/drug/event.json?{params}"

    with urllib.request.urlopen(url, timeout=30) as resp:
        data = json.loads(resp.read())

    results = data.get("results", [])

    if not results:
        print(f"未找到不良反应报告 (drug: {query})")
        return

    total_reports = data.get("meta", {}).get("results", {}).get("total", 0)
    print(f"药品 \"{query}\" 共有 {total_reports} 份不良反应报告")
    print(f"最常见不良反应 (Top {len(results)}):\n")

    for r in results:
        reaction = r.get("term", "N/A")
        count = r.get("count", 0)
        print(f"  {reaction}: {count} 例")


def openfda_label(query: str):
    """搜索 FDA 药品说明书（标签）"""
    params = urllib.parse.urlencode({
        "search": f'openfda.brand_name:"{query}"+openfda.generic_name:"{query}"',
        "limit": "3"
    })
    url = f"{OPENFDA_BASE}/drug/label.json?{params}"

    try:
        with urllib.request.urlopen(url, timeout=30) as resp:
            data = json.loads(resp.read())
    except urllib.error.HTTPError:
        params2 = urllib.parse.urlencode({"search": query, "limit": "3"})
        url2 = f"{OPENFDA_BASE}/drug/label.json?{params2}"
        with urllib.request.urlopen(url2, timeout=30) as resp:
            data = json.loads(resp.read())

    results = data.get("results", [])

    if not results:
        print(f"未找到药品说明书 (query: {query})")
        return

    for r in results:
        openfda = r.get("openfda", {})
        brand = openfda.get("brand_name", ["N/A"])
        generic = openfda.get("generic_name", ["N/A"])

        print(f"{'='*60}")
        print(f"品牌名: {', '.join(brand) if isinstance(brand, list) else brand}")
        print(f"通用名: {', '.join(generic) if isinstance(generic, list) else generic}")

        sections = [
            ("indications_and_usage", "适应症"),
            ("dosage_and_administration", "用法用量"),
            ("warnings", "警告"),
            ("adverse_reactions", "不良反应"),
            ("contraindications", "禁忌"),
            ("drug_interactions", "药物相互作用"),
            ("mechanism_of_action", "作用机制"),
        ]

        for key, label in sections:
            val = r.get(key)
            if val:
                text = val[0] if isinstance(val, list) else val
                # Truncate long sections
                if len(text) > 500:
                    text = text[:500] + "..."
                print(f"\n[{label}]\n{text}")
        print()


# ── MeSH (Medical Subject Headings) ─────────────────────────────────

def mesh_lookup(term: str):
    """查询 MeSH 医学主题词"""
    params = urllib.parse.urlencode({
        "term": term,
        "limit": "10"
    })
    url = f"https://id.nlm.nih.gov/mesh/lookup/descriptor?label={urllib.parse.quote(term)}&match=contains&limit=10&year=current"

    req = urllib.request.Request(url)
    req.add_header("Accept", "application/json")

    with urllib.request.urlopen(req, timeout=30) as resp:
        data = json.loads(resp.read())

    if not data:
        print(f"未找到 MeSH 术语 (term: {term})")
        return

    print(f"MeSH 主题词查询结果 (term: {term}):\n")

    for item in data:
        label = item.get("label", "N/A")
        resource = item.get("resource", "")
        mesh_id = resource.split("/")[-1] if resource else "N/A"

        print(f"  {label} [{mesh_id}]")

        # Get detail for first few
        if resource:
            try:
                req2 = urllib.request.Request(resource + ".json")
                with urllib.request.urlopen(req2, timeout=15) as resp2:
                    detail = json.loads(resp2.read())

                # Scope note (definition)
                scope = detail.get("scopeNote", "")
                if scope:
                    print(f"    定义: {scope[:300]}")

                # Tree numbers
                trees = detail.get("treeNumber", [])
                if trees:
                    if isinstance(trees, str):
                        trees = [trees]
                    tree_ids = []
                    for t in trees[:5]:
                        if isinstance(t, dict):
                            uri = t.get("@id", t.get("resource", ""))
                            tree_ids.append(uri.split("/")[-1] if uri else str(t))
                        elif isinstance(t, str) and "/" in t:
                            tree_ids.append(t.split("/")[-1])
                        else:
                            tree_ids.append(str(t))
                    print(f"    树号: {', '.join(tree_ids)}")
            except Exception:
                pass
        print()


# ── Europe PMC ───────────────────────────────────────────────────────

def europmc_search(query: str, max_results: int = 10):
    """搜索 Europe PMC（欧洲 PubMed Central，含开放获取全文链接）"""
    params = urllib.parse.urlencode({
        "query": query,
        "resultType": "lite",
        "pageSize": str(max_results),
        "format": "json"
    }, quote_via=urllib.parse.quote_plus)
    url = f"https://www.ebi.ac.uk/europepmc/webservices/rest/search?{params}"

    with urllib.request.urlopen(url, timeout=30) as resp:
        data = json.loads(resp.read())

    results = data.get("resultList", {}).get("result", [])
    total = data.get("hitCount", 0)

    if not results:
        print(f"未找到相关文献 (query: {query})")
        return

    print(f"共找到 {total} 篇，显示前 {len(results)} 篇:\n")

    for r in results:
        pmid = r.get("pmid", "")
        pmcid = r.get("pmcid", "")
        title = r.get("title", "N/A")
        authors = r.get("authorString", "N/A")
        journal = r.get("journalTitle", "")
        year = r.get("pubYear", "")
        doi = r.get("doi", "")
        is_oa = r.get("isOpenAccess", "N")
        cited = r.get("citedByCount", 0)

        id_str = f"PMID:{pmid}" if pmid else ""
        if pmcid:
            id_str += f" | {pmcid}"

        print(f"{id_str}")
        print(f"  标题: {title}")
        if len(authors) > 80:
            authors = authors[:80] + "..."
        print(f"  作者: {authors}")
        print(f"  来源: {journal} ({year}) | 被引: {cited}")
        if doi:
            print(f"  DOI: {doi}")
        if is_oa == "Y":
            print(f"  全文: https://europepmc.org/article/MED/{pmid} [开放获取]")
        elif pmcid:
            print(f"  全文: https://europepmc.org/article/PMC/{pmcid}")
        print()


# ── RxNorm (NLM) ────────────────────────────────────────────────────

RXNORM_BASE = "https://rxnav.nlm.nih.gov/REST"

def rxnorm_lookup(drug_name: str):
    """RxNorm 药品标准化名称查询"""
    # Step 1: 查找 RxCUI
    url = f"{RXNORM_BASE}/rxcui.json?name={urllib.parse.quote(drug_name)}&search=2"
    with urllib.request.urlopen(url, timeout=30) as resp:
        data = json.loads(resp.read())

    id_group = data.get("idGroup", {})
    rxcui_list = id_group.get("rxnormId", [])

    if not rxcui_list:
        # 尝试近似搜索
        url2 = f"{RXNORM_BASE}/approximateTerm.json?term={urllib.parse.quote(drug_name)}&maxEntries=5"
        with urllib.request.urlopen(url2, timeout=30) as resp2:
            data2 = json.loads(resp2.read())
        candidates = data2.get("approximateGroup", {}).get("candidate", [])
        if not candidates:
            print(f"未找到药品 (drug: {drug_name})")
            return
        print(f"未精确匹配，近似结果:\n")
        for c in candidates[:5]:
            rxcui = c.get("rxcui", "")
            score = c.get("score", "")
            rank = c.get("rank", "")
            # Get name
            name_url = f"{RXNORM_BASE}/rxcui/{rxcui}/properties.json"
            try:
                with urllib.request.urlopen(name_url, timeout=15) as resp3:
                    props = json.loads(resp3.read())
                name = props.get("properties", {}).get("name", "N/A")
                tty = props.get("properties", {}).get("tty", "")
            except Exception:
                name = f"RxCUI:{rxcui}"
                tty = ""
            print(f"  RxCUI: {rxcui} | {name} [{tty}] (score: {score})")
        return

    for rxcui in rxcui_list[:3]:
        print(f"{'='*60}")
        # Properties
        prop_url = f"{RXNORM_BASE}/rxcui/{rxcui}/properties.json"
        with urllib.request.urlopen(prop_url, timeout=15) as resp:
            props = json.loads(resp.read()).get("properties", {})

        print(f"RxCUI: {rxcui}")
        print(f"名称: {props.get('name', 'N/A')}")
        print(f"类型: {props.get('tty', 'N/A')} ({props.get('rxnormDoseForm', '')})")
        print(f"状态: {props.get('active', 'N/A')}")

        # Related concepts (brands, ingredients, dose forms)
        related_url = f"{RXNORM_BASE}/rxcui/{rxcui}/related.json?tty=BN+IN+SBD+SCD"
        try:
            with urllib.request.urlopen(related_url, timeout=15) as resp:
                related = json.loads(resp.read())
            groups = related.get("relatedGroup", {}).get("conceptGroup", [])
            for g in groups:
                tty = g.get("tty", "")
                concepts = g.get("conceptProperties", [])
                if concepts:
                    names = [c.get("name", "") for c in concepts[:5]]
                    label_map = {"BN": "品牌名", "IN": "活性成分", "SBD": "品牌剂型", "SCD": "临床剂型"}
                    print(f"  {label_map.get(tty, tty)}: {'; '.join(names)}")
        except Exception:
            pass

        # NDC codes
        ndc_url = f"{RXNORM_BASE}/rxcui/{rxcui}/ndcs.json"
        try:
            with urllib.request.urlopen(ndc_url, timeout=15) as resp:
                ndc_data = json.loads(resp.read())
            ndcs = ndc_data.get("ndcGroup", {}).get("ndcList", {}).get("ndc", [])
            if ndcs:
                print(f"  NDC编码: {', '.join(ndcs[:5])}{'...' if len(ndcs) > 5 else ''}")
        except Exception:
            pass
        print()


# ── DailyMed (NLM/NIH) ──────────────────────────────────────────────

DAILYMED_BASE = "https://dailymed.nlm.nih.gov/dailymed/services/v2"

def dailymed_search(query: str, max_results: int = 10):
    """搜索 DailyMed 药品说明书（SPL）"""
    params = urllib.parse.urlencode({
        "drug_name": query,
        "pagesize": str(max_results),
        "page": "1"
    })
    url = f"{DAILYMED_BASE}/spls.json?{params}"

    with urllib.request.urlopen(url, timeout=30) as resp:
        data = json.loads(resp.read())

    results = data.get("data", [])
    metadata = data.get("metadata", {})
    total = metadata.get("total_elements", 0)

    if not results:
        print(f"未找到药品说明书 (query: {query})")
        return

    print(f"共找到 {total} 份说明书，显示前 {len(results)} 份:\n")

    for r in results:
        setid = r.get("setid", "")
        title = r.get("title", "N/A")
        published = r.get("published_date", "N/A")

        # Products info
        products = r.get("products", [])

        print(f"SetID: {setid}")
        print(f"  标题: {title[:120]}")
        print(f"  发布: {published}")
        for p in products[:2]:
            name = p.get("name", "")
            route = p.get("route", "")
            active = [i.get("name", "") for i in p.get("active_ingredients", [])]
            print(f"  产品: {name} | 途径: {route}")
            if active:
                print(f"  成分: {', '.join(active)}")
        print(f"  链接: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid={setid}")
        print()


# ── UMLS (Unified Medical Language System) ───────────────────────────

UMLS_BASE = "https://uts-ws.nlm.nih.gov/rest"

def umls_search(term: str):
    """UMLS 概念查询（需要 API Key）"""
    api_key = _get_key("umls")
    if not api_key:
        print("UMLS 需要 API Key。")
        print("注册（免费）: https://uts.nlm.nih.gov/uts/")
        print("获取后添加到 ~/ai/data/keys/api-keys.json:")
        print('  "umls": {"key": "YOUR_KEY", "base": "https://uts-ws.nlm.nih.gov/rest", "备注": "UMLS, 免费注册"}')
        return

    params = urllib.parse.urlencode({
        "string": term,
        "apiKey": api_key,
        "pageSize": "10",
        "searchType": "words"
    })
    url = f"{UMLS_BASE}/search/current?{params}"

    with urllib.request.urlopen(url, timeout=30) as resp:
        data = json.loads(resp.read())

    results_data = data.get("result", {}).get("results", [])

    if not results_data:
        print(f"未找到 UMLS 概念 (term: {term})")
        return

    print(f"UMLS 概念查询结果 (term: {term}):\n")

    for r in results_data[:10]:
        cui = r.get("ui", "N/A")
        name = r.get("name", "N/A")
        root_source = r.get("rootSource", "")

        print(f"  CUI: {cui} | {name}")
        if root_source:
            print(f"    来源: {root_source}")

        # Get concept details
        if cui != "NONE":
            detail_url = f"{UMLS_BASE}/content/current/CUI/{cui}?apiKey={api_key}"
            try:
                with urllib.request.urlopen(detail_url, timeout=15) as resp:
                    detail = json.loads(resp.read())
                result = detail.get("result", {})
                sem_types = result.get("semanticTypes", [])
                if sem_types:
                    types_str = ", ".join([s.get("name", "") for s in sem_types])
                    print(f"    语义类型: {types_str}")
                atom_count = result.get("atomCount", "")
                if atom_count:
                    print(f"    原子数: {atom_count}")
            except Exception:
                pass
        print()


# ── DrugBank 本地查询 ─────────────────────────────────────────────────

DRUGBANK_DB = os.path.join(os.path.dirname(os.path.abspath(__file__)), "drugbank", "drugbank.db")

def drugbank_search(query: str):
    """DrugBank 本地药物查询（19830种药物，71857条名称索引）"""
    if not os.path.exists(DRUGBANK_DB):
        print(f"DrugBank 数据库未找到: {DRUGBANK_DB}")
        print("运行 python3 ~/ai/data/medical/drugbank/build_db.py 建库")
        return

    conn = sqlite3.connect(DRUGBANK_DB)
    c = conn.cursor()
    q_lower = query.lower().strip()

    # 精确匹配 DrugBank ID
    if q_lower.startswith("db") and len(q_lower) >= 7:
        c.execute("SELECT * FROM drugs WHERE drugbank_id = ? COLLATE NOCASE", (query,))
        rows = c.fetchall()
        if rows:
            _print_drugbank_results(rows)
            conn.close()
            return

    # 精确匹配 CAS 号
    if any(ch == '-' for ch in query) and any(ch.isdigit() for ch in query):
        c.execute("SELECT * FROM drugs WHERE cas = ?", (query,))
        rows = c.fetchall()
        if rows:
            _print_drugbank_results(rows)
            conn.close()
            return

    # 名称精确匹配
    c.execute("""
        SELECT DISTINCT d.* FROM drugs d
        JOIN drug_names n ON d.drugbank_id = n.drugbank_id
        WHERE n.name = ?
    """, (q_lower,))
    rows = c.fetchall()

    if not rows:
        # 模糊匹配
        c.execute("""
            SELECT DISTINCT d.* FROM drugs d
            JOIN drug_names n ON d.drugbank_id = n.drugbank_id
            WHERE n.name LIKE ?
            LIMIT 20
        """, (f"%{q_lower}%",))
        rows = c.fetchall()

    if not rows:
        # common_name 模糊
        c.execute("""
            SELECT * FROM drugs WHERE common_name LIKE ? COLLATE NOCASE LIMIT 20
        """, (f"%{query}%",))
        rows = c.fetchall()

    if not rows:
        print(f"未找到药物 (query: {query})")
        conn.close()
        return

    _print_drugbank_results(rows)
    conn.close()


def _print_drugbank_results(rows):
    print(f"找到 {len(rows)} 种药物:\n")
    for row in rows[:10]:
        dbid, accession, name, cas, unii, synonyms, inchikey = row
        print(f"DrugBank ID: {dbid}")
        print(f"  名称: {name}")
        if cas:
            print(f"  CAS: {cas}")
        if unii:
            print(f"  UNII: {unii}")
        if inchikey:
            print(f"  InChIKey: {inchikey}")
        if synonyms:
            syns = synonyms.split(" | ")
            display = syns[:5]
            extra = f" (+{len(syns)-5})" if len(syns) > 5 else ""
            print(f"  同义词: {' | '.join(display)}{extra}")
        print(f"  详情: https://go.drugbank.com/drugs/{dbid}")
        print()


# ── CLI Entry Point ──────────────────────────────────────────────────

USAGE = """
医学数据库查询工具 (medtools.py)

用法:
  python3 medtools.py pubmed <query> [--max N]           PubMed 文献搜索
  python3 medtools.py pubmed-detail <pmid>               PubMed 单篇详情
  python3 medtools.py europmc <query> [--max N]          Europe PMC（含OA全文）
  python3 medtools.py trials <query> [--max N]           ClinicalTrials.gov
  python3 medtools.py trial-detail <nctid>               单个试验详情
  python3 medtools.py openfda-drug <query>               FDA 药品信息
  python3 medtools.py openfda-adverse <drug> [--max N]   FDA 不良反应
  python3 medtools.py openfda-label <query>              FDA 药品说明书
  python3 medtools.py dailymed <query> [--max N]         DailyMed 说明书
  python3 medtools.py rxnorm <drug_name>                 RxNorm 标准化名称
  python3 medtools.py mesh <term>                        MeSH 主题词
  python3 medtools.py umls <term>                        UMLS 概念（需Key）

示例:
  python3 medtools.py pubmed "femoroacetabular impingement treatment"
  python3 medtools.py pubmed-detail 14646708
  python3 medtools.py europmc "hip labral tear rehabilitation"
  python3 medtools.py trials "femoroacetabular impingement"
  python3 medtools.py openfda-adverse ibuprofen --max 20
  python3 medtools.py dailymed celecoxib
  python3 medtools.py rxnorm ibuprofen
  python3 medtools.py drugbank ibuprofen
  python3 medtools.py drugbank DB00945
  python3 medtools.py umls "osteoarthritis"
""".strip()

def main():
    if len(sys.argv) < 2:
        print(USAGE)
        sys.exit(0)

    cmd = sys.argv[1]

    # Parse --max flag
    max_results = 10
    args = sys.argv[2:]
    filtered_args = []
    i = 0
    while i < len(args):
        if args[i] == "--max" and i + 1 < len(args):
            max_results = int(args[i + 1])
            i += 2
        else:
            filtered_args.append(args[i])
            i += 1

    query = " ".join(filtered_args) if filtered_args else ""

    try:
        if cmd == "pubmed":
            if not query:
                print("Error: 需要搜索词"); sys.exit(1)
            pubmed_search(query, max_results)

        elif cmd == "pubmed-detail":
            if not query:
                print("Error: 需要 PMID"); sys.exit(1)
            pubmed_detail(query)

        elif cmd == "trials":
            if not query:
                print("Error: 需要搜索词"); sys.exit(1)
            trials_search(query, max_results)

        elif cmd == "trial-detail":
            if not query:
                print("Error: 需要 NCT ID"); sys.exit(1)
            trial_detail(query)

        elif cmd == "openfda-drug":
            if not query:
                print("Error: 需要药品名"); sys.exit(1)
            openfda_drug(query)

        elif cmd == "openfda-adverse":
            if not query:
                print("Error: 需要药品名"); sys.exit(1)
            openfda_adverse(query, max_results)

        elif cmd == "openfda-label":
            if not query:
                print("Error: 需要药品名"); sys.exit(1)
            openfda_label(query)

        elif cmd == "europmc":
            if not query:
                print("Error: 需要搜索词"); sys.exit(1)
            europmc_search(query, max_results)

        elif cmd == "dailymed":
            if not query:
                print("Error: 需要药品名"); sys.exit(1)
            dailymed_search(query, max_results)

        elif cmd == "rxnorm":
            if not query:
                print("Error: 需要药品名"); sys.exit(1)
            rxnorm_lookup(query)

        elif cmd == "mesh":
            if not query:
                print("Error: 需要术语"); sys.exit(1)
            mesh_lookup(query)

        elif cmd == "drugbank":
            if not query:
                print("Error: 需要药品名或 DrugBank ID"); sys.exit(1)
            drugbank_search(query)

        elif cmd == "umls":
            if not query:
                print("Error: 需要术语"); sys.exit(1)
            umls_search(query)

        else:
            print(f"未知命令: {cmd}\n")
            print(USAGE)
            sys.exit(1)

    except urllib.error.HTTPError as e:
        print(f"HTTP 错误 {e.code}: {e.reason}")
        try:
            err_body = e.read().decode()[:500]
            print(f"详情: {err_body}")
        except Exception:
            pass
        sys.exit(1)
    except urllib.error.URLError as e:
        print(f"网络错误: {e.reason}")
        sys.exit(1)
    except json.JSONDecodeError:
        print("返回数据解析失败")
        sys.exit(1)

if __name__ == "__main__":
    main()
