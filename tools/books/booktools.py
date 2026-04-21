#!/usr/bin/env python3
"""
图书搜索工具集
用法: python3 booktools.py <command> [args...]

Commands:
  douban <query>                       豆瓣图书搜索（书名/作者）
  douban-detail <subject_id>           豆瓣图书详情（评分、ISBN、简介）
  anna <query> [--ext epub/pdf] [--lang zh/en] [--max N]
                                       Anna's Archive 电子书搜索
  anna-detail <md5>                    Anna's Archive 电子书详情

环境: 纯 Python 3，无需第三方依赖
"""

import os
import sys
import json
import re
import ssl
import urllib.request
import urllib.parse
import html as html_module

# macOS Python SSL 证书修复
if not os.environ.get("SSL_CERT_FILE"):
    for cert_path in ["/etc/ssl/cert.pem", "/etc/ssl/certs/ca-certificates.crt"]:
        if os.path.exists(cert_path):
            os.environ["SSL_CERT_FILE"] = cert_path
            break

# Anna's Archive 域名（按优先级排列，域名可能变化）
ANNA_DOMAINS = ["annas-archive.gl", "annas-archive.pm", "annas-archive.li"]

UA = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"


def _fetch(url: str, headers: dict = None, timeout: int = 15) -> str:
    hdrs = {"User-Agent": UA}
    if headers:
        hdrs.update(headers)
    req = urllib.request.Request(url, headers=hdrs)
    ctx = ssl.create_default_context()
    with urllib.request.urlopen(req, timeout=timeout, context=ctx) as resp:
        return resp.read().decode("utf-8", errors="replace")


def _fetch_json(url: str, headers: dict = None) -> dict:
    return json.loads(_fetch(url, headers))


# ── 豆瓣 ──────────────────────────────────────────────────────────────

def douban_search(query: str):
    """豆瓣图书搜索（suggest API，返回简要信息）"""
    url = f"https://book.douban.com/j/subject_suggest?q={urllib.parse.quote(query)}"
    results = _fetch_json(url)
    if not results:
        print("未找到结果")
        return
    for r in results:
        if r.get("type") != "b":
            continue
        print(f"  ID: {r.get('id', 'N/A')}")
        print(f"  书名: {r.get('title', 'N/A')}")
        print(f"  作者: {r.get('author_name', 'N/A')}")
        print(f"  年份: {r.get('year', 'N/A')}")
        print(f"  豆瓣: https://book.douban.com/subject/{r.get('id')}/")
        print()


def douban_detail(subject_id: str):
    """豆瓣图书详情（从网页解析）"""
    url = f"https://book.douban.com/subject/{subject_id}/"
    page = _fetch(url)

    # 书名
    m = re.search(r'<title>([^<]+)', page)
    title = m.group(1).strip().replace(" (豆瓣)", "") if m else "N/A"
    print(f"  书名: {title}")

    # 评分
    m = re.search(r'property="v:average"[^>]*>([^<]+)', page)
    rating = m.group(1).strip() if m else "N/A"
    m2 = re.search(r'property="v:votes"[^>]*>([^<]+)', page)
    votes = m2.group(1).strip() if m2 else ""
    print(f"  评分: {rating}" + (f" ({votes}人评价)" if votes else ""))

    # 信息块（作者、出版社、ISBN等）
    m = re.search(r'id="info"[^>]*>(.*?)</div>', page, re.DOTALL)
    if m:
        info_text = re.sub(r'<br\s*/?>', '\n', m.group(1))
        info_text = re.sub(r'<[^>]+>', '', info_text)
        info_text = html_module.unescape(info_text)
        for line in info_text.strip().split('\n'):
            line = line.strip()
            if line and ':' in line:
                print(f"  {line}")

    # 简介
    m = re.search(r'class="intro"[^>]*>(.*?)</div>', page, re.DOTALL)
    if m:
        intro = re.sub(r'<[^>]+>', '', m.group(1)).strip()
        intro = html_module.unescape(intro)
        if intro and len(intro) > 10:
            print(f"\n  简介: {intro[:300]}{'...' if len(intro) > 300 else ''}")

    print(f"\n  豆瓣: {url}")


# ── Anna's Archive ────────────────────────────────────────────────────

def _anna_base() -> str:
    """尝试找到可用的 Anna's Archive 域名"""
    for domain in ANNA_DOMAINS:
        try:
            url = f"https://{domain}/"
            req = urllib.request.Request(url, headers={"User-Agent": UA}, method="HEAD")
            ctx = ssl.create_default_context()
            with urllib.request.urlopen(req, timeout=8, context=ctx) as resp:
                if resp.status == 200:
                    return f"https://{domain}"
        except Exception:
            continue
    # 默认回退
    return f"https://{ANNA_DOMAINS[0]}"


def anna_search(query: str, ext: str = "", lang: str = "", max_results: int = 10, content: str = ""):
    """Anna's Archive 搜索（提取 md5 链接 + 详情）"""
    base = _anna_base()
    params = {"q": query}
    if ext:
        params["ext"] = ext
    if lang:
        params["lang"] = lang
    if content:
        params["content"] = content
    url = f"{base}/search?{urllib.parse.urlencode(params)}"

    page = _fetch(url, timeout=20)

    # 提取所有 md5 链接（去重，保持顺序）
    md5s = []
    seen = set()
    for m in re.finditer(r'href="/md5/([a-f0-9]{32})"', page):
        md5 = m.group(1)
        if md5 not in seen:
            seen.add(md5)
            md5s.append(md5)

    if not md5s:
        print("未找到结果")
        return

    md5s = md5s[:max_results]
    print(f"找到 {len(seen)} 个结果，显示前 {len(md5s)} 个:\n")

    for i, md5 in enumerate(md5s, 1):
        try:
            detail_url = f"{base}/md5/{md5}"
            detail_page = _fetch(detail_url, timeout=15)

            # 标题
            t = re.search(r'<title>([^<]+)', detail_page)
            title = t.group(1).strip().replace(" - Anna's Archive", "") if t else md5

            # 描述（作者等）
            d = re.search(r'meta name="description" content="([^"]+)', detail_page)
            desc = d.group(1).strip() if d else ""

            # 文件信息
            files = re.findall(r'(epub|pdf|mobi|azw3|djvu|cbr|cbz)\b.*?(\d+(?:\.\d+)?\s*[MKG]B)', detail_page, re.I)
            file_info = ", ".join(f"{f[0].upper()} {f[1]}" for f in files[:3]) if files else "N/A"

            print(f"  [{i}] {title}")
            if desc and desc != title:
                print(f"      作者: {desc[:100]}")
            print(f"      格式: {file_info}")
            print(f"      链接: {detail_url}")
            print()
        except Exception as e:
            print(f"  [{i}] MD5: {md5} (获取详情失败: {e})")
            print(f"      链接: {base}/md5/{md5}")
            print()


def anna_detail(md5: str):
    """Anna's Archive 电子书详情"""
    base = _anna_base()
    url = f"{base}/md5/{md5}"
    page = _fetch(url, timeout=15)

    # 标题
    t = re.search(r'<title>([^<]+)', page)
    title = t.group(1).strip().replace(" - Anna's Archive", "") if t else "N/A"
    print(f"  书名: {title}")

    # 描述
    d = re.search(r'meta name="description" content="([^"]+)', page)
    if d:
        desc = html_module.unescape(d.group(1).strip())
        print(f"  描述: {desc[:500]}")

    # 文件信息
    files = re.findall(r'(epub|pdf|mobi|azw3|djvu|cbr|cbz)\b.*?(\d+(?:\.\d+)?\s*[MKG]B)', page, re.I)
    if files:
        print(f"  文件: {', '.join(f'{f[0].upper()} {f[1]}' for f in files[:5])}")

    # ISBN
    isbns = set(re.findall(r'\b(97[89]\d{10})\b', page))
    if isbns:
        print(f"  ISBN: {', '.join(isbns)}")

    print(f"\n  链接: {url}")


# ── CLI ───────────────────────────────────────────────────────────────

def main():
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)

    cmd = sys.argv[1]
    args = sys.argv[2:]

    # 解析 --max, --ext, --lang, --content
    max_results = 10
    ext = ""
    lang = ""
    content = ""
    positional = []
    i = 0
    while i < len(args):
        if args[i] == "--max" and i + 1 < len(args):
            max_results = int(args[i + 1])
            i += 2
        elif args[i] == "--ext" and i + 1 < len(args):
            ext = args[i + 1]
            i += 2
        elif args[i] == "--lang" and i + 1 < len(args):
            lang = args[i + 1]
            i += 2
        elif args[i] == "--content" and i + 1 < len(args):
            content = args[i + 1]
            i += 2
        else:
            positional.append(args[i])
            i += 1

    query = " ".join(positional)

    if cmd == "douban":
        if not query:
            print("用法: booktools.py douban <书名/作者>")
            sys.exit(1)
        douban_search(query)
    elif cmd == "douban-detail":
        if not query:
            print("用法: booktools.py douban-detail <subject_id>")
            sys.exit(1)
        douban_detail(query)
    elif cmd == "anna":
        if not query:
            print("用法: booktools.py anna <书名/作者> [--ext epub/pdf] [--lang zh] [--max N]")
            sys.exit(1)
        anna_search(query, ext=ext, lang=lang, max_results=max_results, content=content)
    elif cmd == "anna-detail":
        if not query:
            print("用法: booktools.py anna-detail <md5>")
            sys.exit(1)
        anna_detail(query)
    else:
        print(f"未知命令: {cmd}")
        print(__doc__)
        sys.exit(1)


if __name__ == "__main__":
    main()
