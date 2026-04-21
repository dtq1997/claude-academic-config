# Fresnel IBP Tail Bound 证明策略

来源：Gemini 3.1 Pro + Claude，2026-03-16

## 目标

```lean
fresnel_tail_bound {A B : ℝ} (hA : 0 < A) (hAB : A ≤ B) :
    ‖∫ x in A..B, sin (x ^ 2)‖ ≤ 1 / A
```

## 数学证明

sin(x²) = (1/(2x)) · d/dx(-cos(x²))

IBP with u = 1/(2x), v = -cos(x²):

∫_A^B sin(x²) dx = [-cos(x²)/(2x)]_A^B - ∫_A^B cos(x²)/(2x²) dx

Triangle inequality:
|∫| ≤ 1/(2B) + 1/(2A) + ∫_A^B 1/(2x²) dx
   = 1/(2B) + 1/(2A) + [−1/(2x)]_A^B
   = 1/(2B) + 1/(2A) + 1/(2A) − 1/(2B)
   = 1/A

## Lean 4 证明步骤

### Step 1: 设定函数和导数

- u(x) = 1/(2x)，u'(x) = -1/(2x²)
- v(x) = -cos(x²)，v'(x) = 2x·sin(x²)
- 乘积 u(x)·v'(x) = sin(x²) ✓

### Step 2: 证明 HasDerivAt

```lean
-- v 的导数：cos(x²) 的链式法则
have hv : ∀ x ∈ uIcc A B, HasDerivAt (fun x => -cos (x ^ 2)) (2 * x * sin (x ^ 2)) x := by
  intro x _
  exact ((hasDerivAt_pow 2 x).cos.neg).congr_deriv (by ring)

-- u 的导数：1/(2x) 的导数
have hu : ∀ x ∈ uIcc A B, HasDerivAt (fun x => 1 / (2 * x)) (-1 / (2 * x ^ 2)) x := by
  intro x hx
  -- x > 0 因为 A > 0 且 x ∈ [A,B]
  have hx_pos : 0 < x := ...
  have h2x_ne : 2 * x ≠ 0 := ...
  -- 用 HasDerivAt.div 或手动构造
  ...
```

### Step 3: 可积性

0 ∉ [A,B]（因为 A > 0），所以所有函数在 [A,B] 上连续，hence IntervalIntegrable。
用 `ContinuousOn.intervalIntegrable` + `fun_prop`。

### Step 4: 应用 IBP

```lean
have h_ibp := intervalIntegral.integral_mul_deriv_eq_deriv_mul hu hv hu_int hv_int
```

注意需要把 sin(x²) 改写为 u(x)·v'(x) = (1/(2x))·(2x·sin(x²))。

### Step 5: 界定

IBP 结果：∫ sin(x²) = u(B)v(B) - u(A)v(A) - ∫ u'·v

取范数：
‖∫ sin(x²)‖ ≤ ‖u(B)v(B)‖ + ‖u(A)v(A)‖ + ‖∫ u'·v‖
≤ 1/(2B) + 1/(2A) + ∫_A^B |cos(x²)|/(2x²) dx
≤ 1/(2B) + 1/(2A) + ∫_A^B 1/(2x²) dx

### Step 6: 计算 ∫ 1/(2x²)

用 `integral_eq_sub_of_hasDerivAt`，反导数 -1/(2x)：
∫_A^B 1/(2x²) dx = -1/(2B) - (-1/(2A)) = 1/(2A) - 1/(2B)

### Step 7: 合并

1/(2B) + 1/(2A) + 1/(2A) - 1/(2B) = 1/A ✓

## 关键 Mathlib API

| API | 用途 |
|-----|------|
| `intervalIntegral.integral_mul_deriv_eq_deriv_mul` | IBP |
| `hasDerivAt_pow` | d/dx(x²) = 2x |
| `HasDerivAt.cos`, `HasDerivAt.neg` | 链式法则 |
| `HasDerivAt.inv` 或 `HasDerivAt.div` | d/dx(1/(2x)) |
| `ContinuousOn.intervalIntegrable` | 可积性 |
| `norm_integral_le_of_norm_le` | ‖∫ f‖ ≤ ∫ ‖f‖ |
| `integral_eq_sub_of_hasDerivAt` | FTC 计算 ∫ 1/(2x²) |
| `abs_cos_le_one` | |cos(x²)| ≤ 1 |

## 注意

- cos 版完全对称：u = 1/(2x), v = sin(x²), v' = 2x·cos(x²)
- 关键困难在于把 sin(x²) 改写为 u·v' 的形式，以匹配 IBP 引理的类型
- 需要仔细处理 `congr`/`ring` 来对齐被积函数
