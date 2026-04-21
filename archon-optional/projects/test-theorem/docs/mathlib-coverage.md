# Mathlib 已有结果速查

不要重新证明这些——直接 `import` + 引用即可。

## 特殊积分

| 结果 | Mathlib 定理名 |
|------|---------------|
| ∫ e^{-bx²} = √(π/b) | `integral_gaussian` |
| ∫₀^∞ e^{-bx²} = √(π/b)/2 | `integral_gaussian_Ioi` |
| ∫ₐᵇ sin x = cos a - cos b | `integral_sin` |
| ∫ₐᵇ cos x = sin b - sin a | `integral_cos` |
| ∫ₐᵇ 1/(1+x²) = arctan b - arctan a | `integral_inv_one_add_sq` |
| ∫_ℝ 1/(1+x²) = π | `integral_univ_inv_one_add_sq` |
| ∫₀^∞ e^{-x} = 1 | `integral_exp_neg_Ioi_zero` |
| ∫₀^{π/2} ln(sin x) = -(π/2)ln2 | `integral_log_sin_zero_pi_div_two` |
| ∫ₐᵇ x^n dx | `integral_pow` |
| ∫ sin^n, cos^n (Wallis) | `integral_sin_pow`, `integral_cos_pow_eq` |

## 特殊函数

| 结果 | Mathlib 定理名 |
|------|---------------|
| Γ(s) = ∫₀^∞ t^{s-1} e^{-t} dt | `Real.Gamma_eq_integral` |
| Γ(n+1) = n! | `Real.Gamma_nat_eq_factorial` |
| Γ(1/2) = √π | `Real.Gamma_one_half_eq` |
| Γ(s)Γ(1-s) = π/sin(πs) | `Real.Gamma_mul_Gamma_one_sub` |
| Γ(s)Γ(s+1/2) = Γ(2s)·2^{1-2s}√π | `Real.Gamma_mul_Gamma_add_half` |
| B(s,t) = Γ(s)Γ(t)/Γ(s+t) | `Complex.betaIntegral_eq_Gamma_mul_div` |
| ζ(2) = π²/6 | `riemannZeta_two` |
| ζ(4) = π⁴/90 | `riemannZeta_four` |
| ζ(2k) 通用公式 | `riemannZeta_two_mul_nat` |
| ζ 函数方程 | `riemannZeta_one_sub` |
| Euler sine product | `Real.tendsto_euler_sin_prod` |
| Wallis 乘积 = π/2 | `Real.tendsto_prod_pi_div_two` |
| Stirling 公式 | `Stirling.tendsto_stirlingSeq_sqrt_pi` |
| Leibniz 级数 = π/4 | `Real.tendsto_sum_pi_div_four` |

## 组合恒等式

| 结果 | Mathlib 定理名 |
|------|---------------|
| Vandermonde 恒等式 | `Nat.add_choose_eq` |
| Hockey-stick | `Nat.sum_Icc_choose` |
| 二项式定理 | `add_pow` |
| ∑ C(n,m) = 2^n | `Nat.sum_range_choose` |
| Catalan 数递推 + 显式公式 | `catalan_eq_centralBinom_div` |
| Stirling 数（两类）| `Nat.stirlingFirst`, `Nat.stirlingSecond` |
| 容斥原理 | `Finset.inclusion_exclusion_sum_biUnion` |
| Bernoulli 数 | `bernoulli'` |
