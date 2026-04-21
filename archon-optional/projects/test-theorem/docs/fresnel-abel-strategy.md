# Fresnel Abel 正则化证明策略

来源：Gemini 3.1 Pro，2026-03-16

## 目标

```lean
abel_fresnel_sin (L : ℝ)
    (hL : Tendsto (fun R => ∫ x in (0:ℝ)..R, sin (x ^ 2)) atTop (nhds L)) :
    Tendsto (fun ε => ∫ x : ℝ in Ioi 0, exp (-ε * x ^ 2) * sin (x ^ 2))
      (nhdsWithin 0 (Ioi 0)) (nhds L)
```

## 五步证明

### Step 1: F 有界
定义 F(x) = ∫₀^x sin(t²) dt。因为 F → L，所以 F 有界。
```lean
have h_bound : ∃ M, ∀ x, ‖F x‖ ≤ M := ...
-- Tendsto → Filter.IsBoundedUnder → bound
```

### Step 2: 有限区间 IBP
用 `intervalIntegral.integral_mul_deriv_eq_deriv_mul`：
- u(x) = exp(-εx²)，u'(x) = -2εx·exp(-εx²)
- v(x) = F(x)，v'(x) = sin(x²)

F 的导数用 **`intervalIntegral.integral_hasDerivAt_right`**：
```lean
have hF_deriv : ∀ x, HasDerivAt F (sin (x^2)) x :=
  intervalIntegral.integral_hasDerivAt_right
    (continuous_sin.comp (continuous_pow 2)).continuousAt
    (continuous_sin.comp (continuous_pow 2)).locallyIntegrable
```

IBP 给出：
```
∫₀^R e^{-εx²} sin(x²) = e^{-εR²}·F(R) - F(0) + ∫₀^R 2εx·e^{-εx²}·F(x)
```
注意 F(0) = 0。

### Step 3: R → ∞
- e^{-εR²}·F(R) → 0·L = 0（exp 衰减 × 有界）
- 区间积分 → Ioi 积分（`intervalIntegral_tendsto_integral_Ioi`）

得到：
```
∫_{Ioi 0} e^{-εx²} sin(x²) = ∫_{Ioi 0} 2εx·e^{-εx²}·F(x)
```

### Step 4: 线性换元
用 **`integral_comp_mul_left_Ioi`** 设 c = √ε：
```
∫_{Ioi 0} f(√ε · x) = (√ε)⁻¹ · ∫_{Ioi 0} f(y)
```

定义 f(y) = 2y·e^{-y²}·F(y/√ε)。

代入后 √ε 和 (√ε)⁻¹ 消掉：
```
∫_{Ioi 0} 2εx·e^{-εx²}·F(x) = ∫_{Ioi 0} 2y·e^{-y²}·F(y/√ε)
```

### Step 5: DCT (ε → 0⁺)
用 `tendsto_integral_filter_of_dominated_convergence`：
- Filter: `nhdsWithin 0 (Ioi 0)`
- 被积函数: 2y·e^{-y²}·F(y/√ε)
- 逐点极限: 2y·e^{-y²}·L（因为 y/√ε → ∞，F → L）
- 控制函数: 2M·y·e^{-y²}
- 控制函数可积: 用 FTC，`integral_Ioi_of_hasDerivAt_of_tendsto`，反导数 -M·e^{-y²}

极限值 = L · ∫₀^∞ 2y·e^{-y²} = L · 1 = L。

## 关键 Mathlib API

| API | 用途 |
|-----|------|
| `intervalIntegral.integral_hasDerivAt_right` | F'(x) = sin(x²) |
| `intervalIntegral.integral_mul_deriv_eq_deriv_mul` | IBP |
| `integral_comp_mul_left_Ioi` | 线性换元 x = y/√ε |
| `integral_Ioi_of_hasDerivAt_of_tendsto` | ∫₀^∞ 2y·e^{-y²} = 1 |
| `tendsto_integral_filter_of_dominated_convergence` | DCT |
| `Filter.Tendsto.zero_mul_isBoundedUnder_le` | 0·bounded → 0 |

## 风险评估
- Step 2 的 IBP 不太难（和 DirichletIntegral 里的模式类似）
- Step 4 的线性换元是关键技巧，避免了非线性换元的痛苦
- Step 5 的 DCT 需要细致的 ae 条件
- 整体代码量估计 200-300 行
