/-
# Fresnel Integrals: ∫₀^∞ sin(x²) dx = ∫₀^∞ cos(x²) dx = √(2π)/4

## Proof strategy: Complex Gaussian regularization

For ε > 0, Mathlib gives ∫₀^∞ e^{-(ε+i)x²} dx = (π/(ε+i))^{1/2}/2.

Step 1: Decompose e^{-(ε+i)x²} = e^{-εx²}(cos(x²) - i sin(x²)).
Step 2: Real part of the Gaussian integral gives ∫₀^∞ e^{-εx²} cos(x²) dx.
Step 3: Show the regularized integrals converge to the Fresnel integrals as ε → 0.
Step 4: Compute lim_{ε→0} Re((π/(ε+i))^{1/2}/2) = √(2π)/4.

## Sorry status (4 sorry's remaining)

1. `fresnel_tail_bound`: Integration by parts gives |∫_A^B sin(x²) dx| ≤ 1/A for 0 < A ≤ B.
   Proof sketch: u = 1/(2x), v' = 2x sin(x²), IBP + triangle inequality.
2. `fresnel_tail_bound_cos`: Same bound for cos(x²).
3. `abel_fresnel_sin`: Abel regularization for sin(x²).
4. `abel_fresnel_cos`: Abel regularization for cos(x²).

## What's proved

- Regularized integral identities (complex Gaussian decomposition)
- Explicit value computation: Re((π/i)^{1/2}/2) = -Im((π/i)^{1/2}/2) = √(2π)/4
- Continuity of ε ↦ (π/(ε+i))^{1/2}/2 at ε = 0
- CauchySeq for ℕ-indexed Fresnel integrals (from tail bound)
- Extension from ℕ-indexed to ℝ-indexed convergence (from tail bound)
- Complete assembly: uniqueness of limits gives the final result
-/
import Mathlib.Analysis.SpecialFunctions.Integrals.Basic
import Mathlib.Analysis.SpecialFunctions.Gaussian.GaussianIntegral
import Mathlib.Analysis.SpecialFunctions.Gamma.Basic
import Mathlib.MeasureTheory.Integral.IntegralEqImproper
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Bounds

open MeasureTheory Set Filter Topology Real intervalIntegral
open scoped ENNReal

noncomputable section

/-! ## Step 1: Tail bounds via integration by parts

The key analytical fact: for 0 < A ≤ B, the oscillatory integrals satisfy
|∫_A^B sin(x²) dx| ≤ 1/A and |∫_A^B cos(x²) dx| ≤ 1/A.

Proof sketch: write sin(x²) = (1/(2x)) · d/dx(-cos(x²)), integrate by parts:
∫_A^B sin(x²) dx = [-cos(x²)/(2x)]_A^B - ∫_A^B cos(x²)/(2x²) dx
Then |∫_A^B sin(x²) dx| ≤ 1/(2A) + 1/(2B) + ∫_A^B 1/(2x²) dx
= 1/(2A) + 1/(2B) + 1/(2A) - 1/(2B) = 1/A.

This requires: `integral_mul_deriv_eq_deriv_mul` from Mathlib, HasDerivAt for 1/(2x) and
-cos(x²), IntervalIntegrable for the derivatives, and triangle inequality bounds. -/

/-- Integration by parts bound for ∫_A^B sin(x²) dx. -/
private theorem fresnel_tail_bound {A B : ℝ} (hA : 0 < A) (hAB : A ≤ B) :
    ‖∫ x in A..B, sin (x ^ 2)‖ ≤ 1 / A := by
  sorry

/-- Integration by parts bound for ∫_A^B cos(x²) dx. -/
private theorem fresnel_tail_bound_cos {A B : ℝ} (hA : 0 < A) (hAB : A ≤ B) :
    ‖∫ x in A..B, cos (x ^ 2)‖ ≤ 1 / A := by
  sorry

/-! ## Step 2: Convergence of Fresnel integrals via tail bounds -/

/-- The Fresnel sine partial integrals form a Cauchy sequence. -/
private theorem fresnel_sin_cauchy :
    CauchySeq (fun n : ℕ => ∫ x in (0:ℝ)..n, sin (x ^ 2)) := by
  rw [Metric.cauchySeq_iff']
  intro ε hε
  obtain ⟨N, hN⟩ := exists_nat_gt (1 / ε)
  use max N 1
  intro n hn
  rw [dist_eq_norm]
  have hm_pos : (0 : ℝ) < ↑(max N 1 : ℕ) := by exact_mod_cast (show 0 < max N 1 by omega)
  have hmn_real : (↑(max N 1 : ℕ) : ℝ) ≤ ↑n := by exact_mod_cast (hn : max N 1 ≤ n)
  have hint : ∀ a b : ℝ, IntervalIntegrable (fun x => sin (x ^ 2)) volume a b :=
    fun a b => (continuous_sin.comp (continuous_pow 2)).intervalIntegrable a b
  have h_split : (∫ x in (0:ℝ)..↑n, sin (x ^ 2)) - ∫ x in (0:ℝ)..↑(max N 1 : ℕ), sin (x ^ 2) =
      ∫ x in (↑(max N 1 : ℕ) : ℝ)..↑n, sin (x ^ 2) := by
    linarith [integral_add_adjacent_intervals (hint 0 ↑(max N 1 : ℕ)) (hint ↑(max N 1 : ℕ) ↑n)]
  calc ‖(∫ x in (0:ℝ)..↑n, sin (x ^ 2)) - ∫ x in (0:ℝ)..↑(max N 1 : ℕ), sin (x ^ 2)‖
      = ‖∫ x in (↑(max N 1 : ℕ) : ℝ)..↑n, sin (x ^ 2)‖ := by rw [h_split]
    _ ≤ 1 / (↑(max N 1 : ℕ) : ℝ) := fresnel_tail_bound hm_pos hmn_real
    _ < ε := by
        have hN_le : (N : ℝ) ≤ ↑(max N 1 : ℕ) := by exact_mod_cast le_max_left N 1
        have h1 : 1 / ε < ↑(max N 1 : ℕ) := lt_of_lt_of_le hN hN_le
        rwa [div_lt_comm₀ hm_pos hε]

/-- The Fresnel cosine partial integrals form a Cauchy sequence. -/
private theorem fresnel_cos_cauchy :
    CauchySeq (fun n : ℕ => ∫ x in (0:ℝ)..n, cos (x ^ 2)) := by
  rw [Metric.cauchySeq_iff']
  intro ε hε
  obtain ⟨N, hN⟩ := exists_nat_gt (1 / ε)
  use max N 1
  intro n hn
  rw [dist_eq_norm]
  have hm_pos : (0 : ℝ) < ↑(max N 1 : ℕ) := by exact_mod_cast (show 0 < max N 1 by omega)
  have hmn_real : (↑(max N 1 : ℕ) : ℝ) ≤ ↑n := by exact_mod_cast (hn : max N 1 ≤ n)
  have hint : ∀ a b : ℝ, IntervalIntegrable (fun x => cos (x ^ 2)) volume a b :=
    fun a b => (continuous_cos.comp (continuous_pow 2)).intervalIntegrable a b
  have h_split : (∫ x in (0:ℝ)..↑n, cos (x ^ 2)) - ∫ x in (0:ℝ)..↑(max N 1 : ℕ), cos (x ^ 2) =
      ∫ x in (↑(max N 1 : ℕ) : ℝ)..↑n, cos (x ^ 2) := by
    linarith [integral_add_adjacent_intervals (hint 0 ↑(max N 1 : ℕ)) (hint ↑(max N 1 : ℕ) ↑n)]
  calc ‖(∫ x in (0:ℝ)..↑n, cos (x ^ 2)) - ∫ x in (0:ℝ)..↑(max N 1 : ℕ), cos (x ^ 2)‖
      = ‖∫ x in (↑(max N 1 : ℕ) : ℝ)..↑n, cos (x ^ 2)‖ := by rw [h_split]
    _ ≤ 1 / (↑(max N 1 : ℕ) : ℝ) := fresnel_tail_bound_cos hm_pos hmn_real
    _ < ε := by
        have hN_le : (N : ℝ) ≤ ↑(max N 1 : ℕ) := by exact_mod_cast le_max_left N 1
        have h1 : 1 / ε < ↑(max N 1 : ℕ) := lt_of_lt_of_le hN hN_le
        rwa [div_lt_comm₀ hm_pos hε]

/-- Extend ℕ-indexed convergence of Fresnel sine integrals to ℝ-indexed convergence,
using the tail bound to control ∫_{⌈R⌉}^R. -/
private theorem fresnel_sin_tendsto_real (L : ℝ)
    (hL_nat : Tendsto (fun n : ℕ => ∫ x in (0:ℝ)..n, sin (x ^ 2)) atTop (nhds L)) :
    Tendsto (fun R => ∫ x in (0:ℝ)..R, sin (x ^ 2)) atTop (nhds L) := by
  rw [Metric.tendsto_atTop]
  intro ε hε
  obtain ⟨N₁, hN₁⟩ := (Metric.tendsto_atTop.mp hL_nat) (ε / 2) (half_pos hε)
  obtain ⟨N₂, hN₂⟩ := exists_nat_gt (2 / ε)
  set M := max N₁ (N₂ + 1)
  use ↑M
  intro R hR
  have hR_pos : 0 < R := lt_of_lt_of_le (by positivity : (0:ℝ) < M) hR
  set n := ⌈R⌉₊
  have hn_ge_R : R ≤ (n : ℝ) := Nat.le_ceil R
  have hn_ge_N₁ : n ≥ N₁ := by
    have : (N₁ : ℝ) ≤ M := by exact_mod_cast le_max_left N₁ (N₂ + 1)
    exact_mod_cast le_trans (le_trans this hR) hn_ge_R
  have h1 : dist (∫ x in (0:ℝ)..↑n, sin (x ^ 2)) L < ε / 2 := hN₁ n hn_ge_N₁
  have hint : ∀ a b : ℝ, IntervalIntegrable (fun x => sin (x ^ 2)) volume a b :=
    fun a b => (continuous_sin.comp (continuous_pow 2)).intervalIntegrable a b
  have h_gap : (∫ x in (0:ℝ)..R, sin (x ^ 2)) - ∫ x in (0:ℝ)..↑n, sin (x ^ 2) =
      -(∫ x in R..↑n, sin (x ^ 2)) := by
    linarith [integral_add_adjacent_intervals (hint 0 R) (hint R ↑n)]
  have h2 : ‖∫ x in R..↑n, sin (x ^ 2)‖ ≤ 1 / R :=
    fresnel_tail_bound hR_pos hn_ge_R
  have hR_gt : 2 / ε < R := by
    have : (↑(N₂ + 1) : ℝ) ≤ M := by exact_mod_cast le_max_right N₁ (N₂ + 1)
    push_cast at this; linarith
  have h3 : 1 / R < ε / 2 := by
    have h1 : 2 < ε * R := by rwa [div_lt_iff₀ (by linarith : (0:ℝ) < ε), mul_comm] at hR_gt
    rw [div_lt_div_iff₀ hR_pos (by norm_num : (0:ℝ) < 2)]; linarith
  rw [dist_eq_norm]
  calc ‖(∫ x in (0:ℝ)..R, sin (x ^ 2)) - L‖
      = ‖((∫ x in (0:ℝ)..R, sin (x ^ 2)) - ∫ x in (0:ℝ)..↑n, sin (x ^ 2)) +
        ((∫ x in (0:ℝ)..↑n, sin (x ^ 2)) - L)‖ := by ring_nf
    _ ≤ ‖(∫ x in (0:ℝ)..R, sin (x ^ 2)) - ∫ x in (0:ℝ)..↑n, sin (x ^ 2)‖ +
        ‖(∫ x in (0:ℝ)..↑n, sin (x ^ 2)) - L‖ := norm_add_le _ _
    _ = ‖∫ x in R..↑n, sin (x ^ 2)‖ + ‖(∫ x in (0:ℝ)..↑n, sin (x ^ 2)) - L‖ := by
        rw [h_gap, norm_neg]
    _ ≤ 1 / R + ‖(∫ x in (0:ℝ)..↑n, sin (x ^ 2)) - L‖ := by gcongr
    _ < ε / 2 + ε / 2 := by gcongr; rwa [← dist_eq_norm]
    _ = ε := by ring

/-- Extend ℕ-indexed convergence of Fresnel cosine integrals to ℝ-indexed convergence. -/
private theorem fresnel_cos_tendsto_real (L : ℝ)
    (hL_nat : Tendsto (fun n : ℕ => ∫ x in (0:ℝ)..n, cos (x ^ 2)) atTop (nhds L)) :
    Tendsto (fun R => ∫ x in (0:ℝ)..R, cos (x ^ 2)) atTop (nhds L) := by
  rw [Metric.tendsto_atTop]
  intro ε hε
  obtain ⟨N₁, hN₁⟩ := (Metric.tendsto_atTop.mp hL_nat) (ε / 2) (half_pos hε)
  obtain ⟨N₂, hN₂⟩ := exists_nat_gt (2 / ε)
  set M := max N₁ (N₂ + 1)
  use ↑M
  intro R hR
  have hR_pos : 0 < R := lt_of_lt_of_le (by positivity : (0:ℝ) < M) hR
  set n := ⌈R⌉₊
  have hn_ge_R : R ≤ (n : ℝ) := Nat.le_ceil R
  have hn_ge_N₁ : n ≥ N₁ := by
    have : (N₁ : ℝ) ≤ M := by exact_mod_cast le_max_left N₁ (N₂ + 1)
    exact_mod_cast le_trans (le_trans this hR) hn_ge_R
  have h1 : dist (∫ x in (0:ℝ)..↑n, cos (x ^ 2)) L < ε / 2 := hN₁ n hn_ge_N₁
  have hint : ∀ a b : ℝ, IntervalIntegrable (fun x => cos (x ^ 2)) volume a b :=
    fun a b => (continuous_cos.comp (continuous_pow 2)).intervalIntegrable a b
  have h_gap : (∫ x in (0:ℝ)..R, cos (x ^ 2)) - ∫ x in (0:ℝ)..↑n, cos (x ^ 2) =
      -(∫ x in R..↑n, cos (x ^ 2)) := by
    linarith [integral_add_adjacent_intervals (hint 0 R) (hint R ↑n)]
  have h2 : ‖∫ x in R..↑n, cos (x ^ 2)‖ ≤ 1 / R :=
    fresnel_tail_bound_cos hR_pos hn_ge_R
  have hR_gt : 2 / ε < R := by
    have : (↑(N₂ + 1) : ℝ) ≤ M := by exact_mod_cast le_max_right N₁ (N₂ + 1)
    push_cast at this; linarith
  have h3 : 1 / R < ε / 2 := by
    have h1 : 2 < ε * R := by rwa [div_lt_iff₀ (by linarith : (0:ℝ) < ε), mul_comm] at hR_gt
    rw [div_lt_div_iff₀ hR_pos (by norm_num : (0:ℝ) < 2)]; linarith
  rw [dist_eq_norm]
  calc ‖(∫ x in (0:ℝ)..R, cos (x ^ 2)) - L‖
      = ‖((∫ x in (0:ℝ)..R, cos (x ^ 2)) - ∫ x in (0:ℝ)..↑n, cos (x ^ 2)) +
        ((∫ x in (0:ℝ)..↑n, cos (x ^ 2)) - L)‖ := by ring_nf
    _ ≤ ‖(∫ x in (0:ℝ)..R, cos (x ^ 2)) - ∫ x in (0:ℝ)..↑n, cos (x ^ 2)‖ +
        ‖(∫ x in (0:ℝ)..↑n, cos (x ^ 2)) - L‖ := norm_add_le _ _
    _ = ‖∫ x in R..↑n, cos (x ^ 2)‖ + ‖(∫ x in (0:ℝ)..↑n, cos (x ^ 2)) - L‖ := by
        rw [h_gap, norm_neg]
    _ ≤ 1 / R + ‖(∫ x in (0:ℝ)..↑n, cos (x ^ 2)) - L‖ := by gcongr
    _ < ε / 2 + ε / 2 := by gcongr; rwa [← dist_eq_norm]
    _ = ε := by ring

/-! ## Step 3: Regularized integral identities

For ε > 0, the regularized Fresnel integrals equal the real/imaginary parts
of the complex Gaussian integral ∫₀^∞ e^{-(ε+i)x²} dx = (π/(ε+i))^{1/2}/2. -/

/-- For ε > 0, the regularized Fresnel sine integral equals the imaginary part
of the complex Gaussian integral (with a sign). -/
private theorem regularized_fresnel_sin (ε : ℝ) (hε : 0 < ε) :
    ∫ x : ℝ in Ioi 0, exp (-ε * x ^ 2) * sin (x ^ 2) =
      -Complex.im ((↑π / (↑ε + Complex.I)) ^ (1/2 : ℂ) / 2) := by
  have hb : 0 < (↑ε + Complex.I : ℂ).re := by
    simp [Complex.add_re, Complex.ofReal_re, Complex.I_re]; exact hε
  have hgauss := integral_gaussian_complex_Ioi hb
  have hint := integrable_cexp_neg_mul_sq hb
  set b : ℂ := ↑ε + Complex.I with hb_def
  have h_ofReal_sq : ∀ x : ℝ, ((↑x : ℂ) ^ 2).re = x ^ 2 := by
    intro x; rw [← Complex.ofReal_pow]; exact Complex.ofReal_re _
  have h_ofReal_sq_im : ∀ x : ℝ, ((↑x : ℂ) ^ 2).im = 0 := by
    intro x; rw [← Complex.ofReal_pow]; exact Complex.ofReal_im _
  have h_im_part : ∀ x : ℝ, (-b * (↑x : ℂ) ^ 2).im = -(x ^ 2) := by
    intro x; rw [hb_def]
    simp only [Complex.neg_im, Complex.mul_im,
      Complex.ofReal_re, Complex.I_re, Complex.add_im, Complex.ofReal_im, Complex.I_im,
      h_ofReal_sq, h_ofReal_sq_im]; ring
  have h_re_part : ∀ x : ℝ, (-b * (↑x : ℂ) ^ 2).re = -ε * x ^ 2 := by
    intro x; rw [hb_def]
    simp only [Complex.neg_re, Complex.mul_re, Complex.add_re, Complex.ofReal_re,
      Complex.I_re, Complex.ofReal_im, Complex.I_im,
      h_ofReal_sq, h_ofReal_sq_im]; ring
  have h_im_pw : ∀ x : ℝ, (Complex.exp (-b * ↑x ^ 2)).im =
      -(exp (-ε * x ^ 2) * sin (x ^ 2)) := by
    intro x; rw [Complex.exp_im, h_re_part, h_im_part, sin_neg]; ring
  have h_eq : ∫ x : ℝ in Ioi 0, exp (-ε * x ^ 2) * sin (x ^ 2) =
      -(∫ x : ℝ in Ioi 0, Complex.exp (-b * ↑x ^ 2)).im := by
    have hint_Ioi : IntegrableOn (fun x : ℝ => Complex.exp (-b * ↑x ^ 2))
        (Ioi (0 : ℝ)) volume := hint.integrableOn
    have h_im_integral : ∫ x : ℝ in Ioi 0, (Complex.exp (-b * ↑x ^ 2)).im =
        (∫ x : ℝ in Ioi 0, Complex.exp (-b * ↑x ^ 2)).im :=
      integral_im hint_Ioi
    have h1 : ∫ x : ℝ in Ioi 0, (Complex.exp (-b * ↑x ^ 2)).im =
        ∫ x : ℝ in Ioi 0, -(exp (-ε * x ^ 2) * sin (x ^ 2)) :=
      setIntegral_congr_fun measurableSet_Ioi fun x _ => h_im_pw x
    rw [h_im_integral] at h1
    simp only [MeasureTheory.integral_neg] at h1
    linarith
  rw [h_eq, hgauss]

/-- For ε > 0, the regularized Fresnel cosine integral equals the real part
of the complex Gaussian integral. -/
private theorem regularized_fresnel_cos (ε : ℝ) (hε : 0 < ε) :
    ∫ x : ℝ in Ioi 0, exp (-ε * x ^ 2) * cos (x ^ 2) =
      Complex.re ((↑π / (↑ε + Complex.I)) ^ (1/2 : ℂ) / 2) := by
  have hb : 0 < (↑ε + Complex.I : ℂ).re := by
    simp [Complex.add_re, Complex.ofReal_re, Complex.I_re]; exact hε
  have hgauss := integral_gaussian_complex_Ioi hb
  have hint := integrable_cexp_neg_mul_sq hb
  set b : ℂ := ↑ε + Complex.I with hb_def
  have h_ofReal_sq : ∀ x : ℝ, ((↑x : ℂ) ^ 2).re = x ^ 2 := by
    intro x; rw [← Complex.ofReal_pow]; exact Complex.ofReal_re _
  have h_ofReal_sq_im : ∀ x : ℝ, ((↑x : ℂ) ^ 2).im = 0 := by
    intro x; rw [← Complex.ofReal_pow]; exact Complex.ofReal_im _
  have h_re_part : ∀ x : ℝ, (-b * (↑x : ℂ) ^ 2).re = -ε * x ^ 2 := by
    intro x; rw [hb_def]
    simp only [Complex.neg_re, Complex.mul_re, Complex.add_re, Complex.ofReal_re,
      Complex.I_re, Complex.ofReal_im, Complex.I_im,
      h_ofReal_sq, h_ofReal_sq_im]; ring
  have h_im_part : ∀ x : ℝ, (-b * (↑x : ℂ) ^ 2).im = -(x ^ 2) := by
    intro x; rw [hb_def]
    simp only [Complex.neg_im, Complex.mul_im,
      Complex.ofReal_re, Complex.I_re, Complex.add_im, Complex.ofReal_im, Complex.I_im,
      h_ofReal_sq, h_ofReal_sq_im]; ring
  have h_re_pw : ∀ x : ℝ, (Complex.exp (-b * ↑x ^ 2)).re =
      exp (-ε * x ^ 2) * cos (x ^ 2) := by
    intro x; rw [Complex.exp_re, h_re_part, h_im_part, cos_neg]
  have h_eq : ∫ x : ℝ in Ioi 0, exp (-ε * x ^ 2) * cos (x ^ 2) =
      (∫ x : ℝ in Ioi 0, Complex.exp (-b * ↑x ^ 2)).re := by
    trans (∫ x : ℝ in Ioi 0, (Complex.exp (-b * ↑x ^ 2)).re)
    · exact setIntegral_congr_fun measurableSet_Ioi fun x _ => (h_re_pw x).symm
    · exact integral_re hint.integrableOn
  rw [h_eq, hgauss]

/-! ## Step 4: Abel's theorem for the Fresnel integrals

If ∫₀^R f(x) dx → L as R → ∞, then ∫₀^∞ e^{-εx²} f(x) dx → L as ε → 0⁺.

This is a form of Abel regularization. The standard proof uses integration by parts:
∫₀^∞ e^{-εx²} f(x) dx = [e^{-εx²} F(x)]₀^∞ + 2ε ∫₀^∞ x e^{-εx²} F(x) dx
where F(x) = ∫₀^x f(t) dt → L. Since 2ε ∫₀^∞ x e^{-εx²} dx = 1 (the weight
integrates to 1), we get 2ε ∫₀^∞ x e^{-εx²} F(x) dx → L by dominated convergence
with the weight concentrated near x ~ 1/√ε → ∞ where F ≈ L. -/

/-- Abel regularization for the Fresnel sine integral. -/
private theorem abel_fresnel_sin (L : ℝ)
    (hL : Tendsto (fun R => ∫ x in (0:ℝ)..R, sin (x ^ 2)) atTop (nhds L)) :
    Tendsto (fun ε => ∫ x : ℝ in Ioi 0, exp (-ε * x ^ 2) * sin (x ^ 2))
      (nhdsWithin 0 (Ioi 0)) (nhds L) := by
  sorry

/-- Abel regularization for the Fresnel cosine integral. -/
private theorem abel_fresnel_cos (L : ℝ)
    (hL : Tendsto (fun R => ∫ x in (0:ℝ)..R, cos (x ^ 2)) atTop (nhds L)) :
    Tendsto (fun ε => ∫ x : ℝ in Ioi 0, exp (-ε * x ^ 2) * cos (x ^ 2))
      (nhdsWithin 0 (Ioi 0)) (nhds L) := by
  sorry

/-! ## Step 5: Computing the limit of the complex Gaussian as ε → 0

We need: lim_{ε→0⁺} Re((π/(ε+i))^{1/2}/2) = √(2π)/4
and:     lim_{ε→0⁺} -Im((π/(ε+i))^{1/2}/2) = √(2π)/4

Key computation:
  (π/(ε+i))^{1/2} = exp(log(π/(ε+i))/2)
  As ε → 0⁺, π/(ε+i) → π/i = -πi
  log(-πi) = ln(π) - πi/2
  So (π/i)^{1/2} = exp((ln(π) - πi/2)/2) = √π · e^{-πi/4}
                  = √π · (cos(π/4) - i·sin(π/4)) = √π · (1/√2 - i/√2)
  Dividing by 2: Re = -Im = √π/(2√2) = √(2π)/4 -/

private theorem neg_pi_mul_I_ne_zero : -(↑π * Complex.I) ≠ (0 : ℂ) := by
  simp [Complex.ext_iff, Complex.ofReal_re, Complex.ofReal_im,
    Complex.I_re, Complex.I_im]

private theorem re_cpow_pi_div_I :
    Complex.re ((↑π / Complex.I) ^ (1/2 : ℂ) / 2) = √(2 * π) / 4 := by
  rw [Complex.div_I]
  rw [Complex.cpow_def_of_ne_zero neg_pi_mul_I_ne_zero]
  rw [show -(↑π * Complex.I) = ↑π * (-Complex.I) from by ring]
  rw [Complex.log_ofReal_mul pi_pos (neg_ne_zero.mpr Complex.I_ne_zero)]
  rw [Complex.log_neg_I]
  have h_exp : (↑(Real.log π) + -(↑π / 2) * Complex.I) * (1/2 : ℂ) =
      ↑(Real.log π / 2) + ↑(-(π / 4)) * Complex.I := by
    push_cast; ring
  rw [h_exp]
  rw [show (2 : ℂ) = ↑(2 : ℝ) from by norm_cast]
  rw [Complex.div_ofReal_re]
  rw [Complex.exp_re]
  simp only [Complex.add_re, Complex.ofReal_re, Complex.mul_re,
    Complex.ofReal_im, Complex.I_re, Complex.I_im,
    Complex.add_im, Complex.mul_im]
  ring_nf
  rw [show π * (-1 / 4 : ℝ) = -(π / 4) from by ring, cos_neg, cos_pi_div_four]
  rw [show Real.log π * (1 / 2 : ℝ) = Real.log π / 2 from by ring, exp_half, exp_log pi_pos]
  have h_sqrt : √π * √2 = √(π * 2) := (sqrt_mul (le_of_lt pi_pos) 2).symm
  nlinarith [h_sqrt, sqrt_nonneg π, sqrt_nonneg 2]

private theorem neg_im_cpow_pi_div_I :
    -Complex.im ((↑π / Complex.I) ^ (1/2 : ℂ) / 2) = √(2 * π) / 4 := by
  rw [Complex.div_I]
  rw [Complex.cpow_def_of_ne_zero neg_pi_mul_I_ne_zero]
  rw [show -(↑π * Complex.I) = ↑π * (-Complex.I) from by ring]
  rw [Complex.log_ofReal_mul pi_pos (neg_ne_zero.mpr Complex.I_ne_zero)]
  rw [Complex.log_neg_I]
  have h_exp : (↑(Real.log π) + -(↑π / 2) * Complex.I) * (1/2 : ℂ) =
      ↑(Real.log π / 2) + ↑(-(π / 4)) * Complex.I := by
    push_cast; ring
  rw [h_exp]
  rw [show (2 : ℂ) = ↑(2 : ℝ) from by norm_cast]
  rw [Complex.div_ofReal_im]
  rw [Complex.exp_im]
  simp only [Complex.add_re, Complex.ofReal_re, Complex.mul_re,
    Complex.ofReal_im, Complex.I_re, Complex.I_im,
    Complex.add_im, Complex.mul_im]
  ring_nf
  rw [show π * (-1 / 4 : ℝ) = -(π / 4) from by ring, sin_neg, sin_pi_div_four]
  rw [show Real.log π * (1 / 2 : ℝ) = Real.log π / 2 from by ring, exp_half, exp_log pi_pos]
  have h_sqrt : √π * √2 = √(π * 2) := (sqrt_mul (le_of_lt pi_pos) 2).symm
  nlinarith [h_sqrt, sqrt_nonneg π, sqrt_nonneg 2]

private theorem pi_div_I_in_slitPlane :
    (↑π / (↑(0 : ℝ) + Complex.I) : ℂ) ∈ Complex.slitPlane := by
  simp only [Complex.ofReal_zero, zero_add]
  rw [Complex.mem_slitPlane_iff]; right
  rw [Complex.div_I]
  simp [Complex.neg_im, Complex.ofReal_re]

private theorem continuousAt_re_gaussian :
    ContinuousAt (fun ε : ℝ => Complex.re ((↑π / (↑ε + Complex.I : ℂ)) ^ (1/2 : ℂ) / 2)) 0 := by
  apply Complex.continuous_re.continuousAt.comp
  apply ContinuousAt.div_const
  exact ContinuousAt.cpow
    (ContinuousAt.div continuousAt_const
      (Complex.continuous_ofReal.continuousAt.add continuousAt_const)
      (by intro h; simp [Complex.ext_iff] at h))
    continuousAt_const
    pi_div_I_in_slitPlane

private theorem continuousAt_neg_im_gaussian :
    ContinuousAt (fun ε : ℝ => -Complex.im ((↑π / (↑ε + Complex.I : ℂ)) ^ (1/2 : ℂ) / 2)) 0 := by
  apply ContinuousAt.neg
  apply Complex.continuous_im.continuousAt.comp
  apply ContinuousAt.div_const
  exact ContinuousAt.cpow
    (ContinuousAt.div continuousAt_const
      (Complex.continuous_ofReal.continuousAt.add continuousAt_const)
      (by intro h; simp [Complex.ext_iff] at h))
    continuousAt_const
    pi_div_I_in_slitPlane

private theorem tendsto_re_gaussian_half :
    Tendsto (fun ε : ℝ => Complex.re ((↑π / (↑ε + Complex.I)) ^ (1/2 : ℂ) / 2))
      (nhdsWithin 0 (Ioi 0)) (nhds (√(2 * π) / 4)) := by
  rw [← re_cpow_pi_div_I, show (↑π / Complex.I : ℂ) = ↑π / (↑(0:ℝ) + Complex.I) by simp]
  exact continuousAt_re_gaussian.tendsto.mono_left nhdsWithin_le_nhds

private theorem tendsto_neg_im_gaussian_half :
    Tendsto (fun ε : ℝ => -Complex.im ((↑π / (↑ε + Complex.I)) ^ (1/2 : ℂ) / 2))
      (nhdsWithin 0 (Ioi 0)) (nhds (√(2 * π) / 4)) := by
  rw [← neg_im_cpow_pi_div_I, show (↑π / Complex.I : ℂ) = ↑π / (↑(0:ℝ) + Complex.I) by simp]
  exact continuousAt_neg_im_gaussian.tendsto.mono_left nhdsWithin_le_nhds

/-! ## Step 6: Assembly

The final step combines everything:
1. CauchySeq → convergence to some L (completeness of ℝ)
2. ℕ → ℝ extension (via tail bound)
3. Abel's theorem: regularized integral → L
4. Gaussian computation: regularized integral → √(2π)/4
5. Uniqueness of limits: L = √(2π)/4 -/

/-- **Fresnel sine integral**: lim_{R→∞} ∫₀^R sin(x²) dx = √(2π)/4 -/
theorem tendsto_integral_sin_sq_atTop :
    Tendsto (fun R => ∫ x in (0:ℝ)..R, sin (x ^ 2)) atTop (nhds (√(2 * π) / 4)) := by
  -- Step A: The Cauchy sequence converges to some L
  obtain ⟨L, hL_nat⟩ := cauchySeq_tendsto_of_complete fresnel_sin_cauchy
  -- Step B: Extend from ℕ to ℝ
  have hL := fresnel_sin_tendsto_real L hL_nat
  -- Step C: By Abel's theorem, ∫₀^∞ e^{-εx²} sin(x²) dx → L as ε → 0⁺
  have hAbel := abel_fresnel_sin L hL
  -- Step D: By regularized identity + Gaussian limit, this also → √(2π)/4
  have hGauss : Tendsto (fun ε => ∫ x : ℝ in Ioi 0, exp (-ε * x ^ 2) * sin (x ^ 2))
      (nhdsWithin 0 (Ioi 0)) (nhds (√(2 * π) / 4)) := by
    refine tendsto_neg_im_gaussian_half.congr' ?_
    rw [eventuallyEq_nhdsWithin_iff]
    filter_upwards with ε hε
    exact (regularized_fresnel_sin ε hε).symm
  -- Step E: By uniqueness of limits, L = √(2π)/4
  rwa [tendsto_nhds_unique hAbel hGauss] at hL

/-- **Fresnel cosine integral**: lim_{R→∞} ∫₀^R cos(x²) dx = √(2π)/4 -/
theorem tendsto_integral_cos_sq_atTop :
    Tendsto (fun R => ∫ x in (0:ℝ)..R, cos (x ^ 2)) atTop (nhds (√(2 * π) / 4)) := by
  obtain ⟨L, hL_nat⟩ := cauchySeq_tendsto_of_complete fresnel_cos_cauchy
  have hL := fresnel_cos_tendsto_real L hL_nat
  have hAbel := abel_fresnel_cos L hL
  have hGauss : Tendsto (fun ε => ∫ x : ℝ in Ioi 0, exp (-ε * x ^ 2) * cos (x ^ 2))
      (nhdsWithin 0 (Ioi 0)) (nhds (√(2 * π) / 4)) := by
    refine tendsto_re_gaussian_half.congr' ?_
    rw [eventuallyEq_nhdsWithin_iff]
    filter_upwards with ε hε
    exact (regularized_fresnel_cos ε hε).symm
  rwa [tendsto_nhds_unique hAbel hGauss] at hL

end
