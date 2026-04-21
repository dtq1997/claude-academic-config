# 深度调查方法论（从 biunimodular vector 调查中提炼）

> 创建: 2026-03-03 | 来源: Biunimodular Vector 定理溯源调查

## StackExchange 搜索的坑

### API 盲区
- `search/advanced` **只搜问题标题和正文，不搜回答正文**。答案中的关键术语完全搜不到
- 解法：用 Google `site:` 搜索补充，或用 SEDE（Data Explorer）写 SQL 查 Posts 表（PostTypeId=2 是回答）
- SEDE SQL 模板：
  ```sql
  SELECT p.Id, p.ParentId, p.CreationDate, u.DisplayName, p.Score
  FROM Posts p JOIN Users u ON u.Id = p.OwnerUserId
  WHERE p.PostTypeId = 2 AND p.Body LIKE '%关键词%'
  ORDER BY p.CreationDate;
  ```
  URL: `https://data.stackexchange.com/mathoverflow/query/new`（换 site 名可查不同站）

### 平台混淆
- **MathOverflow** (mathoverflow.net) ≠ **Math Stack Exchange** (math.stackexchange.com)
- 中文社区常统称"overflow"，不区分。搜索时两个站都要查
- API 中 `site=mathoverflow` vs `site=math`

### Google `site:` 搜索失效场景
- 高度专业的数学术语组合（如 "Clifford torus" + "nondisplaceable" + "unitary"）
- 原因：这类页面少、索引优先级低、术语组合罕见
- 解法：降低关键词数量，每次只用 2 个核心词

## 学术溯源的正确路径

### 论文反向追踪法（最可靠）
1. 找到引用该结果的正式论文
2. 下载 PDF，精读 **致谢 (Acknowledgements)** 和 **参考文献 (References)**
3. 特别关注综述论文 (review/survey)——它们通常有最完整的历史叙述
4. **Idel 案例**：原始论文 (2014) 没提 MathOverflow；综述论文 (2016, arXiv:1609.06349) 第 35 页才承认优先权，第 77 页才列出 MSE 链接

### arXiv 论文下载与阅读
- `curl -sL "https://arxiv.org/pdf/XXXX.XXXXX" -o /tmp/paper.pdf`
- 用 Read 工具读 PDF（指定 pages 参数分段读）
- 重点页面：第 1-2 页（摘要+引言历史）、致谢页、参考文献页

### 多版本检查
- arXiv 论文有多个版本（v1, v2, ...），后续版本可能添加致谢或引用
- 对比方法：检查 arXiv 页面的 "Submission history" 部分

## 搜索策略优先级（深度调查任务）

1. **论文反向追踪**：下载核心论文 → 读致谢和引用 → 追踪链条
2. **Google 宽泛搜索**：2 个核心关键词，不加 `site:` 限制
3. **StackExchange API**：搜问题标题（注意 API 不搜回答）
4. **SEDE SQL 查询**：当需要搜回答正文时的终极手段
5. **中文社区搜索**（知乎/PTT/超理论坛）：用中文术语搜，可能找到二手线索
6. **GPT/Gemini 交叉验证**：模型可能在训练数据中见过相关讨论

## 非专业领域的输出质量控制（从做菜菜谱 4 轮迭代中提炼）

> 创建: 2026-03-27 | 来源: birthday-2026 cooking-recipes.md v1→v4

### 核心原则：先搜权威实验来源，再写建议
- 训练数据里的"常识"可能是谣言（实测：蘑菇不能洗、黄油+油提高烟点、奶油沸腾就完蛋——全被 Harold McGee / Kenji Food Lab / ATK 证伪）
- **流传越广的常识越要验证**——传播度和准确度不相关
- 写完初稿后用 GPT `compare` 模式逐条审查"哪些是错的或误导的"

### 权威来源模式（按领域找对应的"McGee"）
- 烹饪：Harold McGee → Kenji (Food Lab) → ATK → Dave Arnold
- 健身/营养：找 meta-analysis 和 systematic review，不找健身博主
- 装修/家居：找建筑规范和材料科学，不找小红书
- **任何领域：先找该领域的"实验驱动型权威"，不找经验谈**

### 信号检测
- 如果发现自己在写"大家都知道""常识是""不要XXX"→ 立刻搜权威来源验证
- 定量数据（时间、温度、比例）不确定时，同时给定性判断标准

## 通用教训

- **不要只搜一个平台**：同一个生态系统（StackExchange）有几十个子站
- **当 API 搜索全空时，问"是不是搜错地方了"**，而不是"是不是不存在"
- **综述论文 > 原始论文**：综述论文的历史叙述最详尽，优先找综述
- **致谢部分是金矿**：非正式的优先权信息（谁先想到、谁告诉谁）往往只出现在致谢中

---

## 图书/出版物查找方法论（从卢米涅《黑洞》调查中提炼）

> 创建: 2026-03-04 | 来源: 用户问"卢米涅的《黑洞》有新版吗"，经多轮低效搜索才找到《黑洞与暗能量》

### 核心原则：作者中心搜索优先于书名搜索

书名（尤其中文译名）高度重复、歧义严重。搜索策略必须**从作者出发**，不从书名出发。

### 搜索流程（按顺序执行）

1. **确认作者全名及多语言拼写**
   - 中文名、原语言名（法语/德语等）、英文名
   - 例：卢米涅 = Jean-Pierre Luminet = Luminet

2. **拉作者完整著作列表**（第一步就做，不要跳过）
   - Goodreads 作者页 → 最稳定的完整书目来源，WebFetch 可靠
   - Wikipedia 作者页 → 著作年表详尽，但 WebFetch 403 率高，作为并列备选
   - Google Books 搜作者名 → 结构化书目数据
   - ⚠️ 不要用 booktools douban 搜作者名（实测命中率极低）
   - 这一步能一次性看到所有著作，包括用户可能不知道的后续作品

3. **识别"新版"的三种可能**
   - **同书再版**：同一本书的新版/修订版（ISBN 不同，书名相同）
   - **同主题新著**：作者就同一主题写了更新更全面的新书（书名不同）
   - **合集/选编收录**：旧书被收入丛书合集重新出版
   - 用户说"新版"时，三种都要查，尤其第二种最容易遗漏

4. **原语言检索**（英语母语作者可跳过此步）
   - 非英语作者的书，用原语言书名搜索能更快定位完整书目
   - 法国作者 → 法语书名；德国作者 → 德语书名

5. **中文译本定位**
   - 拿到原著完整书目后，逐本查中文译本是否存在
   - `booktools.py douban` 搜**书名**有效，搜**作者名极不可靠**（实测：彭罗斯/加来道雄/温伯格的作者名搜索大部分返回空）
   - 正确做法：先用步骤 2 拿到具体书名列表，再用 booktools 逐个搜书名验证中文版
   - 备选：Google Books（有中文版元数据）、WebSearch "作者名 书名 出版社"

### 反模式（禁止）

- ❌ 用通用书名反复搜豆瓣（"黑洞"返回小说/电视剧/其他作者同名书）
- ❌ 找到旧版就停下，不继续查作者后续作品
- ❌ 只搜中文，不搜原语言
- ❌ 把"没找到新版"当最终结论，而没查过作者是否出了同主题新书

### 工具优先级（图书查找任务）

**拉作者完整著作列表（步骤2）：**
1. Goodreads 作者页 — 最稳定最全，WebFetch 可靠
2. Wikipedia 作者页 — 著作年表详尽，但 403 率高（约50%失败），与 Goodreads 并行请求
3. Google Books 搜作者名 — 结构化元数据
4. WebSearch "作者英文名 bibliography" — 兜底

**验证中文译本是否存在（步骤5）：**
1. `booktools.py douban <具体书名>` — 搜书名有效，搜作者名不可靠
2. WebSearch "作者中文名 书名 出版社" — 补充
3. Google Books 搜中文书名 — 有中文版元数据

> 实测记录（2026-03-04）：booktools douban 作者名搜索，彭罗斯❌、加来道雄❌、温伯格⚠️（仅1条），书名搜索均✅
> 端到端测试（2026-03-04）：用"霍金《时间简史》有新版吗"测试完整流程，成功找到 2025-06 全新升级版 + 识别出《时间简史普及版》《大设计》《十问》等同主题新著。方法论有效。

---

## 游戏 Wiki 查询方法论（从杀戮尖塔2卡牌查询中提炼）

> 创建: 2026-03-11 | 来源: STS2 每日挑战中反复搜索卡牌效果，多次低效

### 核心问题

EA 新游戏的 Wiki 分散、不完整，WebFetch 对部分站点 403。搜索关键词在中英文之间映射不稳定（如"重构"=Transfigure，不是 Reconstruct）。

### 高效路径（按优先级）

1. **sts2.wiki 卡牌数据库** — `https://sts2.wiki/cards/` 全卡列表，WebSearch 搜 `site:sts2.wiki <英文卡名>`
2. **lvl.wiki 卡牌列表** — `https://lvl.wiki/slay-the-spire-2/cards/` 含升级效果
3. **Untapped.gg** — `https://sts2.untapped.gg/en/cards/<卡名小写>` URL 规律稳定，直接拼 URL
4. **WebSearch 精准搜** — `slay the spire 2 "<英文卡名>" upgrade effect`，2个关键词足够

### 反模式（禁止）

- ❌ 用中文卡名搜英文 Wiki（翻译不一致导致搜不到）
- ❌ 搜到一个站没结果就换3-4个站重复搜（应先确认英文卡名再精准定位）
- ❌ 大范围搜 "necrobinder cards" 然后在结果里人肉找（太慢）

### 中英文卡名映射（累积记录）

| 中文 | 英文 | 备注 |
|------|------|------|
| 重构 | Transfigure | 不是 Reconstruct。升级去消耗（非去+1费） |
| 重放 | Replay | 关键词 |
| 虚无 | Ethereal | 关键词 |
| 消耗 | Exhaust | 关键词 |
| 保留 | Retain | 关键词 |
| 灵魂 | Soul | 衍生牌 |
| 奥斯提 | Osty | 召唤物 |

> 遇到新的中英文不一致时追加到此表
