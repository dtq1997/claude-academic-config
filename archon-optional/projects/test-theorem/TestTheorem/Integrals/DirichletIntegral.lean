/-
# Dirichlet Integral: lim_{R→∞} ∫₀^R sin(x)/x dx = π/2

## Proof strategy: Finite-rectangle Fubini + DCT

See module docstring for details.
-/
import Mathlib.Analysis.SpecialFunctions.Integrals.Basic
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Arctan
import Mathlib.Analysis.SpecialFunctions.Trigonometric.ArctanDeriv
import Mathlib.MeasureTheory.Integral.IntegralEqImproper
import Mathlib.Analysis.SpecialFunctions.ImproperIntegrals
import Mathlib.MeasureTheory.Integral.IntervalIntegral.FundThmCalculus
import Mathlib.MeasureTheory.Integral.Prod
import Mathlib.MeasureTheory.Integral.ExpDecay

open MeasureTheory Set Filter Topology Real intervalIntegral
open scoped ENNReal

noncomputable section

/-! ## Step 1: ∫₀ᴿ e^{-tx} sin(x) dx via FTC

Define F(x) = -(e^{-tx} (t sin x + cos x)) / (1+t²).
Then F'(x) = e^{-tx} sin(x), so ∫₀ᴿ e^{-tx} sin(x) dx = F(R) - F(0). -/

/-- The antiderivative of e^{-tx} sin(x). -/
private def F (t : ℝ) (x : ℝ) : ℝ :=
  -(exp (-t * x) * (t * sin x + cos x)) / (1 + t ^ 2)

private lemma F_zero (t : ℝ) : F t 0 = -1 / (1 + t ^ 2) := by
  simp [F, sin_zero, cos_zero, exp_zero]

private lemma hasDerivAt_F {t : ℝ} (ht : t ≠ 0) (x : ℝ) :
    HasDerivAt (F t) (exp (-t * x) * sin x) x := by
  unfold F
  have h1t : (1 : ℝ) + t ^ 2 ≠ 0 := by positivity
  -- d/dx[e^{-tx}] = e^{-tx} · (-t)
  have h_exp : HasDerivAt (fun y => exp (-t * y)) (exp (-t * x) * (-t)) x := by
    have hd : HasDerivAt (fun y => -t * y) (-t * 1) x :=
      (hasDerivAt_id x).const_mul (-t)
    simp only [mul_one] at hd
    exact hd.exp
  -- d/dx[t sin x + cos x] = t cos x - sin x
  have h_trig : HasDerivAt (fun y => t * sin y + cos y) (t * cos x - sin x) x :=
    ((hasDerivAt_sin x).const_mul t).add (hasDerivAt_cos x)
  -- Product rule: d/dx[e^{-tx}(t sin x + cos x)]
  have h_prod := h_exp.mul h_trig
  -- Now divide by -(1+t²)
  have h_neg := h_prod.neg.div_const (1 + t ^ 2)
  convert h_neg using 1
  field_simp
  ring

/-- ∫₀ᴿ e^{-tx} sin(x) dx = (1 - e^{-tR}(t sin R + cos R)) / (1+t²) -/
theorem integral_exp_neg_mul_sin {t : ℝ} (ht : 0 < t) {R : ℝ} (_hR : 0 ≤ R) :
    ∫ x in (0:ℝ)..R, exp (-t * x) * sin x =
      (1 - exp (-t * R) * (t * sin R + cos R)) / (1 + t ^ 2) := by
  have h1t : (1 : ℝ) + t ^ 2 ≠ 0 := by positivity
  have hint : IntervalIntegrable (fun x => exp (-t * x) * sin x) volume 0 R := by
    apply Continuous.intervalIntegrable
    fun_prop
  rw [integral_eq_sub_of_hasDerivAt (fun x _ => hasDerivAt_F (ne_of_gt ht) x) hint]
  simp only [F_zero]
  unfold F
  field_simp
  ring

/-! ## Step 2: ∫₀ᵀ e^{-tx} dt = (1 - e^{-Tx})/x -/

/-- For x > 0, ∫₀ᵀ e^{-tx} dt = (1 - e^{-Tx})/x -/
theorem integral_exp_neg_tvar {x T : ℝ} (hx : 0 < x) (_hT : 0 ≤ T) :
    ∫ t in (0:ℝ)..T, exp (-t * x) = (1 - exp (-T * x)) / x := by
  have hx' : x ≠ 0 := ne_of_gt hx
  have hderiv : ∀ s ∈ uIcc 0 T,
      HasDerivAt (fun s => -exp (-s * x) / x) (exp (-s * x)) s := by
    intro s _
    have hd : HasDerivAt (fun s => -s * x) (-x) s := by
      have h := (hasDerivAt_id s).neg.mul_const x
      simp only [neg_mul, one_mul] at h
      exact h
    have h1 : HasDerivAt (fun s => exp (-s * x)) (exp (-s * x) * (-x)) s := by
      convert hd.exp using 1
    have h2 := h1.neg.div_const x
    convert h2 using 1
    field_simp
  have hint : IntervalIntegrable (fun s => exp (-s * x)) volume 0 T := by
    apply Continuous.intervalIntegrable
    fun_prop
  rw [integral_eq_sub_of_hasDerivAt hderiv hint]
  simp [exp_zero]
  field_simp
  ring

/-! ## Step 3: Fubini identity on [0,R] × [0,T]

Key identity: ∫₀^R sin(x)(1-e^{-Tx})/x dx = ∫₀^T (1-e^{-tR}(t sin R + cos R))/(1+t²) dt

This follows from Fubini's theorem: the double integral
  ∫₀^R ∫₀^T e^{-tx} sin(x) dt dx = ∫₀^T ∫₀^R e^{-tx} sin(x) dx dt
where the inner integrals are computed by Steps 1 and 2. -/

/-- Fubini identity on the finite rectangle [0,R] × [0,T].
This is the core identity relating the regularized sinc integral to arctan-type integrals.
Proof: Fubini + the two explicit antiderivatives from Steps 1-2. -/
private theorem fubini_rectangle {R T : ℝ} (hR : 0 < R) (hT : 0 < T) :
    ∫ x in (0:ℝ)..R, sin x * (1 - exp (-T * x)) / x =
      ∫ t in (0:ℝ)..T,
        (1 - exp (-t * R) * (t * sin R + cos R)) / (1 + t ^ 2) := by
  -- Step 1: LHS = ∫₀ᴿ (∫₀ᵀ e^{-tx} sin(x) dt) dx
  have h_lhs : ∫ x in (0:ℝ)..R, sin x * (1 - exp (-T * x)) / x =
      ∫ x in (0:ℝ)..R, ∫ t in (0:ℝ)..T, exp (-t * x) * sin x := by
    rw [integral_of_le (le_of_lt hR), integral_of_le (le_of_lt hR)]
    apply setIntegral_congr_fun measurableSet_Ioc
    intro x hx
    show sin x * (1 - exp (-T * x)) / x = ∫ t in (0:ℝ)..T, exp (-t * x) * sin x
    rw [intervalIntegral.integral_mul_const, integral_exp_neg_tvar hx.1 (le_of_lt hT)]
    ring
  -- Step 2: RHS = ∫₀ᵀ (∫₀ᴿ e^{-tx} sin(x) dx) dt
  have h_rhs : ∫ t in (0:ℝ)..T,
      (1 - exp (-t * R) * (t * sin R + cos R)) / (1 + t ^ 2) =
      ∫ t in (0:ℝ)..T, ∫ x in (0:ℝ)..R, exp (-t * x) * sin x := by
    rw [integral_of_le (le_of_lt hT), integral_of_le (le_of_lt hT)]
    apply setIntegral_congr_fun measurableSet_Ioc
    intro t ht
    show (1 - exp (-t * R) * (t * sin R + cos R)) / (1 + t ^ 2) =
      ∫ x in (0:ℝ)..R, exp (-t * x) * sin x
    rw [integral_exp_neg_mul_sin ht.1 (le_of_lt hR)]
  -- Step 3: Fubini — swap the order of integration
  rw [h_lhs, h_rhs]
  simp_rw [integral_of_le (le_of_lt hR), integral_of_le (le_of_lt hT)]
  set f : ℝ × ℝ → ℝ := fun p => exp (-p.2 * p.1) * sin p.1
  have hf_int : IntegrableOn f (Ioc 0 R ×ˢ Ioc 0 T) (volume.prod volume) := by
    rw [← Measure.volume_eq_prod]
    exact (ContinuousOn.integrableOn_compact (isCompact_Icc.prod isCompact_Icc)
      ((continuous_exp.comp (continuous_snd.neg.mul continuous_fst)).mul
        (continuous_sin.comp continuous_fst)).continuousOn).mono_set
      (Set.prod_mono Ioc_subset_Icc_self Ioc_subset_Icc_self)
  have hf_swap : IntegrableOn (fun w : ℝ × ℝ => f w.swap)
      (Ioc 0 T ×ˢ Ioc 0 R) (volume.prod volume) := by
    rw [← Measure.volume_eq_prod]
    exact (ContinuousOn.integrableOn_compact (isCompact_Icc.prod isCompact_Icc)
      ((continuous_exp.comp (continuous_fst.neg.mul continuous_snd)).mul
        (continuous_sin.comp continuous_snd)).continuousOn).mono_set
      (Set.prod_mono Ioc_subset_Icc_self Ioc_subset_Icc_self)
  rw [← setIntegral_prod f hf_int, ← setIntegral_prod_swap (Ioc 0 R) (Ioc 0 T) f,
      setIntegral_prod _ hf_swap]
  simp only [f, Prod.swap]

/-! ## Step 4: Taking T → ∞ on both sides of Fubini

### LHS: ∫₀^R sin(x)(1-e^{-Tx})/x dx → ∫₀^R sin(x)/x dx

As T → ∞, e^{-Tx} → 0 for x > 0, so the integrand converges to sin(x)/x.
We apply DCT on the compact interval [0,R] with bound 1 (since |sin(x)/x| ≤ 1
and |1-e^{-Tx}| ≤ 1 for T,x ≥ 0).

### RHS: use integral_Ioi_inv_one_add_sq
-/

/-- The LHS of the Fubini identity converges to ∫₀^R sin(x)/x dx as T → ∞.
Proof: DCT on [0,R] with dominator 1. -/
private theorem tendsto_lhs {R : ℝ} (hR : 0 < R) :
    Tendsto (fun T => ∫ x in (0:ℝ)..R, sin x * (1 - exp (-T * x)) / x)
      atTop (nhds (∫ x in (0:ℝ)..R, sin x / x)) := by
  -- We use DCT on the compact interval [0,R].
  -- The integrand F_T(x) = sin(x) * (1-e^{-Tx}) / x converges pointwise to sin(x)/x
  -- and is bounded by 1 (since |sin(x)/x| ≤ 1 and |1-e^{-Tx}| ≤ 1 for T,x ≥ 0).
  apply intervalIntegral.tendsto_integral_filter_of_dominated_convergence (fun _ => 1)
  · -- AEStronglyMeasurable: each F_T is continuous hence measurable
    exact .of_forall fun T => by
      apply ContinuousOn.aestronglyMeasurable
      · apply ContinuousOn.div
        · exact (continuous_sin.continuousOn.mul
            (continuousOn_const.sub (by fun_prop)))
        · exact continuous_id.continuousOn
        · intro x hx
          exact ne_of_mem_of_not_mem hx (by simp [le_of_lt hR])
      · exact measurableSet_uIoc
  · -- Bound: ‖F_T(x)‖ ≤ 1 (for T ≥ 0)
    filter_upwards [eventually_ge_atTop (0:ℝ)] with T hT
    exact ae_of_all _ fun x hx => by
      rw [uIoc_of_le (le_of_lt hR)] at hx
      have hx_pos : 0 < x := hx.1
      rw [norm_div, norm_mul, Real.norm_eq_abs, Real.norm_eq_abs, Real.norm_eq_abs]
      have h1 : |sin x| ≤ |x| := abs_sin_le_abs
      have h2 : 0 ≤ exp (-T * x) := exp_nonneg _
      have h3 : exp (-T * x) ≤ 1 := by
        rw [exp_le_one_iff, neg_mul]
        exact neg_nonpos.mpr (mul_nonneg hT (le_of_lt hx_pos))
      have h4 : |1 - exp (-T * x)| ≤ 1 := by
        rw [abs_le]
        constructor
        · linarith
        · linarith
      have hx_ne : |x| ≠ 0 := ne_of_gt (abs_pos.mpr (ne_of_gt hx_pos))
      calc |sin x| * |1 - exp (-T * x)| / |x|
          ≤ |x| * 1 / |x| := by
            apply div_le_div_of_nonneg_right
              (mul_le_mul h1 h4 (abs_nonneg _) (abs_nonneg _))
            (exact_mod_cast le_of_lt (abs_pos.mpr (ne_of_gt hx_pos)))
        _ = 1 := by rw [mul_one, div_self hx_ne]
  · -- Bound is integrable
    exact _root_.intervalIntegrable_const
  · -- Pointwise limit: sin(x) * (1-e^{-Tx})/x → sin(x)/x as T → ∞
    exact ae_of_all _ fun x hx => by
      rw [uIoc_of_le (le_of_lt hR)] at hx
      have hx_pos : 0 < x := hx.1
      have hx_ne : x ≠ 0 := ne_of_gt hx_pos
      -- e^{-Tx} → 0 as T → ∞ (for x > 0)
      have h_exp : Tendsto (fun T => exp (-T * x)) atTop (nhds 0) := by
        rw [tendsto_exp_comp_nhds_zero]
        have : Tendsto (fun T : ℝ => -T) atTop atBot := tendsto_neg_atTop_atBot
        exact (this.atBot_mul_const hx_pos).congr (fun T => by ring)
      -- 1 - e^{-Tx} → 1
      have h_one : Tendsto (fun T => 1 - exp (-T * x)) atTop (nhds (1 - 0)) :=
        tendsto_const_nhds.sub h_exp
      rw [sub_zero] at h_one
      -- sin(x) * (1-e^{-Tx}) → sin(x) * 1 = sin(x)
      have h_mul : Tendsto (fun T => sin x * (1 - exp (-T * x))) atTop (nhds (sin x)) := by
        convert tendsto_const_nhds.mul h_one using 1
        simp [mul_one]
      -- Divide by x
      have h_div : Tendsto (fun T => sin x * (1 - exp (-T * x)) / x) atTop
          (nhds (sin x / x)) :=
        h_mul.div tendsto_const_nhds hx_ne
      exact h_div

/-- The error integrand is integrable on Ioi 0 for R > 0. -/
private theorem integrable_error {R : ℝ} (hR : 0 < R) :
    IntegrableOn (fun t => exp (-t * R) * (t * sin R + cos R) / (1 + t ^ 2))
      (Set.Ioi 0) volume := by
  -- Bound: |f(t)| ≤ (|sin R| + |cos R|) · e^{-Rt}, then use exp integrability
  have hexp_int : IntegrableOn (fun t => exp (-R * t)) (Set.Ioi 0) volume :=
    integrableOn_exp_mul_Ioi (neg_neg_of_pos hR) 0
  have hbound_int : IntegrableOn (fun t => (|sin R| + |cos R|) * exp (-R * t))
      (Set.Ioi 0) volume :=
    hexp_int.const_mul _
  apply Integrable.mono' hbound_int
  · -- AEStronglyMeasurable: continuous function
    exact ((Continuous.div (by fun_prop) (by fun_prop)
      (fun t => by positivity)).aestronglyMeasurable).restrict
  · -- Norm bound: ‖f(t)‖ ≤ (|sin R| + |cos R|) · e^{-Rt}
    filter_upwards [ae_restrict_mem measurableSet_Ioi] with t ht
    simp only [Set.mem_Ioi] at ht
    rw [norm_div, norm_mul, Real.norm_eq_abs, Real.norm_eq_abs,
        abs_of_pos (exp_pos _), Real.norm_eq_abs,
        abs_of_pos (by positivity : (0 : ℝ) < 1 + t ^ 2)]
    have h1t : (0 : ℝ) < 1 + t ^ 2 := by positivity
    rw [div_le_iff₀ h1t]
    calc exp (-t * R) * |t * sin R + cos R|
        ≤ exp (-t * R) * (|sin R| * t + |cos R|) := by
          apply mul_le_mul_of_nonneg_left _ (le_of_lt (exp_pos _))
          calc |t * sin R + cos R|
              ≤ |t * sin R| + |cos R| := abs_add_le _ _
            _ = |sin R| * t + |cos R| := by rw [abs_mul, abs_of_pos ht]; ring
      _ ≤ exp (-t * R) * ((|sin R| + |cos R|) * (1 + t ^ 2)) := by
          apply mul_le_mul_of_nonneg_left _ (le_of_lt (exp_pos _))
          have h1 : |sin R| * t ≤ |sin R| * (1 + t ^ 2) := by
            apply mul_le_mul_of_nonneg_left _ (abs_nonneg _)
            nlinarith [sq_nonneg t]
          have h2 : |cos R| ≤ |cos R| * (1 + t ^ 2) := by
            apply le_mul_of_one_le_right (abs_nonneg _)
            linarith [sq_nonneg t]
          linarith
      _ = (|sin R| + |cos R|) * exp (-R * t) * (1 + t ^ 2) := by ring_nf

private theorem tendsto_rhs {R : ℝ} (hR : 0 < R) :
    Tendsto (fun T => ∫ t in (0:ℝ)..T,
        (1 - exp (-t * R) * (t * sin R + cos R)) / (1 + t ^ 2))
      atTop (nhds (π / 2 -
        ∫ t in Set.Ioi (0:ℝ),
          exp (-t * R) * (t * sin R + cos R) / (1 + t ^ 2))) := by
  -- Rewrite the integral
  have h_eq : ∀ T, ∫ t in (0:ℝ)..T,
      (1 - exp (-t * R) * (t * sin R + cos R)) / (1 + t ^ 2) =
    arctan T - ∫ t in (0:ℝ)..T, exp (-t * R) * (t * sin R + cos R) / (1 + t ^ 2) := by
    intro T
    have hint1 : IntervalIntegrable (fun t => (1 + t ^ 2)⁻¹) volume 0 T :=
      intervalIntegral.intervalIntegrable_inv_one_add_sq
    have hint2 : IntervalIntegrable
        (fun t => exp (-t * R) * (t * sin R + cos R) / (1 + t ^ 2)) volume 0 T := by
      apply ContinuousOn.intervalIntegrable
      apply ContinuousOn.div (by fun_prop) (by fun_prop)
      intro t _; positivity
    have h1 := intervalIntegral.integral_sub hint1 hint2
    -- h1 : ∫ (1+t²)⁻¹ - g(t) = ∫ (1+t²)⁻¹ - ∫ g(t)
    rw [integral_inv_one_add_sq, arctan_zero, sub_zero] at h1
    rw [← h1]
    congr 1 with t
    have h1t : (1 : ℝ) + t ^ 2 ≠ 0 := by positivity
    field_simp
  simp_rw [h_eq]
  -- arctan(T) → π/2 and ∫₀^T error → ∫₀^∞ error
  apply Tendsto.sub
  · -- arctan(T) → π/2
    exact Real.tendsto_arctan_atTop.mono_right nhdsWithin_le_nhds
  · -- ∫₀^T error → ∫₀^∞ error
    exact intervalIntegral_tendsto_integral_Ioi 0 (integrable_error hR) tendsto_id

/-! ## Step 5: The error term E(R) → 0 as R → ∞

E(R) = ∫₀^∞ e^{-tR}(t sin R + cos R)/(1+t²) dt

We bound |E(R)| ≤ ∫₀^∞ e^{-tR}(t+1)/(1+t²) dt.
The integrand is dominated by (t+1)/(1+t²) (which is integrable on [0,∞))
and converges pointwise to 0. By DCT, E(R) → 0. -/

/-- (t+1)·e^{-t} is integrable on Ioi 0. Used as a dominator. -/
private theorem integrable_bound :
    IntegrableOn (fun t : ℝ => (t + 1) * exp (-t)) (Set.Ioi 0) volume := by
  apply integrable_of_isBigO_exp_neg (b := 1/2) (a := 0) (by positivity)
  · fun_prop
  · apply Asymptotics.IsBigO.of_bound 3
    filter_upwards [eventually_ge_atTop (0:ℝ)] with t ht
    simp only [Real.norm_eq_abs]
    rw [abs_of_nonneg (by positivity), abs_of_pos (exp_pos _)]
    rw [show -(1/2 : ℝ) * t = -(t/2) from by ring]
    rw [show (t + 1) * exp (-t) = (t + 1) * exp (-(t/2)) * exp (-(t/2)) from by
      rw [mul_assoc, ← exp_add]; ring_nf]
    calc (t + 1) * exp (-(t / 2)) * exp (-(t / 2))
        ≤ 3 * exp (t / 2) * exp (-(t / 2)) * exp (-(t / 2)) := by
          apply mul_le_mul_of_nonneg_right _ (le_of_lt (exp_pos _))
          apply mul_le_mul_of_nonneg_right _ (le_of_lt (exp_pos _))
          nlinarith [add_one_le_exp (t/2)]
      _ = 3 * exp (-(t / 2)) := by
          congr 1; rw [mul_assoc, ← exp_add]; simp [add_neg_cancel]

/-- The error term tends to 0 as R → ∞.

Bound: |e^{-tR}(t sin R + cos R)/(1+t²)| ≤ e^{-tR}(t+1)/(1+t²) ≤ (t+1)e^{-t} for R ≥ 1.
The dominator (t+1)e^{-t} is integrable, and the integrand → 0 pointwise. -/
private theorem tendsto_error :
    Tendsto (fun R => ∫ t in Set.Ioi (0:ℝ),
      exp (-t * R) * (t * sin R + cos R) / (1 + t ^ 2))
      atTop (nhds 0) := by
  -- Use DCT on μ = volume.restrict (Ioi 0) with dominator (1+t²)⁻¹.
  -- Key insight: (t+1)*exp(-t) ≤ 1 for all t (from add_one_le_exp),
  -- so for R ≥ 1 and t > 0: ‖F R t‖ ≤ exp(-t)(t+1)/(1+t²) ≤ (1+t²)⁻¹.
  have h_bound : ∀ {R t : ℝ}, 1 ≤ R → 0 < t →
      ‖exp (-t * R) * (t * sin R + cos R) / (1 + t ^ 2)‖ ≤ (1 + t ^ 2)⁻¹ := by
    intro R t hR ht
    have h1t : (0 : ℝ) < 1 + t ^ 2 := by positivity
    simp only [norm_div, norm_mul, Real.norm_eq_abs, abs_of_pos h1t]
    rw [(one_div (1 + t ^ 2)).symm]
    apply div_le_div_of_nonneg_right _ (le_of_lt h1t)
    calc |exp (-t * R)| * |t * sin R + cos R|
        = exp (-t * R) * |t * sin R + cos R| := by rw [abs_of_pos (exp_pos _)]
      _ ≤ exp (-t * R) * (t + 1) := by
          apply mul_le_mul_of_nonneg_left _ (le_of_lt (exp_pos _))
          calc |t * sin R + cos R|
              ≤ |t * sin R| + |cos R| := abs_add_le _ _
            _ ≤ t * |sin R| + |cos R| := by
                gcongr; rw [abs_mul]
                exact le_of_eq (congrArg (· * |sin R|) (abs_of_pos ht))
            _ ≤ t * 1 + 1 := by
                gcongr; exact abs_sin_le_one R; exact abs_cos_le_one R
            _ = t + 1 := by ring
      _ ≤ exp (-t) * (t + 1) := by
          apply mul_le_mul_of_nonneg_right _ (by linarith)
          exact exp_le_exp.mpr (by nlinarith)
      _ = (t + 1) * exp (-t) := by ring
      _ ≤ 1 := by
          have : t + 1 ≤ exp t := add_one_le_exp t
          rw [exp_neg, mul_inv_le_iff₀ (exp_pos t)]; linarith
  -- Apply DCT with f = 0, bound = (1+t²)⁻¹
  have key := @MeasureTheory.tendsto_integral_filter_of_dominated_convergence
    ℝ ℝ _ _ _ (volume.restrict (Ioi (0:ℝ))) ℝ (atTop : Filter ℝ) _
    (fun R (t : ℝ) => exp (-t * R) * (t * sin R + cos R) / (1 + t ^ 2))
    (fun _ => (0 : ℝ))
    (fun t => (1 + t ^ 2)⁻¹)
    -- AEStronglyMeasurable
    (.of_forall fun R => by
      apply Continuous.aestronglyMeasurable
      exact Continuous.div (by fun_prop) (by fun_prop) (fun t => by positivity))
    -- Norm bound: for R ≥ 1, ‖F R t‖ ≤ (1+t²)⁻¹ a.e. on Ioi 0
    (by filter_upwards [eventually_ge_atTop (1 : ℝ)] with R hR
        rw [ae_restrict_iff' measurableSet_Ioi]
        exact ae_of_all _ fun t ht => h_bound hR ht)
    -- Integrability of bound
    (integrable_inv_one_add_sq.integrableOn)
    -- Pointwise convergence: for t > 0, F R t → 0 as R → ∞
    (by rw [ae_restrict_iff' measurableSet_Ioi]
        exact ae_of_all _ fun t ht => by
          -- Write F R t = exp(-tR) * [(t sin R + cos R)/(1+t²)]
          -- exp(-tR) → 0, second factor is bounded → product → 0
          have h_eq : (fun R => exp (-t * R) * (t * sin R + cos R) / (1 + t ^ 2)) =
              fun R => exp (-t * R) * ((t * sin R + cos R) / (1 + t ^ 2)) := by ext R; ring
          rw [h_eq]
          apply Filter.Tendsto.zero_mul_isBoundedUnder_le
          · exact tendsto_exp_atBot.comp
              (Filter.Tendsto.const_mul_atTop_of_neg (neg_lt_zero.mpr ht) tendsto_id)
          · unfold IsBoundedUnder IsBounded
            use (t + 1) / (1 + t ^ 2)
            rw [Filter.eventually_map]
            exact Eventually.of_forall fun R => by
              show ‖(t * sin R + cos R) / (1 + t ^ 2)‖ ≤ (t + 1) / (1 + t ^ 2)
              rw [norm_div, Real.norm_eq_abs (1 + t ^ 2), abs_of_pos (by positivity)]
              apply div_le_div_of_nonneg_right _ (by positivity)
              calc ‖t * sin R + cos R‖
                  = |t * sin R + cos R| := Real.norm_eq_abs _
                _ ≤ |t * sin R| + |cos R| := abs_add_le _ _
                _ ≤ t * 1 + 1 := by
                    gcongr
                    · rw [abs_mul, abs_of_pos ht]
                      exact mul_le_mul_of_nonneg_left (abs_sin_le_one R) (le_of_lt ht)
                    · exact abs_cos_le_one R
                _ = t + 1 := by ring)
  simp only [MeasureTheory.integral_zero] at key
  exact key

/-! ## Step 6: Assembling the proof -/

/-- Key intermediate: for R > 0, ∫₀^R sin(x)/x dx = π/2 - E(R). -/
private theorem integral_sinc_eq {R : ℝ} (hR : 0 < R) :
    ∫ x in (0:ℝ)..R, sin x / x =
      π / 2 - ∫ t in Set.Ioi (0:ℝ),
        exp (-t * R) * (t * sin R + cos R) / (1 + t ^ 2) := by
  -- Both sides are the limit of the same sequence (by Fubini),
  -- so they must be equal.
  have h_fubini : ∀ T > 0,
      ∫ x in (0:ℝ)..R, sin x * (1 - exp (-T * x)) / x =
        ∫ t in (0:ℝ)..T,
          (1 - exp (-t * R) * (t * sin R + cos R)) / (1 + t ^ 2) :=
    fun T hT => fubini_rectangle hR hT
  -- LHS of Fubini → ∫₀^R sin(x)/x dx
  have h_lhs := tendsto_lhs hR
  -- RHS of Fubini → π/2 - E(R)
  have h_rhs := tendsto_rhs hR
  -- Since both sides of the Fubini identity converge, and the identity
  -- holds for all T > 0, the limits must be equal.
  -- We use tendsto_nhds_unique applied to a common subsequence.
  -- Filter through T = n (natural numbers)
  -- Use subsequence T = n + 1 (positive naturals)
  have h_seq : Tendsto (fun n : ℕ => ((n : ℝ) + 1)) atTop atTop :=
    tendsto_atTop_atTop.mpr fun b => ⟨⌈b⌉₊, fun n hn => by
      calc b ≤ ↑⌈b⌉₊ := Nat.le_ceil b
        _ ≤ (n : ℝ) := Nat.cast_le.mpr hn
        _ ≤ n + 1 := le_add_of_nonneg_right (by positivity)⟩
  exact tendsto_nhds_unique
    (h_lhs.comp h_seq)
    ((h_rhs.comp h_seq).congr
      (fun n => (h_fubini ((n : ℝ) + 1) (by positivity)).symm))

/-- **Dirichlet integral**: lim_{R→∞} ∫₀ᴿ sin(x)/x dx = π/2 -/
theorem tendsto_integral_sin_div_x :
    Tendsto (fun R => ∫ x in (0:ℝ)..R, sin x / x) atTop (nhds (π / 2)) := by
  -- Suffices to show the integrand equals π/2 - E(R) where E(R) → 0
  -- We rewrite using integral_sinc_eq for R > 0, then show the error → 0
  suffices h : Tendsto (fun R => π / 2 -
      ∫ t in Set.Ioi (0:ℝ),
        exp (-t * R) * (t * sin R + cos R) / (1 + t ^ 2))
      atTop (nhds (π / 2)) by
    apply h.congr'
    filter_upwards [eventually_gt_atTop 0] with R hR
    exact (integral_sinc_eq hR).symm
  -- π/2 - E(R) → π/2 iff E(R) → 0
  have h_err := tendsto_error
  have : Tendsto (fun R => π / 2 -
      ∫ t in Set.Ioi (0:ℝ),
        exp (-t * R) * (t * sin R + cos R) / (1 + t ^ 2))
      atTop (nhds (π / 2 - 0)) := by
    exact tendsto_const_nhds.sub h_err
  rwa [sub_zero] at this

end
