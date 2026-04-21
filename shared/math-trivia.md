# 深层数学冷知识集

收集时间：2026-03-04
用途：和数学圈朋友聊天的谈资，需要进一步研究细节

---

## 1. Borwein 积分：看起来铁律的东西突然崩塌

$$\int_0^\infty \mathrm{sinc}(x)\cdot\mathrm{sinc}(x/3)\cdots\mathrm{sinc}(x/(2k-1))\,dx$$

在 $k=1,\dots,7$ 时**全部精确等于** $\pi/2$。到 $k=8$（乘到 $\mathrm{sinc}(x/15)$）突然变成 $\pi/2 - 2.31\times10^{-11}$。

**原因：** $1/3+1/5+\cdots+1/13 < 1$，加上 $1/15$ 后越过 1，Fourier 卷积的 support 溢出 $[-1,1]$。

**加强版：** 加一个 $2\cos(x)$ 因子后，规律一直撑到 $\mathrm{sinc}(x/111)$，到 $\mathrm{sinc}(x/113)$ 才崩——偏差仅 $\sim10^{-138}$。

**传播点：** "数值验证了前 7 项精确成立的规律，第 8 项就崩了——差 $10^{-11}$。"

**待研究：** Fourier 卷积 support 溢出的精确机制；加 $2\cos(x)$ 后临界值为何推迟到 113

---

## 2. 196884 = 196883 + 1：Monstrous Moonshine

j-function 的第一个非平凡 Fourier 系数是 196884。Monster group（阶 $\approx 8\times10^{53}$）最小非平凡 irrep 的维数是 196883。差恰好 1。后续系数也全部分解为 Monster irrep 维数之和：$21493760 = 1 + 196883 + 21296876$。

McKay 1978 年发现，Conway 称之为 "moonshine"（胡扯）。Borcherds 用 vertex operator algebra + 弦论的 no-ghost theorem 证明，获 1998 Fields Medal。

**OEIS：** A001379（Monster irrep 维数）、A000521（j-invariant Fourier 系数）

**传播点：** "最大的 sporadic group 和椭圆曲线理论的核心函数之间的联系，要借道弦理论才能证明。"

**待研究：** vertex operator algebra (moonshine module $V^\natural$) 的具体构造；Borcherds 证明中 no-ghost theorem 的角色

---

## 3. Supersingular Primes = 整除 Monster 阶的素数

2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 41, 47, 59, 71

这是全部 15 个 supersingular primes（椭圆曲线在特征 $p$ 的 supersingular locus 给出的条件），恰好也是整除 Monster group 阶的全部素数。**为什么一致至今没有不依赖分类定理的解释。**

**OEIS：** A002267

**传播点：** "椭圆曲线的一个性质选出的素数集合，和群论里最大怪物的阶的素因子集合，完全一样。"

**待研究：** Ogg's conjecture 的历史；supersingular 条件的具体定义和等价刻画

---

## 4. $e^{\pi\sqrt{163}}$ 差 $10^{-12}$ 是整数

$$e^{\pi\sqrt{163}} \approx 262537412640768743.99999999999925\ldots$$

**原因链：**
- 163 是最大 Heegner number，$\mathbb{Q}(\sqrt{-163})$ 类数为 1
- $j\bigl(\frac{1+\sqrt{-163}}{2}\bigr) = -640320^3$ 精确为整数
- 所以 $e^{\pi\sqrt{163}} \approx 640320^3 + 744$
- 同一个 640320 出现在 Chudnovsky 兄弟算 $\pi$ 最快的公式里
- 163 = 4·41 - 1，与 Euler 素数生成多项式 $n^2+n+41$（对 $n=0,\dots,39$ 全输出素数）相关

**OEIS：** A003173（Heegner numbers）

**传播点：** "一个常数差 $10^{-12}$ 就是整数，背后连着类域论、j-function 和 $\pi$ 的快速计算。"

**待研究：** complex multiplication 理论的完整图景；Chudnovsky 公式的推导路径

---

## 5. $\tau(n) \equiv \sigma_{11}(n) \pmod{691}$

Ramanujan tau 函数满足此同余。691 的来历：

- $B_{12} = -691/2730$ 的分子
- 反映 Eisenstein series 和 cusp form 在 mod 691 处的 Hecke algebra congruence
- 与 Galois 表示的 reducibility 相关
- 691 同时是 irregular prime，联系 Kummer 对 Fermat 大定理部分情形的处理

**OEIS：** A027860（$(-\tau(n) + \sigma_{11}(n))/691$）

**附加冷知识：** 满足 $p \mid \tau(p)$ 的素数（non-ordinary primes for $\Delta$）只知道 6 个：2, 3, 5, 7, 2411, 7758337633。是否有无穷多个是 open problem。（OEIS: A007659）

**传播点：** "Ramanujan 的一个同余式里冒出 691，它是 Bernoulli 数的分子，同时还是 irregular prime——三条线汇聚到一个数。"

**待研究：** Hecke algebra congruence 的精确陈述；691 与 Kummer 工作的联系细节

---

## 6. Apéry 证明 $\zeta(3)$ 无理性

1978 年，年过六旬、籍籍无名的 Apéry 用法语在会议上宣称证了 $\zeta(3)$ 无理。开场写了一个"在花园里发现的"递推恒等式，跳过关键步骤，台下几乎没人信。Cohen、Lenstra、van der Poorten 花两个月逐行验证：完全正确。

核心：构造递推序列，收敛速度恰好快到能用 Dirichlet 无理性判据。

至今无人能推广到 $\zeta(5)$——计算机搜索表明类似代数常数的最小多项式系数至少 $10^{383}$ 量级。

**传播点：** "Euler 没做到的事，一个无名老人用'花园里灵感一现'做到了，而且至今没人能推广。"

**待研究：** Apéry 递推序列的具体形式；Zagier 的后续工作；$\zeta(5)$ 无理性的困难所在

---

## 7. Borsuk 猜想：低维直觉在 64 维崩塌

$\mathbb{R}^n$ 中有界集能否分成 $n+1$ 个直径更小的子集？$n=2,3$ 及各种特殊情形全部成立。

- 1993 Kahn-Kalai 用概率方法从 $n=1325$ 给出反例
- 后来推到 $n \geq 64$（Jenrich）
- 所需块数增长是指数级：$\alpha(n) \geq (1.2)^{\sqrt{n}}$

**传播点：** "低维想当然的几何直觉，到 64 维就彻底失效。"

**待研究：** Kahn-Kalai 概率构造的具体方法；最优下界的现状

---

## 8. 26 个 Sporadic Groups：20 个 Happy Family + 6 个 Pariahs

26 个 sporadic simple groups 中 20 个是 Monster 的 subquotient（Griess 称 "happy family"），6 个是 "pariahs"：$J_1, J_3, J_4, Ly, Ru, O'N$。

整除所有 sporadic groups 之阶的 18 个素数中，37, 43, 67 不整除 Monster 的阶——只出现在 pariahs 里。

为什么恰好 26 个？为什么分 20+6？没有不依赖分类定理的解释。

**传播点：** "有限单群分类的终点：26 个怪物，其中 6 个连 Monster 都管不住。"

**待研究：** 各 pariah group 的发现历史；它们"不属于 Monster"的本质障碍

---

## 使用建议

- **开场破冰** → #1 Borwein（最戏剧化）或 #6 Apéry（有故事弧）
- **深聊** → #2-5（Moonshine + Heegner + 691 构成连贯叙事链）
- **快速抛梗** → #7 Borsuk 或 #8 Pariahs

---

# 第二批：与研究方向相关的冷知识

收集时间：2026-03-04
方向：isomonodromy, Stokes phenomenon, q-Painlevé, knot invariants, quantum groups

---

## 9. Airy 函数渐近展开系数 = 三角化地图计数 = 闭线性 lambda 项

OEIS A062980（1, 5, 60, 1105, 27120, 828250, ...）同时出现在三个无关领域：

- **Airy 函数的渐近展开**：$\mathrm{Ai}'(x)/\mathrm{Ai}(x)$ 的 large-$x$ 展开系数
- **组合拓扑**：紧致闭合定向曲面上有 $2n$ 个面的有根连通三角化地图数目
- **Lambda 演算**：闭线性 lambda 项的数目（Bodini-Gardy-Jacquot 2013 用双射证明）

渐近量 $a(n) \sim 3 \cdot 6^n \cdot n! / \pi$，阶乘增长正是 Stokes phenomenon 中 divergent asymptotic series 的签名。积分表示：$a(n) = (6/\pi^2) \int_0^\infty (4x)^{3n/2} / (\mathrm{Ai}(x)^2 + \mathrm{Bi}(x)^2)\, dx$。

**传播点：** "Airy 函数的渐近系数同时在数三角化地图和数 lambda 演算表达式，阶乘发散是 Stokes 现象的体现。"

**待研究：** 三角化地图与 Airy 渐近之间的双射/解析证明路径

---

## 10. q-Painlevé I 的 tau 函数在 q=1 退化为 Somos-4 序列

OEIS A095708 给出 q-discrete Painlevé I 的 tau 函数（取 $q=2$）：1, 1, 1, 1, 2, 5, 24, 409, 16648, ...

**关键：** $a(n)$ 本质是 $q$ 的多项式，$q=1$ 时退化为 **Somos-4 序列**（A006720: 1,1,1,1,2,3,7,23,...），其渐近由 Weierstrass 椭圆函数的 sigma/zeta 函数控制（不变量 $(g_2,g_3)=(4,-1)$）。即 q-Painlevé I 的 tau 函数族插值了从椭圆曲线（$q=1$）到超快增长（$q=2$，增长阶 $\log a(n) \sim \log(2) \cdot n^3/18$）的单参数形变。

**传播点：** "q-Painlevé 的 tau 函数取 q=1 就变成 Somos 序列，背后是椭圆函数。"

**待研究：** tau 函数多项式性的证明（来自 cluster algebra 结构？）；A014125 给出的次数序列生成函数 $1/((1-x)^3(1-x^3))$

---

## 11. Ising 模型对角关联满足 Painlevé VI（全温度版本）

Wu-McCoy-Tracy-Barouch (1976) 发现 2D Ising scaling limit 下关联函数满足 PIII。更冷门的是 **Jimbo-Miwa (1980)**：在**所有温度**下（不取 scaling limit），对角关联 $\langle\sigma_{0,0}\sigma_{N,N}\rangle$ 直接满足 **Painlevé VI 的 sigma-form**。Scaling limit 退化为 PIII 只是 PVI coalescence cascade 的一个特例。

**不对称性：** 非对角关联 $\langle\sigma_{0,0}\sigma_{M,N}\rangle$ 至今没有 Painlevé 表示——只满足 quadratic difference equation。这个"对角 vs 非对角"不对称性没有深层解释。

**传播点：** "Ising 关联函数在全温度下是 Painlevé VI，但这只对对角成立——偏一点就不是 Painlevé type 了。"

**待研究：** 非对角情形的 McCoy-Wu-Perk 结果具体形式

---

## 12. 16 种 q-Painlevé 方程 = 16 种恰有一个内格点的凸多边形

Bershtein-Gavrylenko-Marshakov (arXiv:1711.02063) 的统一框架：**所有 16 种 q-Painlevé 方程一一对应于 Newton polygon 恰好有一个内点的凸格多边形**（平面上恰好有 16 种这样的多边形）。Painlevé 动力学被解释为 cluster quiver mutations 的离散流的 deautonomization。

与 Sakai (2001) 的有理曲面分类互补，但给出更具组合味道的视角。

**传播点：** "q-Painlevé 方程的分类等价于数平面上特定凸多边形——恰好 16 个。"

**待研究：** 与 Sakai 分类的精确字典；cluster algebra structure

---

## 13. Kyiv 公式：Painlevé tau 函数 = c=1 共形块 = Nekrasov 分配函数

Gamayun-Iorgov-Lisovyy (2012)：**Painlevé VI 通解的 tau 函数写成 $c=1$ Virasoro conformal blocks 的 Fourier 级数**，系数含 Barnes G-function。通过 AGT correspondence，同一个 tau 函数同时是：(a) isomonodromy 问题的解，(b) $c=1$ CFT 关联函数，(c) 4d $\mathcal{N}=2$ $SU(2)$ Nekrasov instanton partition function。

q-Painlevé 情形（Bershtein-Shchechkin）：conformal blocks → q-Virasoro Whittaker blocks，partition function → 5d Nekrasov。

**传播点：** "同一个函数同时是 ODE 的解、2d CFT 的关联函数、4d 规范场论的配分函数。"

**待研究：** Nekrasov blowup equations 的证明路径；与你们论文中 q-isomonodromy 的关系

---

## 14. Painlevé VI 的代数解：Boalch 的 52 个二十面体解 + "最后的丰富情形"

PVI 代数解（character variety 上有限轨道）的完整分类由 **Lisovyy-Tykhyy (2014)** 完成。Tykhyy 猜想推广到 $n$-punctured sphere 上 $SL(2,\mathbb{C})$ character variety 的有限轨道，**Lam-Landesman-Litt (2024)** 证明了：puncture 数 $\geq 7$ 时**不存在**有限轨道；$n=6$ 时恰好有唯一的 1-parameter 族。

**深意：** PVI 是"最后一个有丰富代数解的情形"——更高阶 Garnier 系统的代数解极度稀少。

**传播点：** "Painlevé VI 的代数解已被完全分类，而且证明了从 7 个奇点开始就没有了——PVI 是最后的乐土。"

**待研究：** Lam-Landesman-Litt 2024 论文 (arXiv:2409.04379)；与 mapping class group dynamics 的联系

---

## 15. Borromean 素数：素数以 Borromean 环的方式"链接"

Arithmetic topology 的字典：knot complement $\leftrightarrow$ number field, linking number $\leftrightarrow$ Legendre symbol, Milnor triple linking number $\leftrightarrow$ Redei symbol。

**(13, 61, 937)** 是一组 **Borromean primes**：任意两个的 Legendre symbol 都是 1（pairwise unlinked），但 Redei symbol 是 $-1$（triply linked）——完美模拟 Borromean 环。Ishida 等人 (2024, arXiv:2403.17957) 在 GRH 下证明了 Borromean primes 的渐近密度公式。

**传播点：** "13、61、937 这三个素数两两不缠但三者不可分——素数可以像 Borromean 环一样链接。"

**待研究：** Morishita《Knots and Primes》的精确类比字典

---

## 16. Jones polynomial 的近似计算恰好是 BQP-complete

精确计算 Jones polynomial 是 #P-hard（和 permanent 一样难）。但 Aharonov-Jones-Landau (2005)：在单位根 $e^{2\pi i/k}$ 处做 **additive approximation** 恰好是 **BQP-complete**（$k=5$ 或 $k \geq 7$）。即 Jones polynomial 的近似求值精确刻画了量子计算机的能力——既不更容易也不更难。从 multiplicative 切到 additive approximation，复杂度从 #P 陡降到 BQP。

**传播点：** "Jones polynomial 的近似计算就是量子计算本身——不多不少。"

**待研究：** Kuperberg (2015) 对 $k \geq 5$ 的完整性证明

---

## 17. Colored Jones 的"尾巴"是 Rogers-Ramanujan 型恒等式

对 alternating knot $K$，$N$-colored Jones polynomial $J_{K,N}(q)$ 的系数随 $N$ 增大稳定化，极限 $q$-series 称为 **tail**。Garoufalidis-Le-Zagier 发现这些 tail 是 **generalized Nahm sums**——同类 $q$-hypergeometric series 也出现在 CFT character formula 中。某些 alternating knots 的 tail 恰好满足 **Rogers-Ramanujan 型恒等式**。Zagier 将其纳入 quantum modular forms 框架。

**传播点：** "knot 的 colored Jones polynomial 稳定化后变成 Rogers-Ramanujan 恒等式——从拓扑到数论。"

**待研究：** Zagier quantum modular forms 的精确定义；与 volume conjecture 的关系

---

## 18. Kontsevich integral 的 unknot 值：modified Bernoulli numbers

Kontsevich integral 是所有 Vassiliev invariants 的 universal invariant，但极难算——2000 年前**连 unknot 的值都不知道**。Bar-Natan, Garoufalidis, Rozansky, Thurston 证明 Wheels formula：

$$Z(\text{unknot}) = \exp\Bigl(\sum_{n=1}^{\infty} b_{2n}\, w_{2n}\Bigr)$$

$w_{2n}$ 是 wheel-shaped Jacobi diagram，$b_{2n}$ 是 modified Bernoulli numbers（由 $\frac{1}{2}\ln\frac{\sinh(x/2)}{x/2}$ 定义，$b_2=1/48$, $b_4=-1/5760$, ...）。

**传播点：** "最简单的结的最强不变量，答案是 Bernoulli 数的变体——纯数论量编码拓扑信息。"

**待研究：** Wheels formula 的证明策略；与 Duflo isomorphism 的联系

---

## 19. 公交车到站间距服从 Painlevé 定义的分布

Tracy-Widom 分布由 Painlevé II 定义（这个已知）。冷门细节：

- **有限 $N$ 修正**：随机酉矩阵 eigenvalue spacing 的 $O(1/N^2)$ 修正项系数本身又含 **Painlevé V** 函数
- **Cuernavaca 公交车**：Krbalek-Seba 对墨西哥 Cuernavaca 市公交车到站间距实测——间距分布与 GUE spacing（Painlevé V/III 定义的 Fredholm determinant）吻合，而非 Poisson。这是 Painlevé 超越函数在日常生活中最意外的"应用"

**传播点：** "墨西哥公交车到站间距分布是 Painlevé 方程的解。"

**待研究：** 有限尺寸修正中 Painlevé V 出现的精确形式

---

## 使用建议（第二批）

- **和做 isomonodromy 的人聊** → #11 Ising 对角/非对角不对称, #13 Kyiv 公式, #14 代数解分类
- **和做 combinatorics/q-series 的人聊** → #10 Somos-4, #12 十六多边形, #17 Rogers-Ramanujan tail
- **和做 knot theory 的人聊** → #15 Borromean primes, #16 BQP-complete, #18 Wheels formula
- **万能破冰** → #19 公交车到站间距, #9 Airy/地图/lambda

---

## 20. Schwarz 映射的圆弧条件比"a,b,c 全实"更宽

Schwarz 映射 $s(z) = y_1/y_2$ 将实轴的三段映为圆弧三角形的三条边。标准叙述说"$a,b,c$ 实数时成立"，但精确条件是 **ODE 系数在实轴上为实**，即 $c, a+b, ab \in \mathbb{R}$。这等价于：

- $a,b \in \mathbb{R}$, $c \in \mathbb{R}$（标准情形），**或**
- $a = \bar{b}$（复共轭），$c \in \mathbb{R}$

第二种情形的几何：指数差 $\nu = a - b = 2i\,\mathrm{Im}(a)$ 是纯虚数，"角度" $\pi\nu$ 不是实角。三角形在 $z=\infty$ 对应的顶点退化为尖点（两边相切，角度为零），Schwarz 映射在该点附近螺旋趋近。但三条边仍然是圆弧。

**机制：** $a = \bar{b}$ 时 Pochhammer 积 $(a)_n(b)_n = |(a)_n|^2 > 0$，所以 $_2F_1(a,b;c;z)$ 在实轴上取正实值。两个 Frobenius 基都实值 → 比值映到 $\mathbb{R}$ → Möbius 保圆 → 圆弧。

**若系数不实**（$c \notin \mathbb{R}$，或 $a,b$ 既非全实亦非共轭），则实轴上无实值解基，像是 $\mathbb{C}$ 中一般解析曲线，非圆弧。

**传播点：** "$a,b$ 可以是复数——只要互为共轭，Schwarz 三角形的边依然是圆弧，只是某个顶点退化成尖点。"

**来源：** pvi-survey/schwarz-demo 项目讨论 (2026-03-09) [Claude]

---

## 数据来源

- OEIS API (oeis.org)
- LMFDB API (lmfdb.org)
- INSPIRE-HEP API (inspirehep.net)
- DLMF (dlmf.nist.gov)
- nLab (ncatlab.org)
- Wikipedia
- arXiv
- Quanta Magazine, Scientific American 等科普报道
