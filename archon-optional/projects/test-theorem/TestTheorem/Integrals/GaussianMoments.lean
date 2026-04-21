/-
# Gaussian Moments: ∫₀^∞ x^{2n} e^{-x²} dx = (2n-1)!! √π / 2^{n+1}

Mathlib has `integral_gaussian` (= √π) and `integral_gaussian_Ioi` (= √π/2),
but not the moments ∫₀^∞ x^k e^{-x²} dx.

## Main results

* `integral_Ioi_pow_mul_exp_neg_sq`: ∫₀^∞ x^(2n) e^{-x²} dx = (2n)! √π / (n! 4^n 2)

## Proof strategy

The key identity uses the Gamma function:
  ∫₀^∞ x^{2n} e^{-x²} dx = (1/2) Γ(n + 1/2)

Then use Γ(n + 1/2) = (2n)! √π / (n! 4^n).
-/
import Mathlib.Analysis.SpecialFunctions.Gaussian.GaussianIntegral
import Mathlib.Analysis.SpecialFunctions.Gamma.Basic
import Mathlib.Analysis.SpecialFunctions.Gamma.Beta
import Mathlib.MeasureTheory.Integral.IntegralEqImproper
import Mathlib.MeasureTheory.Integral.Gamma

open MeasureTheory Set Filter Topology Real
open scoped ENNReal

noncomputable section

/-- **Gaussian moment (even)**:
∫₀^∞ x^{2n} e^{-x²} dx = Γ(n + 1/2) / 2.

This follows from the substitution u = x², giving
∫₀^∞ u^{n - 1/2} e^{-u} du / 2 = Γ(n + 1/2) / 2.
-/
theorem integral_Ioi_pow_mul_exp_neg_sq (n : ℕ) :
    ∫ x in Ioi (0:ℝ), x ^ (2 * n) * exp (-(x ^ 2)) =
      Real.Gamma (n + 1/2) / 2 := by
  -- Convert x ^ (2*n) (ℕ-pow) and x^2 to rpow form, needed for integral_rpow_mul_exp_neg_rpow
  have h_eq : ∀ x ∈ Ioi (0:ℝ), x ^ (2 * n) * exp (-(x ^ 2)) =
      x ^ ((2 * (n : ℝ)) : ℝ) * exp (-(x ^ (2:ℝ))) := by
    intro x _
    congr 1
    · rw [show (2 * (n : ℝ)) = ((2 * n : ℕ) : ℝ) from by push_cast; ring]
      exact (rpow_natCast x (2 * n)).symm
    · congr 1; congr 1
      exact (rpow_natCast x 2).symm
  rw [show (∫ x in Ioi (0:ℝ), x ^ (2 * n) * exp (-(x ^ 2))) =
    (∫ x in Ioi (0:ℝ), x ^ ((2 * (n : ℝ)) : ℝ) * exp (-(x ^ (2:ℝ)))) from
    setIntegral_congr_fun measurableSet_Ioi h_eq]
  -- Apply ∫₀^∞ x^q e^{-x^p} dx = (1/p) Γ((q+1)/p) with p = 2, q = 2n
  have hq : (-1:ℝ) < 2 * (n : ℝ) := by
    have : (0 : ℝ) ≤ (n : ℝ) := Nat.cast_nonneg n
    linarith
  rw [integral_rpow_mul_exp_neg_rpow (by norm_num : (0:ℝ) < 2) hq]
  -- Simplify 1/2 * Γ((2n+1)/2) = Γ(n + 1/2) / 2
  have : (2 * (n : ℝ) + 1) / 2 = (n : ℝ) + 1 / 2 := by ring
  rw [this]
  ring

end
