/-
# Quartic Reciprocal Integral: ∫_{-∞}^∞ 1/(1+x⁴) dx = π/√2

## Proof strategy (via Gamma reflection)

1. By symmetry: ∫_ℝ = 2 ∫₀^∞ 1/(1+x⁴) dx  (using integral_comp_abs)
2. Substitution u = x⁴: ∫₀^∞ 1/(1+x⁴) dx = (1/4) ∫₀^∞ u^{-3/4}/(1+u) du
   (using integral_comp_rpow_Ioi_of_pos with p=1/4)
3. Key identity: ∫₀^∞ u^{s-1}/(1+u) du = Γ(s)Γ(1-s) = π/sin(πs)
   (via Fubini and the Gamma integral; see integral_Ioi_rpow_div_one_add)
4. With s = 1/4: π/sin(π/4) = π/(√2/2) = π√2
5. Result: 2 · (1/4) · π√2 = π√2/2 = π/√2
-/
import Mathlib.Analysis.SpecialFunctions.Integrals.Basic
import Mathlib.Analysis.SpecialFunctions.Gamma.Basic
import Mathlib.Analysis.SpecialFunctions.Gamma.Beta
import Mathlib.MeasureTheory.Integral.IntegralEqImproper
import Mathlib.Analysis.SpecialFunctions.ImproperIntegrals
import TestTheorem.Integrals.EulerReflection

open MeasureTheory Set Filter Topology Real
open scoped ENNReal

noncomputable section

/-! ## Integrability -/

/-- `x ↦ 1/(1+x^4)` is integrable on `ℝ`, by comparison with `1/(1+x^2)`.

The bound `1/(1+x⁴) ≤ 2/(1+x²)` follows from `2x⁴ - x² + 1 > 0` (discriminant = -7 < 0). -/
private lemma integrable_inv_one_add_pow_four :
    Integrable (fun x : ℝ => 1 / (1 + x ^ 4)) := by
  apply Integrable.mono (integrable_inv_one_add_sq.const_mul 2)
  · exact (measurable_const.div
      (measurable_const.add (measurable_id'.pow_const 4))).aestronglyMeasurable
  · refine Filter.Eventually.of_forall (fun x => ?_)
    simp only [one_div]
    show ‖(1 + x ^ 4)⁻¹‖ ≤ ‖2 * (1 + x ^ 2)⁻¹‖
    rw [Real.norm_of_nonneg (inv_nonneg.mpr (by positivity : (0 : ℝ) ≤ 1 + x ^ 4))]
    rw [Real.norm_of_nonneg (by positivity : (0 : ℝ) ≤ 2 * (1 + x ^ 2)⁻¹)]
    exact (inv_le_comm₀ (by positivity) (by positivity)).mpr (by
      rw [mul_inv_rev, inv_inv]
      nlinarith [sq_nonneg (x ^ 2), sq_nonneg x])

/-- `x ↦ 1/(1+x^4)` is integrable on `(0,∞)`. -/
private lemma integrableOn_Ioi_inv_one_add_pow_four :
    IntegrableOn (fun x : ℝ => 1 / (1 + x ^ 4)) (Ioi 0) :=
  integrable_inv_one_add_pow_four.integrableOn

/-! ## Main computation

Uses `integral_Ioi_rpow_div_one_add` from `EulerReflection.lean` as a building block. -/

/-- The half-line integral: `∫₀^∞ 1/(1+x⁴) dx = π/(2√2)`.

Uses the substitution `u = x⁴` (via `integral_comp_rpow_Ioi_of_pos` with `p = 1/4`)
to reduce to `(1/4) ∫₀^∞ u^{-3/4}/(1+u) du`, then applies the Gamma reflection formula. -/
private lemma integral_Ioi_inv_one_add_pow_four :
    ∫ x in Ioi (0 : ℝ), 1 / (1 + x ^ 4) = π / (2 * √2) := by
  -- Step 1: Substitution u = x^{1/4} via integral_comp_rpow_Ioi_of_pos.
  -- With p = 1/4 and g(y) = 1/(1+y^4), we get:
  -- ∫₀^∞ (1/4 · x^{-3/4}) · g(x^{1/4}) dx = ∫₀^∞ g(y) dy
  have hsub := @integral_comp_rpow_Ioi_of_pos ℝ _ _
    (fun y : ℝ => 1 / (1 + y ^ 4)) (1 / 4 : ℝ) (by positivity)
  -- Simplify the LHS: for x > 0, (x^{1/4})^4 = x, so g(x^{1/4}) = 1/(1+x)
  have simp_integrand : ∀ x : ℝ, x ∈ Ioi (0 : ℝ) →
      (1 / 4 * x ^ ((1 : ℝ) / 4 - 1)) •
        ((fun y : ℝ => 1 / (1 + y ^ 4)) (x ^ ((1 : ℝ) / 4))) =
      (1 / 4) * (x ^ ((1 : ℝ) / 4 - 1) / (1 + x)) := by
    intro x hx
    simp only [smul_eq_mul]
    have hxpos : 0 < x := hx
    have : (x ^ ((1 : ℝ) / 4)) ^ (4 : ℕ) = x := by
      rw [← rpow_natCast (x ^ ((1 : ℝ) / 4)) 4, ← rpow_mul hxpos.le]
      norm_num
    rw [this]; ring
  rw [setIntegral_congr_fun measurableSet_Ioi simp_integrand] at hsub
  -- Now hsub : (1/4) * ∫₀^∞ x^{1/4-1}/(1+x) dx = ∫₀^∞ 1/(1+y^4) dy
  rw [← hsub, integral_const_mul]
  -- Step 2: Apply the key identity with s = 1/4
  rw [integral_Ioi_rpow_div_one_add (1 / 4) (by positivity) (by norm_num)]
  -- Step 3: Apply the Gamma reflection formula: Γ(1/4)·Γ(3/4) = π/sin(π/4)
  rw [Real.Gamma_mul_Gamma_one_sub (1 / 4 : ℝ)]
  -- Step 4: Compute sin(π/4) = √2/2
  rw [show π * (1 / 4 : ℝ) = π / 4 from by ring]
  rw [sin_pi_div_four]
  -- Step 5: Algebra: (1/4) · (π / (√2/2)) = π/(2√2)
  have hsqrt2 : (√2 : ℝ) ≠ 0 := Real.sqrt_ne_zero'.mpr (by norm_num)
  field_simp
  ring

/-- **Quartic reciprocal integral**: `∫_{-∞}^∞ 1/(1+x⁴) dx = π/√2`. -/
theorem integral_inv_one_add_pow_four :
    ∫ x : ℝ, 1 / (1 + x ^ 4) = π / √2 := by
  -- By evenness: 1/(1+x^4) = 1/(1+|x|^4), so ∫_ℝ f = 2 ∫_{Ioi 0} f
  have step1 : ∫ x : ℝ, 1 / (1 + x ^ 4) =
      2 * ∫ x in Ioi (0 : ℝ), 1 / (1 + x ^ 4) := by
    have h1 := @integral_comp_abs (fun t : ℝ => 1 / (1 + t ^ 4))
    -- h1 : ∫ x, 1/(1+|x|^4) = 2 * ∫ x in Ioi 0, 1/(1+x^4)
    convert h1 using 2
    ext x; congr 1; congr 1
    rw [← Even.pow_abs ⟨2, rfl⟩]
  rw [step1, integral_Ioi_inv_one_add_pow_four]
  -- Algebra: 2 · π/(2√2) = π/√2
  ring

end
