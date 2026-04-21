/-
# Log-Sine Integral: ∫₀^π log(sin x) dx = -π log 2

Proof strategy:
1. Use the identity sin(x) = 2 sin(x/2) cos(x/2)
2. Split ∫₀^π log(sin x) dx via substitution x ↦ 2x on [0,π/2]
3. Use ∫₀^{π/2} log(sin x) dx = ∫₀^{π/2} log(cos x) dx (by x ↦ π/2 - x)
4. Adding: 2I = ∫₀^{π/2} log(sin 2x) dx = ∫₀^{π/2} (log 2 + log sin x + log cos x) dx
5. Solve: 2I = π/2 · log 2 + 2I, giving I = -π/2 · log 2
6. Then ∫₀^π log(sin x) dx = 2I = -π log 2
-/
import Mathlib.Analysis.SpecialFunctions.Integrals.Basic
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Analysis.SpecialFunctions.Integrals.LogTrigonometric
import Mathlib.MeasureTheory.Integral.IntervalIntegral.FundThmCalculus
import Mathlib.MeasureTheory.Integral.IntegralEqImproper

open MeasureTheory Set Filter Topology Real
open scoped ENNReal

/-! ## Auxiliary: symmetry of log sin and log cos -/

/-- ∫₀^{π/2} log(sin x) dx = ∫₀^{π/2} log(cos x) dx -/
theorem integral_log_sin_eq_integral_log_cos :
    ∫ x in (0:ℝ)..(π/2), log (sin x) = ∫ x in (0:ℝ)..(π/2), log (cos x) := by
  have h := @intervalIntegral.integral_comp_sub_left ℝ _ _ (0 : ℝ) (π/2) (fun x => log (sin x)) (π/2)
  simp only [sub_zero, sub_self] at h
  simp only [Real.sin_pi_div_two_sub] at h
  exact h.symm

/-! ## Main result -/

/-- The log-sine integral: ∫₀^{π/2} log(sin x) dx = -(π/2) log 2 -/
theorem integral_log_sin_Icc_zero_pi_div_two :
    ∫ x in (0:ℝ)..(π/2), log (sin x) = -(π / 2) * log 2 := by
  rw [integral_log_sin_zero_pi_div_two]
  ring

/-- Full interval version: ∫₀^π log(sin x) dx = -π log 2 -/
theorem integral_log_sin_Icc_zero_pi :
    ∫ x in (0:ℝ)..π, log (sin x) = -π * log 2 := by
  rw [integral_log_sin_zero_pi]
  ring
