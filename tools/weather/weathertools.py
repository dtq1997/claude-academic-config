#!/usr/bin/env python3
"""
天气查询工具 - 全中国内地覆盖
数据源：Open-Meteo（免费无Key）+ 高德地理编码（转坐标）
用法：python3 weathertools.py <命令> <城市> [参数]

命令：
  now       <城市>                    实况天气（当前小时）
  forecast  <城市> [天数]             未来N天预报（默认7天，最多16天）
  hourly    <城市> [小时数]           逐小时预报（默认48小时）
  history   <城市> <起始日期> [结束日期]  历史天气（日级）
  aqi       <城市>                    空气质量（实时+48h预报）
  travel    <城市> <起始日期> <结束日期>  出行综合评估
  compare   <城市> <月-日> [年份数]    历年同期对比（默认近3年）

日期格式：YYYY-MM-DD

示例：
  python3 weathertools.py now 北京
  python3 weathertools.py forecast 上海 10
  python3 weathertools.py history 北京 2025-04-02 2025-04-06
  python3 weathertools.py travel 北京 2026-04-02 2026-04-06
  python3 weathertools.py compare 北京 04-02 5
  python3 weathertools.py aqi 成都
"""

import json
import os
import sys
import ssl
import urllib.request
import urllib.parse
from datetime import datetime, timedelta

# ─── 配置 ───────────────────────────────────────────────────

KEYS_FILE = os.path.expanduser("~/ai/data/keys/api-keys.json")
CACHE_FILE = os.path.expanduser("~/ai/data/weather/.geocache.json")

OPEN_METEO_FORECAST = "https://api.open-meteo.com/v1/forecast"
OPEN_METEO_HISTORY = "https://archive-api.open-meteo.com/v1/archive"
OPEN_METEO_AQI = "https://air-quality-api.open-meteo.com/v1/air-quality"
AMAP_GEOCODE = "https://restapi.amap.com/v3/geocode/geo"

# 常用城市坐标缓存（减少 API 调用）
BUILTIN_CITIES = {
    "北京": (39.9042, 116.4074),
    "上海": (31.2304, 121.4737),
    "广州": (23.1291, 113.2644),
    "深圳": (22.5431, 114.0579),
    "成都": (30.5728, 104.0668),
    "杭州": (30.2741, 120.1551),
    "重庆": (29.5630, 106.5516),
    "武汉": (30.5928, 114.3055),
    "西安": (34.3416, 108.9398),
    "南京": (32.0603, 118.7969),
    "天津": (39.0842, 117.2010),
    "苏州": (31.2990, 120.5853),
    "长沙": (28.2282, 112.9388),
    "郑州": (34.7466, 113.6254),
    "青岛": (36.0671, 120.3826),
    "大连": (38.9140, 121.6147),
    "哈尔滨": (45.8038, 126.5350),
    "沈阳": (41.8057, 123.4315),
    "昆明": (25.0389, 102.7183),
    "三亚": (18.2528, 109.5120),
    "厦门": (24.4798, 118.0894),
    "珠海": (22.2710, 113.5767),
    "海口": (20.0174, 110.3492),
    "贵阳": (26.6470, 106.6302),
    "太原": (37.8706, 112.5489),
    "拉萨": (29.6500, 91.1000),
    "乌鲁木齐": (43.8256, 87.6168),
    "呼和浩特": (40.8414, 111.7519),
    "兰州": (36.0611, 103.8343),
    "银川": (38.4872, 106.2309),
    "西宁": (36.6171, 101.7782),
    "南宁": (22.8170, 108.3665),
    "合肥": (31.8206, 117.2272),
    "福州": (26.0745, 119.2965),
    "南昌": (28.6820, 115.8579),
    "济南": (36.6512, 117.1201),
    "石家庄": (38.0428, 114.5149),
    "长春": (43.8171, 125.3235),
    "威海": (37.5128, 122.1205),
    "秦皇岛": (39.9354, 119.5977),
    "延庆": (40.4567, 115.9850),
    "密云": (40.3769, 116.8430),
    "通州": (39.9021, 116.6562),
    "顺义": (40.1302, 116.6543),
    "怀柔": (40.3161, 116.6319),
    "丰台": (39.8585, 116.2870),
    "朝阳": (39.9219, 116.4435),
    "海淀": (39.9593, 116.2984),
}

# UV 指数等级
UV_LEVELS = [
    (2, "低", "无需防护"),
    (5, "中等", "建议涂防晒霜"),
    (7, "高", "必须防晒，减少户外暴露"),
    (10, "很高", "尽量避免户外活动"),
    (99, "极高", "禁止户外暴露"),
]

# 体感舒适度
COMFORT_LEVELS = [
    (-10, "极寒", "❄️"),
    (0, "严寒", "🥶"),
    (10, "寒冷", "🧥"),
    (15, "凉爽", "🧣"),
    (20, "舒适偏凉", "👍"),
    (25, "舒适", "😊"),
    (30, "温热", "☀️"),
    (35, "炎热", "🥵"),
    (40, "酷热", "🔥"),
    (99, "极端高温", "⚠️"),
]

# AQI 等级（US EPA 标准）
AQI_LEVELS = [
    (50, "优", "空气质量令人满意"),
    (100, "良", "可接受，敏感人群应减少户外"),
    (150, "轻度污染", "敏感人群有健康影响"),
    (200, "中度污染", "所有人群开始受影响"),
    (300, "重度污染", "健康警报，所有人受影响"),
    (999, "严重污染", "紧急状况，避免外出"),
]

# ─── 网络请求 ─────────────────────────────────────────────

def _get_ssl_context():
    """获取 SSL context（兼容 macOS）"""
    ctx = ssl.create_default_context()
    # macOS 有时需要额外的证书路径
    cert_file = os.environ.get("NODE_EXTRA_CA_CERTS") or "/etc/ssl/cert.pem"
    if os.path.exists(cert_file):
        try:
            ctx.load_verify_locations(cert_file)
        except Exception:
            pass
    return ctx

def fetch_json(url, timeout=15):
    """请求 URL 并解析 JSON"""
    ctx = _get_ssl_context()
    req = urllib.request.Request(url, headers={"User-Agent": "weathertools/1.0"})
    try:
        with urllib.request.urlopen(req, timeout=timeout, context=ctx) as resp:
            return json.loads(resp.read().decode("utf-8"))
    except urllib.error.HTTPError as e:
        body = e.read().decode("utf-8", errors="replace")[:500]
        print(f"HTTP {e.code}: {body}", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"请求失败: {e}", file=sys.stderr)
        sys.exit(1)

# ─── 地理编码 ─────────────────────────────────────────────

def load_geocache():
    if os.path.exists(CACHE_FILE):
        try:
            with open(CACHE_FILE, "r") as f:
                return json.load(f)
        except Exception:
            pass
    return {}

def save_geocache(cache):
    os.makedirs(os.path.dirname(CACHE_FILE), exist_ok=True)
    with open(CACHE_FILE, "w") as f:
        json.dump(cache, f, ensure_ascii=False, indent=2)

def geocode(city_name):
    """中文城市名 → (lat, lon)"""
    # 1. 内置缓存
    if city_name in BUILTIN_CITIES:
        return BUILTIN_CITIES[city_name]

    # 2. 文件缓存
    cache = load_geocache()
    if city_name in cache:
        return tuple(cache[city_name])

    # 3. 高德 API
    try:
        with open(KEYS_FILE, "r") as f:
            keys = json.load(f)
        amap_key = keys["amap"]["key"]
    except Exception as e:
        print(f"无法读取高德 Key: {e}", file=sys.stderr)
        sys.exit(1)

    url = f"{AMAP_GEOCODE}?key={amap_key}&address={urllib.parse.quote(city_name)}"
    data = fetch_json(url)

    if data.get("status") != "1" or not data.get("geocodes"):
        print(f"找不到城市: {city_name}", file=sys.stderr)
        sys.exit(1)

    loc = data["geocodes"][0]["location"]  # "116.407526,39.904030"
    lon, lat = loc.split(",")
    lat, lon = float(lat), float(lon)

    # 存入缓存
    cache[city_name] = [lat, lon]
    save_geocache(cache)

    return (lat, lon)

# ─── Open-Meteo 查询构建 ──────────────────────────────────

DAILY_VARS = [
    "temperature_2m_max", "temperature_2m_min",
    "apparent_temperature_max", "apparent_temperature_min",
    "precipitation_sum", "rain_sum", "snowfall_sum",
    "precipitation_hours", "precipitation_probability_max",
    "wind_speed_10m_max", "wind_gusts_10m_max", "wind_direction_10m_dominant",
    "uv_index_max", "uv_index_clear_sky_max",
    "sunrise", "sunset",
    "sunshine_duration",
]

HOURLY_VARS = [
    "temperature_2m", "relative_humidity_2m", "dew_point_2m",
    "apparent_temperature",
    "precipitation", "precipitation_probability", "rain", "snowfall",
    "cloud_cover",
    "wind_speed_10m", "wind_direction_10m", "wind_gusts_10m",
    "uv_index",
    "visibility",
    "pressure_msl", "surface_pressure",
]

HISTORY_DAILY_VARS = [
    "temperature_2m_max", "temperature_2m_min",
    "apparent_temperature_max", "apparent_temperature_min",
    "precipitation_sum", "rain_sum", "snowfall_sum",
    "wind_speed_10m_max", "wind_gusts_10m_max", "wind_direction_10m_dominant",
    "sunrise", "sunset",
    "sunshine_duration",
]

HISTORY_HOURLY_VARS = [
    "temperature_2m", "relative_humidity_2m", "dew_point_2m",
    "apparent_temperature",
    "precipitation", "rain", "snowfall",
    "cloud_cover",
    "wind_speed_10m", "wind_direction_10m", "wind_gusts_10m",
    "visibility",
    "pressure_msl",
]

AQI_HOURLY_VARS = [
    "pm10", "pm2_5",
    "carbon_monoxide", "nitrogen_dioxide", "sulphur_dioxide", "ozone",
    "us_aqi", "us_aqi_pm2_5", "us_aqi_pm10",
]

# ─── 格式化辅助 ─────────────────────────────────────────────

def wind_dir_name(deg):
    """角度 → 风向名称"""
    if deg is None:
        return "无数据"
    dirs = ["北", "东北", "东", "东南", "南", "西南", "西", "西北"]
    idx = round(deg / 45) % 8
    return dirs[idx]

def wind_level(speed_kmh):
    """风速(km/h) → 风力等级"""
    if speed_kmh is None:
        return "无数据"
    levels = [
        (1, "0级 无风"), (5, "1级 软风"), (11, "2级 轻风"),
        (19, "3级 微风"), (28, "4级 和风"), (38, "5级 劲风"),
        (49, "6级 强风"), (61, "7级 疾风"), (74, "8级 大风"),
        (88, "9级 烈风"), (102, "10级 狂风"), (117, "11级 暴风"),
        (9999, "12级+ 飓风"),
    ]
    for threshold, name in levels:
        if speed_kmh < threshold:
            return name
    return "12级+ 飓风"

def uv_desc(uv):
    if uv is None:
        return "无数据"
    for threshold, level, advice in UV_LEVELS:
        if uv <= threshold:
            return f"{uv:.1f} ({level}: {advice})"
    return f"{uv:.1f}"

def comfort_desc(temp):
    if temp is None:
        return "无数据"
    for threshold, level, emoji in COMFORT_LEVELS:
        if temp <= threshold:
            return f"{emoji} {level}"
    return "极端"

def aqi_desc(aqi_val):
    if aqi_val is None:
        return "无数据"
    for threshold, level, desc in AQI_LEVELS:
        if aqi_val <= threshold:
            return f"{int(aqi_val)} ({level}: {desc})"
    return f"{int(aqi_val)}"

def fmt_temp(t):
    return f"{t:.1f}°C" if t is not None else "-"

def fmt_pct(p):
    return f"{p:.0f}%" if p is not None else "-"

def fmt_mm(mm):
    return f"{mm:.1f}mm" if mm is not None else "-"

def fmt_km(m):
    if m is None:
        return "-"
    return f"{m/1000:.1f}km" if m >= 1000 else f"{m:.0f}m"

def safe_get(lst, idx, default=None):
    try:
        v = lst[idx]
        return v if v is not None else default
    except (IndexError, TypeError):
        return default

# ─── 命令实现 ──────────────────────────────────────────────

def cmd_now(city):
    """实况天气"""
    lat, lon = geocode(city)

    params = {
        "latitude": lat, "longitude": lon,
        "current": ",".join([
            "temperature_2m", "relative_humidity_2m", "apparent_temperature",
            "precipitation", "rain", "snowfall",
            "cloud_cover", "wind_speed_10m", "wind_direction_10m", "wind_gusts_10m",
            "pressure_msl", "surface_pressure",
            "is_day", "weather_code",
        ]),
        "daily": ",".join(DAILY_VARS[:8]),  # 今天的日级摘要
        "timezone": "Asia/Shanghai",
        "forecast_days": 1,
    }

    url = OPEN_METEO_FORECAST + "?" + urllib.parse.urlencode(params)
    data = fetch_json(url)
    c = data.get("current", {})
    d = data.get("daily", {})

    wcode = c.get("weather_code", 0)
    weather_names = {
        0: "晴", 1: "大部晴", 2: "局部多云", 3: "阴",
        45: "雾", 48: "雾凇", 51: "小毛毛雨", 53: "毛毛雨", 55: "大毛毛雨",
        56: "冻毛毛雨", 57: "强冻毛毛雨",
        61: "小雨", 63: "中雨", 65: "大雨",
        66: "冻小雨", 67: "冻大雨",
        71: "小雪", 73: "中雪", 75: "大雪", 77: "雪粒",
        80: "小阵雨", 81: "中阵雨", 82: "大阵雨",
        85: "小阵雪", 86: "大阵雪",
        95: "雷暴", 96: "雷暴+小冰雹", 99: "雷暴+大冰雹",
    }

    print(f"{'=' * 50}")
    print(f"  {city} 实况天气")
    print(f"  {c.get('time', '').replace('T', ' ')}")
    print(f"{'=' * 50}")
    print(f"  天气状况: {weather_names.get(wcode, f'代码{wcode}')}")
    print(f"  温度:     {fmt_temp(c.get('temperature_2m'))}")
    print(f"  体感温度: {fmt_temp(c.get('apparent_temperature'))}  {comfort_desc(c.get('apparent_temperature'))}")
    print(f"  湿度:     {fmt_pct(c.get('relative_humidity_2m'))}")
    print(f"  降水:     {fmt_mm(c.get('precipitation'))}")
    print(f"  云量:     {fmt_pct(c.get('cloud_cover'))}")
    print(f"  风向:     {wind_dir_name(c.get('wind_direction_10m'))}")
    print(f"  风速:     {c.get('wind_speed_10m', '-')} km/h  {wind_level(c.get('wind_speed_10m'))}")
    print(f"  阵风:     {c.get('wind_gusts_10m', '-')} km/h")
    print(f"  气压:     {c.get('pressure_msl', '-')} hPa")
    print(f"  日夜:     {'白天' if c.get('is_day') else '夜晚'}")

    if d.get("temperature_2m_max"):
        print(f"\n  今日概况:")
        print(f"  最高/最低: {fmt_temp(safe_get(d['temperature_2m_max'], 0))}/{fmt_temp(safe_get(d['temperature_2m_min'], 0))}")
        if d.get("precipitation_sum"):
            print(f"  降水总量: {fmt_mm(safe_get(d['precipitation_sum'], 0))}")
        if d.get("wind_speed_10m_max"):
            print(f"  最大风速: {safe_get(d['wind_speed_10m_max'], 0)} km/h")

def cmd_forecast(city, days=7):
    """未来N天预报"""
    lat, lon = geocode(city)
    days = min(int(days), 16)

    params = {
        "latitude": lat, "longitude": lon,
        "daily": ",".join(DAILY_VARS),
        "timezone": "Asia/Shanghai",
        "forecast_days": days,
    }

    url = OPEN_METEO_FORECAST + "?" + urllib.parse.urlencode(params)
    data = fetch_json(url)
    d = data.get("daily", {})

    dates = d.get("time", [])
    if not dates:
        print("无预报数据")
        return

    print(f"{'=' * 90}")
    print(f"  {city} 未来 {len(dates)} 天预报")
    print(f"{'=' * 90}")

    # 表头
    print(f"  {'日期':<12} {'天气':>6} {'最高':>6} {'最低':>6} {'体感高':>6} {'体感低':>6}"
          f" {'降水':>6} {'降水h':>4} {'风速':>6} {'UV':>4} {'日出':>6} {'日落':>6}")
    print(f"  {'─' * 86}")

    for i, date in enumerate(dates):
        # 用降水量推断天气
        precip = safe_get(d.get("precipitation_sum", []), i, 0)
        snow = safe_get(d.get("snowfall_sum", []), i, 0)
        rain = safe_get(d.get("rain_sum", []), i, 0)
        if snow > 0:
            weather = "🌨 雪"
        elif precip > 10:
            weather = "🌧 大雨"
        elif precip > 2:
            weather = "🌦 雨"
        elif precip > 0:
            weather = "🌂 小雨"
        else:
            weather = "☀ 晴"

        t_max = safe_get(d.get("temperature_2m_max", []), i)
        t_min = safe_get(d.get("temperature_2m_min", []), i)
        at_max = safe_get(d.get("apparent_temperature_max", []), i)
        at_min = safe_get(d.get("apparent_temperature_min", []), i)
        precip_h = safe_get(d.get("precipitation_hours", []), i, 0)
        wind_max = safe_get(d.get("wind_speed_10m_max", []), i, 0)
        uv_max = safe_get(d.get("uv_index_max", []), i, 0)
        sunrise = safe_get(d.get("sunrise", []), i, "")
        sunset = safe_get(d.get("sunset", []), i, "")

        sr = sunrise.split("T")[1][:5] if "T" in str(sunrise) else "-"
        ss = sunset.split("T")[1][:5] if "T" in str(sunset) else "-"

        # 星期
        try:
            weekday = ["一", "二", "三", "四", "五", "六", "日"][datetime.strptime(date, "%Y-%m-%d").weekday()]
        except Exception:
            weekday = "?"

        print(f"  {date} {weekday} {weather:>4}"
              f" {fmt_temp(t_max):>6} {fmt_temp(t_min):>6}"
              f" {fmt_temp(at_max):>6} {fmt_temp(at_min):>6}"
              f" {fmt_mm(precip):>6} {precip_h:>3.0f}h"
              f" {wind_max:>5.0f} {uv_max:>4.1f}"
              f" {sr:>6} {ss:>6}")

    # 汇总
    precip_days = sum(1 for p in d.get("precipitation_sum", []) if p and p > 0.1)
    avg_uv = sum(u for u in d.get("uv_index_max", []) if u) / max(len(dates), 1)
    all_temps = [t for t in d.get("temperature_2m_max", []) if t is not None] + \
                [t for t in d.get("temperature_2m_min", []) if t is not None]

    print(f"\n  摘要: {precip_days}/{len(dates)} 天有降水 | 平均UV {avg_uv:.1f} | "
          f"温度区间 {min(all_temps):.0f}~{max(all_temps):.0f}°C")

def cmd_hourly(city, hours=48):
    """逐小时预报"""
    lat, lon = geocode(city)
    hours = min(int(hours), 168)
    forecast_days = min((hours // 24) + 2, 16)

    params = {
        "latitude": lat, "longitude": lon,
        "hourly": ",".join(HOURLY_VARS),
        "timezone": "Asia/Shanghai",
        "forecast_days": forecast_days,
    }

    url = OPEN_METEO_FORECAST + "?" + urllib.parse.urlencode(params)
    data = fetch_json(url)
    h = data.get("hourly", {})

    times = h.get("time", [])[:hours]
    if not times:
        print("无数据")
        return

    print(f"{'=' * 110}")
    print(f"  {city} 逐小时预报（{len(times)}小时）")
    print(f"{'=' * 110}")
    print(f"  {'时间':<18} {'温度':>6} {'体感':>6} {'湿度':>4} {'降水':>6} {'概率':>4}"
          f" {'云量':>4} {'风速':>5} {'风向':>4} {'阵风':>5} {'UV':>4} {'能见':>7} {'气压':>7}")
    print(f"  {'─' * 106}")

    last_date = ""
    for i, t in enumerate(times):
        date_str = t.split("T")[0]
        if date_str != last_date:
            if last_date:
                print(f"  {'─' * 106}")
            last_date = date_str

        temp = safe_get(h.get("temperature_2m", []), i)
        at = safe_get(h.get("apparent_temperature", []), i)
        rh = safe_get(h.get("relative_humidity_2m", []), i)
        precip = safe_get(h.get("precipitation", []), i, 0)
        prob = safe_get(h.get("precipitation_probability", []), i)
        cloud = safe_get(h.get("cloud_cover", []), i)
        ws = safe_get(h.get("wind_speed_10m", []), i, 0)
        wd = safe_get(h.get("wind_direction_10m", []), i)
        wg = safe_get(h.get("wind_gusts_10m", []), i, 0)
        uv = safe_get(h.get("uv_index", []), i, 0)
        vis = safe_get(h.get("visibility", []), i)
        pres = safe_get(h.get("pressure_msl", []), i)

        time_short = t.replace("T", " ")

        precip_mark = f"{precip:.1f}mm" if precip > 0 else "  -  "
        prob_str = f"{prob:.0f}%" if prob is not None else "  -"

        print(f"  {time_short:<18}"
              f" {fmt_temp(temp):>6} {fmt_temp(at):>6}"
              f" {fmt_pct(rh):>4} {precip_mark:>6} {prob_str:>4}"
              f" {fmt_pct(cloud):>4}"
              f" {ws:>4.0f} {wind_dir_name(wd):>4} {wg:>4.0f}"
              f" {uv:>4.1f} {fmt_km(vis):>7}"
              f" {pres:>6.0f}" if pres else "")

def cmd_history(city, start_date, end_date=None):
    """历史天气"""
    lat, lon = geocode(city)
    if end_date is None:
        end_date = start_date

    params = {
        "latitude": lat, "longitude": lon,
        "start_date": start_date,
        "end_date": end_date,
        "daily": ",".join(HISTORY_DAILY_VARS),
        "hourly": "temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,cloud_cover,wind_speed_10m,visibility",
        "timezone": "Asia/Shanghai",
    }

    url = OPEN_METEO_HISTORY + "?" + urllib.parse.urlencode(params)
    data = fetch_json(url)
    d = data.get("daily", {})
    h = data.get("hourly", {})

    dates = d.get("time", [])
    if not dates:
        print("无历史数据")
        return

    print(f"{'=' * 90}")
    print(f"  {city} 历史天气  {start_date} ~ {end_date}")
    print(f"{'=' * 90}")

    for i, date in enumerate(dates):
        t_max = safe_get(d.get("temperature_2m_max", []), i)
        t_min = safe_get(d.get("temperature_2m_min", []), i)
        at_max = safe_get(d.get("apparent_temperature_max", []), i)
        at_min = safe_get(d.get("apparent_temperature_min", []), i)
        precip = safe_get(d.get("precipitation_sum", []), i, 0)
        rain = safe_get(d.get("rain_sum", []), i, 0)
        snow = safe_get(d.get("snowfall_sum", []), i, 0)
        wind_max = safe_get(d.get("wind_speed_10m_max", []), i, 0)
        wind_gust = safe_get(d.get("wind_gusts_10m_max", []), i, 0)
        wind_dir = safe_get(d.get("wind_direction_10m_dominant", []), i)
        sunrise = safe_get(d.get("sunrise", []), i, "")
        sunset = safe_get(d.get("sunset", []), i, "")
        sunshine = safe_get(d.get("sunshine_duration", []), i, 0)

        try:
            weekday = ["一", "二", "三", "四", "五", "六", "日"][datetime.strptime(date, "%Y-%m-%d").weekday()]
        except Exception:
            weekday = "?"

        sr = sunrise.split("T")[1][:5] if "T" in str(sunrise) else "-"
        ss = sunset.split("T")[1][:5] if "T" in str(sunset) else "-"

        print(f"\n  {date} 周{weekday}")
        print(f"  温度:     {fmt_temp(t_min)} ~ {fmt_temp(t_max)}")
        print(f"  体感温度: {fmt_temp(at_min)} ~ {fmt_temp(at_max)}  {comfort_desc(at_max)}")
        print(f"  降水:     {fmt_mm(precip)}  (雨 {fmt_mm(rain)} / 雪 {fmt_mm(snow)})")
        print(f"  风速:     最大 {wind_max:.0f} km/h ({wind_level(wind_max)})  阵风 {wind_gust:.0f} km/h")
        print(f"  风向:     {wind_dir_name(wind_dir)}")
        print(f"  日照:     {sunshine / 3600:.1f} 小时  日出 {sr} 日落 {ss}")

        # 提取该天的小时级湿度数据
        h_times = h.get("time", [])
        day_indices = [j for j, t in enumerate(h_times) if t.startswith(date)]
        if day_indices:
            rh_vals = [safe_get(h.get("relative_humidity_2m", []), j) for j in day_indices]
            rh_vals = [v for v in rh_vals if v is not None]
            if rh_vals:
                print(f"  湿度:     {min(rh_vals):.0f}% ~ {max(rh_vals):.0f}%  平均 {sum(rh_vals)/len(rh_vals):.0f}%")

            vis_vals = [safe_get(h.get("visibility", []), j) for j in day_indices]
            vis_vals = [v for v in vis_vals if v is not None]
            if vis_vals:
                print(f"  能见度:   {fmt_km(min(vis_vals))} ~ {fmt_km(max(vis_vals))}")

def cmd_aqi(city):
    """空气质量"""
    lat, lon = geocode(city)

    params = {
        "latitude": lat, "longitude": lon,
        "current": ",".join(AQI_HOURLY_VARS),
        "hourly": ",".join(AQI_HOURLY_VARS),
        "timezone": "Asia/Shanghai",
        "forecast_days": 3,
    }

    url = OPEN_METEO_AQI + "?" + urllib.parse.urlencode(params)
    data = fetch_json(url)
    c = data.get("current", {})

    print(f"{'=' * 50}")
    print(f"  {city} 空气质量")
    print(f"  {c.get('time', '').replace('T', ' ')}")
    print(f"{'=' * 50}")
    print(f"  US AQI:    {aqi_desc(c.get('us_aqi'))}")
    print(f"  PM2.5 AQI: {aqi_desc(c.get('us_aqi_pm2_5'))}")
    print(f"  PM10 AQI:  {aqi_desc(c.get('us_aqi_pm10'))}")
    print(f"  PM2.5:     {c.get('pm2_5', '-')} μg/m³")
    print(f"  PM10:      {c.get('pm10', '-')} μg/m³")
    print(f"  O₃:        {c.get('ozone', '-')} μg/m³")
    print(f"  NO₂:       {c.get('nitrogen_dioxide', '-')} μg/m³")
    print(f"  SO₂:       {c.get('sulphur_dioxide', '-')} μg/m³")
    print(f"  CO:        {c.get('carbon_monoxide', '-')} μg/m³")

def cmd_travel(city, start_date, end_date):
    """出行综合评估"""
    lat, lon = geocode(city)

    # 判断是否在预报范围内（未来16天）
    today = datetime.now()
    start_dt = datetime.strptime(start_date, "%Y-%m-%d")
    end_dt = datetime.strptime(end_date, "%Y-%m-%d")
    is_future = start_dt > today - timedelta(days=1)
    is_in_forecast = (start_dt - today).days <= 16

    if is_future and is_in_forecast:
        # 用预报数据
        days_needed = (end_dt - today).days + 2
        params = {
            "latitude": lat, "longitude": lon,
            "daily": ",".join(DAILY_VARS),
            "hourly": "temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,precipitation_probability,wind_speed_10m,uv_index,visibility,cloud_cover",
            "timezone": "Asia/Shanghai",
            "forecast_days": min(days_needed, 16),
        }
        url = OPEN_METEO_FORECAST + "?" + urllib.parse.urlencode(params)
        source = "预报数据"
    elif not is_future:
        # 用历史数据
        params = {
            "latitude": lat, "longitude": lon,
            "start_date": start_date, "end_date": end_date,
            "daily": ",".join(HISTORY_DAILY_VARS),
            "hourly": "temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,wind_speed_10m,visibility,cloud_cover",
            "timezone": "Asia/Shanghai",
        }
        url = OPEN_METEO_HISTORY + "?" + urllib.parse.urlencode(params)
        source = "历史数据"
    else:
        # 超出预报范围，用去年同期
        last_year_start = start_date.replace(str(start_dt.year), str(start_dt.year - 1))
        last_year_end = end_date.replace(str(end_dt.year), str(end_dt.year - 1))
        params = {
            "latitude": lat, "longitude": lon,
            "start_date": last_year_start, "end_date": last_year_end,
            "daily": ",".join(HISTORY_DAILY_VARS),
            "hourly": "temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,wind_speed_10m,visibility,cloud_cover",
            "timezone": "Asia/Shanghai",
        }
        url = OPEN_METEO_HISTORY + "?" + urllib.parse.urlencode(params)
        source = f"去年同期参考 ({last_year_start} ~ {last_year_end})"

    data = fetch_json(url)
    d = data.get("daily", {})
    h = data.get("hourly", {})

    dates = d.get("time", [])
    # 过滤到目标日期范围
    if is_future and is_in_forecast:
        target_dates = []
        for i, dt in enumerate(dates):
            if start_date <= dt <= end_date:
                target_dates.append((i, dt))
    else:
        target_dates = list(enumerate(dates))

    if not target_dates:
        print("无数据")
        return

    print(f"{'=' * 70}")
    print(f"  {city} 出行天气评估")
    print(f"  {start_date} ~ {end_date}  [{source}]")
    print(f"{'=' * 70}")

    issues = []
    good_points = []
    total_precip = 0
    all_temps = []

    for idx, date in target_dates:
        t_max = safe_get(d.get("temperature_2m_max", []), idx)
        t_min = safe_get(d.get("temperature_2m_min", []), idx)
        at_max = safe_get(d.get("apparent_temperature_max", []), idx)
        at_min = safe_get(d.get("apparent_temperature_min", []), idx)
        precip = safe_get(d.get("precipitation_sum", []), idx, 0)
        wind_max = safe_get(d.get("wind_speed_10m_max", []), idx, 0)
        wind_gust = safe_get(d.get("wind_gusts_10m_max", []), idx, 0)
        uv_max = safe_get(d.get("uv_index_max", []), idx)
        sunrise = safe_get(d.get("sunrise", []), idx, "")
        sunset = safe_get(d.get("sunset", []), idx, "")
        sunshine = safe_get(d.get("sunshine_duration", []), idx, 0)

        total_precip += precip
        if t_max is not None:
            all_temps.append(t_max)
        if t_min is not None:
            all_temps.append(t_min)

        try:
            weekday = ["一", "二", "三", "四", "五", "六", "日"][datetime.strptime(date, "%Y-%m-%d").weekday()]
        except Exception:
            weekday = "?"

        sr = sunrise.split("T")[1][:5] if "T" in str(sunrise) else "-"
        ss = sunset.split("T")[1][:5] if "T" in str(sunset) else "-"

        # 小时级数据
        h_times = h.get("time", [])
        day_indices = [j for j, t in enumerate(h_times) if t.startswith(date)]

        rh_vals = [safe_get(h.get("relative_humidity_2m", []), j) for j in day_indices]
        rh_vals = [v for v in rh_vals if v is not None]
        rh_avg = sum(rh_vals) / len(rh_vals) if rh_vals else None

        vis_vals = [safe_get(h.get("visibility", []), j) for j in day_indices]
        vis_vals = [v for v in vis_vals if v is not None]
        vis_min = min(vis_vals) if vis_vals else None

        print(f"\n  📅 {date} 周{weekday}")
        print(f"     温度 {fmt_temp(t_min)}~{fmt_temp(t_max)}  体感 {fmt_temp(at_min)}~{fmt_temp(at_max)}  {comfort_desc(at_max)}")
        print(f"     降水 {fmt_mm(precip)}  风速 {wind_max:.0f}km/h({wind_level(wind_max)})  阵风 {wind_gust:.0f}km/h")
        if uv_max is not None:
            print(f"     UV {uv_desc(uv_max)}")
        if rh_avg is not None:
            print(f"     湿度 {rh_avg:.0f}%  能见度 {fmt_km(vis_min) if vis_min else '-'}")
        print(f"     日出 {sr}  日落 {ss}  日照 {sunshine/3600:.1f}h")

        # 问题检测
        if precip > 10:
            issues.append(f"{date}: 大雨 {precip:.1f}mm — 强烈建议室内活动")
        elif precip > 2:
            issues.append(f"{date}: 中雨 {precip:.1f}mm — 带伞，安排室内备选")
        elif precip > 0.1:
            issues.append(f"{date}: 小雨 {precip:.1f}mm — 带伞")

        if wind_max > 50:
            issues.append(f"{date}: 大风 {wind_max:.0f}km/h — 户外不适")
        elif wind_max > 30:
            issues.append(f"{date}: 较大风 {wind_max:.0f}km/h — 注意")

        if at_max is not None and at_max < 5:
            issues.append(f"{date}: 体感温度低 {at_max:.0f}°C — 需厚外套")

        if uv_max is not None and uv_max > 7:
            issues.append(f"{date}: UV高 {uv_max:.1f} — 必须防晒")

        if vis_min is not None and vis_min < 5000:
            issues.append(f"{date}: 能见度低 {vis_min:.0f}m — 雾霾/雾")

        if rh_avg is not None and rh_avg > 85:
            issues.append(f"{date}: 湿度高 {rh_avg:.0f}% — 体感闷热")

        if precip < 0.1 and (at_max is not None and 15 <= at_max <= 28):
            good_points.append(f"{date}: 温度舒适，适合户外")

    # 总评
    print(f"\n{'─' * 70}")
    print(f"  📊 总评")
    print(f"     温度区间: {min(all_temps):.0f}~{max(all_temps):.0f}°C" if all_temps else "")
    print(f"     总降水:   {total_precip:.1f}mm")
    precip_days = sum(1 for idx, _ in target_dates
                      if safe_get(d.get("precipitation_sum", []), idx, 0) > 0.1)
    print(f"     雨天:     {precip_days}/{len(target_dates)} 天")

    if issues:
        print(f"\n  ⚠️  注意事项:")
        for issue in issues:
            print(f"     • {issue}")

    if good_points:
        print(f"\n  ✅ 好消息:")
        for gp in good_points:
            print(f"     • {gp}")

    # 穿衣建议
    if all_temps:
        avg_temp = sum(all_temps) / len(all_temps)
        print(f"\n  👔 穿衣建议:")
        if avg_temp < 5:
            print(f"     厚羽绒服/棉服 + 毛衣 + 保暖内衣 + 围巾手套")
        elif avg_temp < 10:
            print(f"     薄羽绒/厚外套 + 毛衣/卫衣")
        elif avg_temp < 15:
            print(f"     风衣/夹克 + 长袖")
        elif avg_temp < 20:
            print(f"     薄外套/卫衣 + 长袖T恤")
        elif avg_temp < 25:
            print(f"     T恤/衬衫 + 薄外套备用")
        else:
            print(f"     短袖/薄裙 + 防晒")

def cmd_compare(city, month_day, years=3):
    """历年同期对比"""
    lat, lon = geocode(city)
    years = int(years)
    current_year = datetime.now().year

    month, day = month_day.split("-")

    print(f"{'=' * 70}")
    print(f"  {city} 历年 {month}月{day}日 前后天气对比")
    print(f"{'=' * 70}")

    for y in range(current_year - 1, current_year - years - 1, -1):
        start = f"{y}-{month}-{int(day)-1:02d}" if int(day) > 1 else f"{y}-{month}-01"
        # 取前后各2天，共5天窗口
        try:
            center = datetime(y, int(month), int(day))
            s = (center - timedelta(days=2)).strftime("%Y-%m-%d")
            e = (center + timedelta(days=2)).strftime("%Y-%m-%d")
        except ValueError:
            continue

        params = {
            "latitude": lat, "longitude": lon,
            "start_date": s, "end_date": e,
            "daily": ",".join(HISTORY_DAILY_VARS),
            "hourly": "relative_humidity_2m",
            "timezone": "Asia/Shanghai",
        }

        url = OPEN_METEO_HISTORY + "?" + urllib.parse.urlencode(params)
        try:
            data = fetch_json(url)
        except SystemExit:
            print(f"\n  {y}年: 数据不可用")
            continue

        d = data.get("daily", {})
        h = data.get("hourly", {})
        dates = d.get("time", [])

        if not dates:
            print(f"\n  {y}年: 无数据")
            continue

        print(f"\n  ── {y}年 ──")
        for i, date in enumerate(dates):
            t_max = safe_get(d.get("temperature_2m_max", []), i)
            t_min = safe_get(d.get("temperature_2m_min", []), i)
            precip = safe_get(d.get("precipitation_sum", []), i, 0)
            wind_max = safe_get(d.get("wind_speed_10m_max", []), i, 0)
            sunshine = safe_get(d.get("sunshine_duration", []), i, 0)

            # 小时湿度
            h_times = h.get("time", [])
            day_idx = [j for j, t in enumerate(h_times) if t.startswith(date)]
            rh_vals = [safe_get(h.get("relative_humidity_2m", []), j) for j in day_idx]
            rh_vals = [v for v in rh_vals if v is not None]
            rh_str = f"湿度{sum(rh_vals)/len(rh_vals):.0f}%" if rh_vals else ""

            marker = " ★" if date.endswith(f"-{month}-{day}") else "  "

            rain_str = f"雨{precip:.1f}mm" if precip > 0.1 else "无雨"

            print(f"  {marker} {date}  {fmt_temp(t_min)}~{fmt_temp(t_max)}"
                  f"  {rain_str:<10} 风{wind_max:.0f}km/h"
                  f"  日照{sunshine/3600:.1f}h  {rh_str}")

# ─── 主入口 ────────────────────────────────────────────────

def main():
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(0)

    cmd = sys.argv[1].lower()
    args = sys.argv[2:]

    if cmd == "now":
        if not args:
            print("用法: weathertools.py now <城市>")
            sys.exit(1)
        cmd_now(args[0])

    elif cmd == "forecast":
        if not args:
            print("用法: weathertools.py forecast <城市> [天数]")
            sys.exit(1)
        days = args[1] if len(args) > 1 else 7
        cmd_forecast(args[0], days)

    elif cmd == "hourly":
        if not args:
            print("用法: weathertools.py hourly <城市> [小时数]")
            sys.exit(1)
        hours = args[1] if len(args) > 1 else 48
        cmd_hourly(args[0], hours)

    elif cmd == "history":
        if len(args) < 2:
            print("用法: weathertools.py history <城市> <起始日期> [结束日期]")
            sys.exit(1)
        end = args[2] if len(args) > 2 else None
        cmd_history(args[0], args[1], end)

    elif cmd == "aqi":
        if not args:
            print("用法: weathertools.py aqi <城市>")
            sys.exit(1)
        cmd_aqi(args[0])

    elif cmd == "travel":
        if len(args) < 3:
            print("用法: weathertools.py travel <城市> <起始日期> <结束日期>")
            sys.exit(1)
        cmd_travel(args[0], args[1], args[2])

    elif cmd == "compare":
        if len(args) < 2:
            print("用法: weathertools.py compare <城市> <月-日> [年份数]")
            sys.exit(1)
        years = args[2] if len(args) > 2 else 3
        cmd_compare(args[0], args[1], years)

    else:
        print(f"未知命令: {cmd}")
        print(__doc__)
        sys.exit(1)

if __name__ == "__main__":
    main()
