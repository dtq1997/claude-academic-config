#!/usr/bin/env python3
"""
12306 余票查询工具 — 使用 12306 公开查询接口（不需要登录）。

[Claude] 2026-03-10

用法:
    python3 train_search.py "北京" "上海" --date 2026-03-15
    python3 train_search.py "北京" "杭州" --type G --json
    python3 train_search.py "上海" "南京"

车型: all(全部), G(高铁), D(动车), K(快速), Z(直达)

注意: 12306 有公开余票查询 API，不需要 Chrome CDP。
"""

import sys, os, json, re, argparse, ssl, certifi
from datetime import datetime, timedelta

# macOS Python SSL fix
_SSL_CTX = ssl.create_default_context(cafile=certifi.where())

# 常用站点电报码（查票用）
STATION_MAP = {}  # 会在首次运行时从 12306 加载


def _load_stations():
    """加载站点编码映射"""
    global STATION_MAP
    if STATION_MAP:
        return

    cache_file = os.path.join(os.path.dirname(__file__), '_station_cache.json')

    # 尝试缓存
    if os.path.exists(cache_file):
        try:
            with open(cache_file) as f:
                STATION_MAP = json.load(f)
            if STATION_MAP:
                return
        except Exception:
            pass

    # 从 12306 下载
    try:
        import urllib.request
        url = "https://kyfw.12306.cn/otn/resources/js/framework/station_name.js"
        req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
        resp = urllib.request.urlopen(req, timeout=10, context=_SSL_CTX)
        text = resp.read().decode('utf-8')

        # 格式: @bjb|北京北|VAP|beijingbei|bjb|0|...
        for item in text.split('@')[1:]:
            parts = item.split('|')
            if len(parts) >= 4:
                name = parts[1]
                code = parts[2]
                STATION_MAP[name] = code

        # 保存缓存
        with open(cache_file, 'w') as f:
            json.dump(STATION_MAP, f, ensure_ascii=False)

    except Exception as e:
        print(f"警告: 无法加载站点数据: {e}", file=sys.stderr)
        # 硬编码常用站
        STATION_MAP.update({
            '北京': 'BJP', '北京南': 'VNP', '北京西': 'BXP', '北京北': 'VAP',
            '上海': 'SHH', '上海虹桥': 'AOH', '南京': 'NJH', '南京南': 'NKH',
            '杭州': 'HZH', '杭州东': 'HGH', '广州': 'GZQ', '广州南': 'IZQ',
            '深圳': 'SZQ', '深圳北': 'IOQ', '成都': 'CDW', '成都东': 'ICW',
            '武汉': 'WHN', '西安': 'XAY', '西安北': 'EAY', '天津': 'TJP',
            '重庆': 'CQW', '长沙': 'CSQ', '长沙南': 'CWQ',
        })


def _get_station_code(name):
    """获取站点电报码"""
    _load_stations()
    # 精确匹配
    if name in STATION_MAP:
        return STATION_MAP[name]
    # 模糊匹配
    for sname, code in STATION_MAP.items():
        if name in sname:
            return code
    return None


def search_trains(from_city, to_city, date=None, train_type='all'):
    """查询余票"""
    import urllib.request

    if not date:
        date = (datetime.now() + timedelta(days=1)).strftime('%Y-%m-%d')

    from_code = _get_station_code(from_city)
    to_code = _get_station_code(to_city)

    if not from_code:
        print(f"错误: 未找到站点 '{from_city}'", file=sys.stderr)
        return []
    if not to_code:
        print(f"错误: 未找到站点 '{to_city}'", file=sys.stderr)
        return []

    url = (f"https://kyfw.12306.cn/otn/leftTicketPrice/queryAllPublicPrice?"
           f"leftTicketDTO.train_date={date}"
           f"&leftTicketDTO.from_station={from_code}"
           f"&leftTicketDTO.to_station={to_code}"
           f"&purpose_codes=ADULT")

    try:
        req = urllib.request.Request(url, headers={
            'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)',
            'Accept': 'application/json',
        })

        # 通过环境变量中的代理设置，不走代理直连 12306
        proxy_handler = urllib.request.ProxyHandler({})
        https_handler = urllib.request.HTTPSHandler(context=_SSL_CTX)
        opener = urllib.request.build_opener(proxy_handler, https_handler)
        resp = opener.open(req, timeout=15)
        data = json.loads(resp.read().decode('utf-8'))

    except Exception as e:
        print(f"查询失败: {e}", file=sys.stderr)
        return []

    if data.get('status') is not True:
        print(f"12306 返回错误: {data.get('messages', '未知错误')}", file=sys.stderr)
        return []

    results = []
    raw_list = data.get('data', [])
    if isinstance(raw_list, dict):
        raw_list = raw_list.get('ticket', raw_list.get('result', []))

    for item in raw_list:
        dto = item.get('queryLeftNewDTO', item) if isinstance(item, dict) else {}
        train_no = dto.get('station_train_code', '')

        # 车型过滤
        if train_type != 'all' and not train_no.startswith(train_type):
            continue

        result = {
            'train_no': train_no,
            'from_station': dto.get('from_station_name', ''),
            'to_station': dto.get('to_station_name', ''),
            'departure': dto.get('start_time', ''),
            'arrival': dto.get('arrive_time', ''),
            'duration': dto.get('lishi', ''),
        }

        # 票价（单位：分，需除100）
        price_fields = {
            'swz_price': '商务座', 'zy_price': '一等座', 'ze_price': '二等座',
            'rw_price': '软卧', 'yw_price': '硬卧', 'yz_price': '硬座',
            'wz_price': '无座',
        }
        for field, name in price_fields.items():
            val = dto.get(field, '')
            if val and val != '0' and val != '':
                try:
                    yuan = int(val) / 100
                    result[name] = f"¥{yuan:.0f}"
                except (ValueError, TypeError):
                    pass

        results.append(result)

    return results


def main():
    parser = argparse.ArgumentParser(description='12306 余票查询')
    parser.add_argument('from_city', help='出发城市/站点')
    parser.add_argument('to_city', help='到达城市/站点')
    parser.add_argument('--date', help='出发日期 (YYYY-MM-DD)，默认明天')
    parser.add_argument('--type', default='all', choices=['all', 'G', 'D', 'K', 'Z'],
                        help='车型 (默认: all)')
    parser.add_argument('--max', type=int, default=30, help='最大结果数')
    parser.add_argument('--json', action='store_true', help='输出 JSON 格式')
    args = parser.parse_args()

    results = search_trains(args.from_city, args.to_city, args.date, args.type)

    if args.max:
        results = results[:args.max]

    if args.json:
        print(json.dumps(results, ensure_ascii=False, indent=2))
    else:
        if not results:
            print(f"未找到 {args.from_city} → {args.to_city} 的车次")
            return

        date_str = args.date or (datetime.now() + timedelta(days=1)).strftime('%Y-%m-%d')
        print(f"\n{args.from_city} → {args.to_city}  {date_str} — 共 {len(results)} 个车次\n")
        print(f"{'车次':<10} {'出发':>6} {'到达':>6} {'历时':>6} {'票价信息'}")
        print('-' * 70)
        for r in results:
            train = r['train_no']
            dep = r.get('departure', '-')
            arr = r.get('arrival', '-')
            dur = r.get('duration', '-')
            # 收集所有票价
            prices = []
            for k, v in r.items():
                if k not in ('train_no', 'from_station', 'to_station',
                             'departure', 'arrival', 'duration') and v:
                    prices.append(f"{k}{v}")
            price_str = ' '.join(prices[:4])
            print(f"{train:<10} {dep:>6} {arr:>6} {dur:>6} {price_str}")


if __name__ == '__main__':
    main()
