# Archon 项目进度

## 2026-03-16 配置完成

### 已完成
- [x] Lean 4.29.0-rc6 + Mathlib 安装并缓存
- [x] API Keys 配置（Claude Opus 4.6 + Gemini 3.1 Pro + GPT-5.4）
- [x] Lean LSP MCP 部署（`lean-lsp-mcp` via uvx，项目级配置）
- [x] Plan Agent 定义（`.claude/agents/plan-agent.md`）— 三阶段工作流 + 三种干预策略 + 多轮 Gemini 精化 + 内存持久化
- [x] Lean Agent 定义（`.claude/agents/lean-agent.md`）— LSP MCP 工具指南 + 失败报告格式
- [x] 编排器重写（`tools/orchestrator.py`）— 精简为 155 行启动脚本，委托 Plan Agent
- [x] 端到端测试通过（96s, $0.58，比旧版快 2x 便宜 27%）
- [x] 项目级 CLAUDE.md 配置（交互式 + 无人值守两种模式）
- [x] 三个 AI 连通性验证（Claude/Gemini/GPT）
- [x] CLAUDE.md 来源信息补全（北大 Bin Dong 组 / FrenzyMath）

### 架构（原版 Archon 对齐）
- Plan Agent 主线程 + lean-agent subagent（Claude Code 原生 agent 系统）
- Lean LSP MCP：20+ 工具（诊断、目标、LeanSearch、Loogle 等）
- Gemini 非正式智能体：多轮精化 + 自我反思（通过 mcp__multi-ai__ask）
- 三种干预策略：A(数学gap→Gemini) B(复杂度→分解) C(路径不可行→多模型交叉验证)

## 2026-03-16 定理库建设

### 文件总览（1486 行 Lean 代码）

| 文件 | 行数 | sorry | 状态 | 主定理 |
|------|------|-------|------|--------|
| DirichletIntegral.lean | 466 | 0 | ✅ | `tendsto_integral_sin_div_x`: lim ∫₀^R sin(x)/x = π/2 |
| LogSinIntegral.lean | 43 | 0 | ✅ | `integral_log_sin_Icc_zero_pi_div_two`: ∫₀^{π/2} log(sin x) = -(π/2)log2 |
| LaplaceTransform.lean | 259 | 0 | ✅ | `integral_Ioi_exp_neg_mul_sin/cos`: ∫₀^∞ e^{-at}sin(bt) = b/(a²+b²) |
| GaussianMoments.lean | 60 | 0 | ✅ | `integral_Ioi_pow_mul_exp_neg_sq`: ∫₀^∞ x^{2n}e^{-x²} = Γ(n+1/2)/2 |
| EulerReflection.lean | 98 | 0 | ✅ | `integral_Ioi_rpow_div_one_add`: ∫₀^∞ x^{s-1}/(1+x) = π/sin(πs) |
| QuarticIntegral.lean | 107 | 0 | ✅ | `integral_inv_one_add_pow_four`: ∫_ℝ 1/(1+x⁴) = π/√2 |
| FresnelIntegral.lean | 453 | 4 | 🔄 | `tendsto_integral_sin/cos_sq_atTop`: ∫₀^∞ sin(x²) = √(2π)/4 |

**6 个定理完全证明，1 个（Fresnel）框架完成待填充。**
**全部 7 项均为 Mathlib 中不存在的结果（Claude+GPT+Gemini 三模型交叉验证确认）。**

### 定理依赖关系（SSOT）

```
EulerReflection.lean  ←─── QuarticIntegral.lean（import 并直接引用）
       ↑
  Beta + Gamma 反射（Mathlib 已有）

DirichletIntegral.lean（独立，FTC + Fubini + DCT）
LaplaceTransform.lean（独立，FTC + 极限）
GaussianMoments.lean（独立，调用 integral_rpow_mul_exp_neg_rpow）
LogSinIntegral.lean（独立，直接调 Mathlib）
FresnelIntegral.lean（独立，复 Gaussian + Abel 正则化）
```

### Fresnel 剩余 sorry（4 个）

1. `fresnel_tail_bound` (line 57) — IBP 界：|∫_A^B sin(x²)| ≤ 1/A
2. `fresnel_tail_bound_cos` (line 62) — 同上 cos 版
3. `abel_fresnel_sin` (line 297) — Abel 正则化定理
4. `abel_fresnel_cos` (line 304) — 同上 cos 版

**整体框架完整**：CauchySeq → ℕ→ℝ 扩展 → Abel 正则化 → 复 Gaussian → 极限唯一性。

### 项目结构

```
TestTheorem/
├── Basic.lean               # 基础算术
├── Integrals.lean           # 索引（import 7 个子文件）
├── Integrals/
│   ├── DirichletIntegral.lean
│   ├── LogSinIntegral.lean
│   ├── LaplaceTransform.lean
│   ├── GaussianMoments.lean
│   ├── EulerReflection.lean
│   ├── QuarticIntegral.lean
│   └── FresnelIntegral.lean
├── Combinatorics.lean       # 空，待积累
└── SpecialFunctions.lean    # 空，待积累
```

### 新增技巧记录

- `integral_rpow_mul_exp_neg_rpow` — Mathlib 通用引理 ∫₀^∞ x^q e^{-x^p} = (1/p)Γ((q+1)/p)，GaussianMoments 直接调用
- `integral_image_eq_integral_abs_deriv_smul` — 一般换元公式（EulerReflection 的核心工具）
- `Complex.betaIntegral_eq_Gamma_mul_div` — B(u,v) = Γ(u)Γ(v)/Γ(u+v)，连接积分与 Gamma
- `Complex.ofReal_cpow` — 实数 rpow 提升为复数 cpow
- `Ioo_ae_eq_Ioc` + `setIntegral_congr_set` — Ioo 与 Ioc 在 Lebesgue 测度下等价
- `integral_comp_rpow_Ioi_of_pos` — 幂函数换元 u = x^p（QuarticIntegral 的核心）
- `integral_comp_abs` — 偶函数 ∫_ℝ f(|x|) = 2 ∫_{Ioi 0} f(x)
- `integral_gaussian_complex_Ioi` — 复 Gaussian 半轴积分（Fresnel 的基础）
- `Complex.log_ofReal_mul` + `Complex.log_neg_I` — 复对数分解

## 踩坑总结（Lean 4 + Mathlib 形式化经验）

### 1. Mathlib API 频繁重命名
当前 Mathlib (2026) 大量引理已更名，旧名字直接报 `Unknown identifier`：
| 旧名 | 新名 | 说明 |
|------|------|------|
| `div_le_iff` | `div_le_iff₀` | 加了下标 |
| `abs_add` | `abs_add_le` | 改为不等式命名 |
| `eventually_of_forall` | `Eventually.of_forall` | 点号语法 |
| `setIntegral_congr` | `setIntegral_congr_fun` | 后缀变化 |

**应对**：遇到 `Unknown identifier` 时，先用 `exact?` 或 `apply?` 让 Lean 自动搜索，比猜名字快得多。

### 2. fun_prop 对除法的局限
`fun_prop` 无法自动证明 `Continuous (fun t => f t / g t)` 当分母非零需要 `positivity`。
**应对**：手动写 `Continuous.div (by fun_prop) (by fun_prop) (fun t => by positivity)`。

### 3. Interval integral 的 Fubini 缺失
Mathlib 没有 `intervalIntegral_intervalIntegral_swap`（两个 interval integral 的 Fubini）。
- `intervalIntegral_integral_swap` 存在（一个 interval + 一个一般测度）
- `integral_integral_swap` 存在（两个一般积分）
- `setIntegral_prod` + `setIntegral_prod_swap` 存在（set integral 层级）

**应对**：要么用 `intervalIntegral_integral_swap` 取 `μ = volume.restrict (uIoc c d)`，要么手动转 set integral。后者代码多但更直接。

### 4. 一般测度 DCT 需要显式类型标注
`MeasureTheory.tendsto_integral_filter_of_dominated_convergence` 类型推断经常失败，尤其是 `IsCountablyGenerated` 实例。
**应对**：用 `@` 显式传入所有类型参数，包括 `(atTop : Filter ℝ)` 和 measure。

### 5. ae_restrict 的成员关系
`ae_of_all` 只给全局事实，不提供 `t ∈ Ioi 0` 这种受限集成员关系。
**应对**：用 `filter_upwards [ae_restrict_mem measurableSet_Ioi] with t ht` 获取 `ht : t ∈ Ioi 0`。

### 6. exp 相关引理的参数形式
- `integrableOn_exp_mul_Ioi` 要求 `a < 0`，用 `neg_neg_of_pos hR` 而非手动 `neg_neg.mpr`
- `add_one_le_exp t` 接受 `t : ℝ` 而非 `Prop`
- `exp_le_exp.mpr` 用于 `exp a ≤ exp b ↔ a ≤ b`
- `tendsto_exp_atBot` + `comp` 用于证 `exp(-tR) → 0`

### 7. IsBoundedUnder 的展开
`Filter.Tendsto.zero_mul_isBoundedUnder_le` 需要第二个参数是 `IsBoundedUnder (· ≤ ·) l (‖·‖ ∘ g)`。
**应对**：直接 `unfold IsBoundedUnder IsBounded`，然后 `use bound` + `rw [Filter.eventually_map]` + `Eventually.of_forall`。

### 8. lake build 缓存问题
移动 `.lean` 文件后旧 `.olean` 缓存会导致编译失败。
**应对**：`lake clean` 后重新 build。

### 9. 搜索策略优先级
| 需求 | 首选工具 | 备选 |
|------|---------|------|
| 名字记不清 | `exact?` / `apply?`（在 Lean 里） | `lean_leansearch` |
| 概念性搜索 | `lean_leansearch`（自然语言） | `lean_leanfinder` |
| 类型签名搜索 | `lean_loogle` | `lean_hover_info` |
| 本地是否存在 | `lean_local_search` | `Grep` |
| 当前目标怎么关 | `lean_state_search` | `lean_hammer_premise` |

### 10. 复数幂函数展开
`Complex.cpow_def_of_ne_zero` 展开 `z^w = exp(log(z) * w)`，然后用：
- `Complex.log_ofReal_mul` — 拆分 log(a·z) = log(a) + log(z)（a > 0）
- `Complex.log_neg_I` — log(-i) = -πi/2
- `Complex.exp_re/im` — 取实虚部
- `exp_half` — exp(x/2) = √(exp(x))

### 11. 换元公式
- `integral_image_eq_integral_abs_deriv_smul` — 一般 C¹ 微分同胚的换元
- `integral_comp_rpow_Ioi_of_pos` — 幂函数换元 u = x^p（p > 0）
- 需要证 `InjOn` 和 `HasDerivWithinAt`

### 12. 偶函数积分
`integral_comp_abs` 给 ∫_ℝ f(|x|) = 2 ∫_{Ioi 0} f(x)。
用 `Even.pow_abs` 将 |x|^n 化为 x^n。

## Mathlib 已有结果速查

详见 `docs/mathlib-coverage.md`。关键原则：**不要重新证明 Mathlib 已有的。**
