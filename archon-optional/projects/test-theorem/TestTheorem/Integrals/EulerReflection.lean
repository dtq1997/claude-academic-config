/-
# Euler Reflection Integral: ∫₀^∞ x^{s-1}/(1+x) dx = π/sin(πs)

This is a foundational identity linking the Beta function to Gamma reflection.
Many special integrals are instances of this formula.

## Main result

* `integral_Ioi_rpow_div_one_add`: ∫₀^∞ x^{s-1}/(1+x) dx = π/sin(πs), for 0 < s < 1.

## Proof strategy

The substitution `t = x/(1+x)`, equivalently `x = t/(1-t)`, transforms the integral
over `(0,∞)` into the Beta integral `B(s, 1-s) = ∫₀¹ t^{s-1}(1-t)^{-s} dt`.
Then the chain `B(s,1-s) = Γ(s)Γ(1-s)/Γ(1) = Γ(s)Γ(1-s) = π/sin(πs)` closes the proof,
using `Complex.betaIntegral_eq_Gamma_mul_div` and `Real.Gamma_mul_Gamma_one_sub`.
-/
import Mathlib.Analysis.SpecialFunctions.Gamma.Basic
import Mathlib.Analysis.SpecialFunctions.Gamma.Beta
import Mathlib.MeasureTheory.Integral.IntegralEqImproper

open MeasureTheory Set Filter Topology Real
open scoped ENNReal

noncomputable section

set_option maxHeartbeats 400000 in
/-- **Euler reflection integral**:
∫₀^∞ x^{s-1}/(1+x) dx = π/sin(πs) for 0 < s < 1.

This is equivalent to B(s,1-s) = Γ(s)Γ(1-s) = π/sin(πs). -/
theorem integral_Ioi_rpow_div_one_add {s : ℝ} (hs0 : 0 < s) (hs1 : s < 1) :
    ∫ x in Ioi (0:ℝ), x ^ (s - 1) / (1 + x) = π / sin (π * s) := by
  /- Step A: Change of variables x = t/(1-t).
     The map t ↦ t/(1-t) sends (0,1) bijectively onto (0,∞) with Jacobian 1/(1-t)².
     After simplification the integrand becomes t^(s-1)·(1-t)^(-s). -/
  have hcov : ∫ x in Ioi (0:ℝ), x ^ (s - 1) / (1 + x) =
      ∫ t in Ioo (0:ℝ) 1, t ^ (s - 1) * (1 - t) ^ (-s) := by
    have himage : (fun t : ℝ => t / (1 - t)) '' Ioo 0 1 = Ioi 0 := by
      ext x; simp only [mem_image, mem_Ioo, mem_Ioi]; constructor
      · rintro ⟨t, ⟨ht0, ht1⟩, rfl⟩; exact div_pos ht0 (sub_pos.mpr ht1)
      · intro hx; exact ⟨x / (1 + x), ⟨div_pos hx (by linarith),
          by rw [div_lt_one (by linarith)]; linarith⟩, by field_simp; ring⟩
    have hderiv : ∀ t ∈ Ioo (0:ℝ) 1,
        HasDerivWithinAt (fun t => t / (1 - t)) (1 / (1 - t) ^ 2) (Ioo 0 1) t := by
      intro t ht; apply HasDerivAt.hasDerivWithinAt
      have h1t : (1:ℝ) - t ≠ 0 := by linarith [ht.2]
      have hden : HasDerivAt (fun x : ℝ => 1 - x) (-1) t := by
        simpa using (hasDerivAt_const t (1:ℝ)).sub (hasDerivAt_id t)
      have h3 := (hasDerivAt_id t).div hden h1t
      simp only [id_eq] at h3; convert h3 using 1; field_simp; ring
    have hinj : InjOn (fun t : ℝ => t / (1 - t)) (Ioo 0 1) := by
      intro a ha b hb hab
      rw [div_eq_div_iff (by linarith [ha.2] : (1:ℝ) - a ≠ 0)
          (by linarith [hb.2] : (1:ℝ) - b ≠ 0)] at hab; linarith
    rw [← himage, integral_image_eq_integral_abs_deriv_smul measurableSet_Ioo hderiv hinj]
    exact setIntegral_congr_fun measurableSet_Ioo fun t ht => by
      have ht0 : (0:ℝ) < t := ht.1; have h1t : (0:ℝ) < 1 - t := by linarith [ht.2]
      rw [abs_of_pos (by positivity : (0:ℝ) < 1 / (1 - t) ^ 2), smul_eq_mul,
          show 1 + t / (1 - t) = 1 / (1 - t) from by field_simp; ring,
          div_rpow ht0.le h1t.le,
          show (1 - t : ℝ) ^ (2 : ℕ) = (1 - t) ^ (2 : ℝ) from by norm_cast,
          show (1 : ℝ) / (1 - t) = (1 - t) ^ ((-1 : ℝ)) from by
            rw [rpow_neg h1t.le, rpow_one, one_div],
          div_div, ← rpow_add h1t, show (s - 1 + (-1) : ℝ) = s - 2 from by ring,
          one_div, ← rpow_neg h1t.le, mul_div_assoc',
          mul_comm, mul_div_assoc, ← rpow_sub h1t]; congr 1; ring
  /- Step B: Convert (0,1) set integral to interval integral on [0,1]. -/
  rw [hcov, show ∫ t in Ioo (0:ℝ) 1, t ^ (s - 1) * (1 - t) ^ (-s) =
      ∫ t in (0:ℝ)..1, t ^ (s - 1) * (1 - t) ^ (-s) from by
    rw [intervalIntegral.integral_of_le (by norm_num : (0:ℝ) ≤ 1)]
    exact setIntegral_congr_set Ioo_ae_eq_Ioc]
  /- Step C: Identify with Γ(s)·Γ(1-s) via the complex Beta function,
     then apply the Euler reflection formula. -/
  suffices h : ∫ t in (0:ℝ)..1, t ^ (s - 1) * (1 - t) ^ (-s) =
      Gamma s * Gamma (1 - s) by rw [h, Gamma_mul_Gamma_one_sub]
  -- The complex betaIntegral at real arguments equals the real interval integral.
  have hbeta_real : Complex.betaIntegral ↑s ↑(1 - s) =
      ↑(∫ t in (0:ℝ)..1, t ^ (s - 1) * (1 - t) ^ (-s)) := by
    simp only [Complex.betaIntegral]
    rw [← intervalIntegral.integral_ofReal]
    exact intervalIntegral.integral_congr fun t ht => by
      rw [uIcc_of_le (by norm_num : (0:ℝ) ≤ 1)] at ht
      simp only [Complex.ofReal_mul, Complex.ofReal_cpow ht.1,
                 Complex.ofReal_cpow (by linarith [ht.2] : (0:ℝ) ≤ 1 - t)]
      congr 1 <;> congr 1 <;> push_cast <;> ring
  -- Beta = Gamma product: B(s,1-s) = Γ(s)Γ(1-s)/Γ(1) = Γ(s)Γ(1-s).
  have hbeta_gamma : Complex.betaIntegral (↑s : ℂ) ↑(1 - s) =
      ↑(Gamma s * Gamma (1 - s)) := by
    rw [Complex.betaIntegral_eq_Gamma_mul_div _ _
        (by simp [Complex.ofReal_re]; exact hs0)
        (by simp [Complex.ofReal_re]; linarith),
        show (↑s : ℂ) + ↑(1 - s) = 1 from by push_cast; ring,
        Complex.Gamma_one, div_one, Complex.Gamma_ofReal, Complex.Gamma_ofReal,
        ← Complex.ofReal_mul]
  exact Complex.ofReal_injective (hbeta_real.symm.trans hbeta_gamma)

end
