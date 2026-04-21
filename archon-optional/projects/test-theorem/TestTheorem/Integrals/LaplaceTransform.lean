/-
# Laplace Transforms of Sine and Cosine

## Main results

* `integral_Ioi_exp_neg_mul_sin`: ∫₀^∞ e^{-at} sin(bt) dt = b/(a²+b²) for a > 0
* `integral_Ioi_exp_neg_mul_cos`: ∫₀^∞ e^{-at} cos(bt) dt = a/(a²+b²) for a > 0

## Proof strategy

1. Compute ∫₀^R via FTC with explicit antiderivative
2. Show IntegrableOn on Ioi 0 (bound by e^{-at})
3. Use `intervalIntegral_tendsto_integral_Ioi` to relate interval → Ioi integral
4. Compute the limit of the FTC formula (error ∝ e^{-aR} → 0)
5. Conclude by `tendsto_nhds_unique`

### Antiderivatives

For sin: F(t) = -e^{-at}(a sin(bt) + b cos(bt))/(a²+b²), F(0) = -b/(a²+b²)
For cos: G(t) = e^{-at}(b sin(bt) - a cos(bt))/(a²+b²), G(0) = -a/(a²+b²)
-/
import Mathlib.Analysis.SpecialFunctions.Integrals.Basic
import Mathlib.MeasureTheory.Integral.IntegralEqImproper
import Mathlib.MeasureTheory.Integral.IntervalIntegral.FundThmCalculus
import Mathlib.Analysis.SpecialFunctions.ImproperIntegrals

open MeasureTheory Set Filter Topology Real intervalIntegral
open scoped ENNReal

noncomputable section

/-! ## Antiderivatives and FTC for the sin case -/

/-- The antiderivative of e^{-at} sin(bt). -/
private def F_sin (a b : ℝ) (t : ℝ) : ℝ :=
  -(exp (-a * t) * (a * sin (b * t) + b * cos (b * t))) / (a ^ 2 + b ^ 2)

private lemma F_sin_zero (a b : ℝ) : F_sin a b 0 = -b / (a ^ 2 + b ^ 2) := by
  simp [F_sin, sin_zero, cos_zero, exp_zero]

private lemma hasDerivAt_F_sin {a : ℝ} (ha : 0 < a) (b : ℝ) (t : ℝ) :
    HasDerivAt (F_sin a b) (exp (-a * t) * sin (b * t)) t := by
  unfold F_sin
  have hab : a ^ 2 + b ^ 2 ≠ 0 := by positivity
  -- d/dt[e^{-at}] = e^{-at} · (-a)
  have h_exp : HasDerivAt (fun s => exp (-a * s)) (exp (-a * t) * (-a)) t := by
    have hd : HasDerivAt (fun s => -a * s) (-a * 1) t :=
      (hasDerivAt_id t).const_mul (-a)
    simp only [mul_one] at hd
    exact hd.exp
  -- d/dt[a sin(bt) + b cos(bt)] = ab cos(bt) - b² sin(bt)
  have h_bt : HasDerivAt (fun s => b * s) b t := by
    have := (hasDerivAt_id t).const_mul b; simp only [mul_one] at this; exact this
  have h_trig : HasDerivAt (fun s => a * sin (b * s) + b * cos (b * s))
      (a * (cos (b * t) * b) + b * (-(sin (b * t)) * b)) t :=
    (h_bt.sin.const_mul a).add (h_bt.cos.const_mul b)
  -- Product rule
  have h_prod := h_exp.mul h_trig
  -- Divide by -(a² + b²)
  have h_neg := h_prod.neg.div_const (a ^ 2 + b ^ 2)
  convert h_neg using 1
  field_simp
  ring

/-- ∫₀^R e^{-at} sin(bt) dt = [b - e^{-aR}(a sin(bR) + b cos(bR))] / (a² + b²) -/
private theorem integral_sin_ftc {a : ℝ} (ha : 0 < a) (b : ℝ) {R : ℝ} (_hR : 0 ≤ R) :
    ∫ t in (0:ℝ)..R, exp (-a * t) * sin (b * t) =
      (b - exp (-a * R) * (a * sin (b * R) + b * cos (b * R))) / (a ^ 2 + b ^ 2) := by
  have hab : a ^ 2 + b ^ 2 ≠ 0 := by positivity
  have hint : IntervalIntegrable (fun t => exp (-a * t) * sin (b * t)) volume 0 R := by
    apply Continuous.intervalIntegrable; fun_prop
  rw [integral_eq_sub_of_hasDerivAt (fun t _ => hasDerivAt_F_sin ha b t) hint]
  simp only [F_sin_zero]
  unfold F_sin
  field_simp
  ring

/-! ## Antiderivatives and FTC for the cos case -/

/-- The antiderivative of e^{-at} cos(bt). -/
private def F_cos (a b : ℝ) (t : ℝ) : ℝ :=
  exp (-a * t) * (b * sin (b * t) - a * cos (b * t)) / (a ^ 2 + b ^ 2)

private lemma F_cos_zero (a b : ℝ) : F_cos a b 0 = -a / (a ^ 2 + b ^ 2) := by
  simp [F_cos, sin_zero, cos_zero, exp_zero]

private lemma hasDerivAt_F_cos {a : ℝ} (ha : 0 < a) (b : ℝ) (t : ℝ) :
    HasDerivAt (F_cos a b) (exp (-a * t) * cos (b * t)) t := by
  unfold F_cos
  have hab : a ^ 2 + b ^ 2 ≠ 0 := by positivity
  -- d/dt[e^{-at}] = e^{-at} · (-a)
  have h_exp : HasDerivAt (fun s => exp (-a * s)) (exp (-a * t) * (-a)) t := by
    have hd : HasDerivAt (fun s => -a * s) (-a * 1) t :=
      (hasDerivAt_id t).const_mul (-a)
    simp only [mul_one] at hd
    exact hd.exp
  -- d/dt[b sin(bt) - a cos(bt)] = b² cos(bt) + ab sin(bt)
  have h_bt : HasDerivAt (fun s => b * s) b t := by
    have := (hasDerivAt_id t).const_mul b; simp only [mul_one] at this; exact this
  have h_trig : HasDerivAt (fun s => b * sin (b * s) - a * cos (b * s))
      (b * (cos (b * t) * b) - a * (-(sin (b * t)) * b)) t :=
    (h_bt.sin.const_mul b).sub (h_bt.cos.const_mul a)
  -- Product rule
  have h_prod := h_exp.mul h_trig
  -- Divide by (a² + b²)
  have h_div := h_prod.div_const (a ^ 2 + b ^ 2)
  convert h_div using 1
  field_simp
  ring

/-- ∫₀^R e^{-at} cos(bt) dt = [a + e^{-aR}(b sin(bR) - a cos(bR))] / (a² + b²) -/
private theorem integral_cos_ftc {a : ℝ} (ha : 0 < a) (b : ℝ) {R : ℝ} (_hR : 0 ≤ R) :
    ∫ t in (0:ℝ)..R, exp (-a * t) * cos (b * t) =
      (a + exp (-a * R) * (b * sin (b * R) - a * cos (b * R))) / (a ^ 2 + b ^ 2) := by
  have hab : a ^ 2 + b ^ 2 ≠ 0 := by positivity
  have hint : IntervalIntegrable (fun t => exp (-a * t) * cos (b * t)) volume 0 R := by
    apply Continuous.intervalIntegrable; fun_prop
  rw [integral_eq_sub_of_hasDerivAt (fun t _ => hasDerivAt_F_cos ha b t) hint]
  simp only [F_cos_zero]
  unfold F_cos
  field_simp
  ring

/-! ## Integrability on Ioi -/

private theorem integrableOn_exp_neg_mul_sin {a : ℝ} (ha : 0 < a) (b : ℝ) :
    IntegrableOn (fun t => exp (-a * t) * sin (b * t)) (Ioi 0) volume := by
  have hexp : IntegrableOn (fun t => exp (-a * t)) (Ioi 0) volume :=
    integrableOn_exp_mul_Ioi (neg_neg_of_pos ha) 0
  apply Integrable.mono' hexp
  · exact (Continuous.aestronglyMeasurable (by fun_prop)).restrict
  · filter_upwards [ae_restrict_mem measurableSet_Ioi] with t _
    rw [Real.norm_eq_abs, abs_mul, abs_of_pos (exp_pos _)]
    calc exp (-a * t) * |sin (b * t)|
        ≤ exp (-a * t) * 1 :=
          mul_le_mul_of_nonneg_left (abs_sin_le_one _) (le_of_lt (exp_pos _))
      _ = exp (-a * t) := mul_one _

private theorem integrableOn_exp_neg_mul_cos {a : ℝ} (ha : 0 < a) (b : ℝ) :
    IntegrableOn (fun t => exp (-a * t) * cos (b * t)) (Ioi 0) volume := by
  have hexp : IntegrableOn (fun t => exp (-a * t)) (Ioi 0) volume :=
    integrableOn_exp_mul_Ioi (neg_neg_of_pos ha) 0
  apply Integrable.mono' hexp
  · exact (Continuous.aestronglyMeasurable (by fun_prop)).restrict
  · filter_upwards [ae_restrict_mem measurableSet_Ioi] with t _
    rw [Real.norm_eq_abs, abs_mul, abs_of_pos (exp_pos _)]
    calc exp (-a * t) * |cos (b * t)|
        ≤ exp (-a * t) * 1 :=
          mul_le_mul_of_nonneg_left (abs_cos_le_one _) (le_of_lt (exp_pos _))
      _ = exp (-a * t) := mul_one _

/-! ## Helper: exp(-aR) → 0 -/

private theorem tendsto_exp_neg_mul {a : ℝ} (ha : 0 < a) :
    Tendsto (fun R => exp (-a * R)) atTop (nhds 0) := by
  rw [tendsto_exp_comp_nhds_zero]
  have : Tendsto (fun R : ℝ => -R) atTop atBot := tendsto_neg_atTop_atBot
  exact (this.atBot_mul_const ha).congr (fun R => by ring)

/-! ## Limits of FTC formulas -/

/-- The FTC formula for ∫₀^R e^{-at} sin(bt) dt converges to b/(a²+b²) as R → ∞. -/
private theorem tendsto_ftc_sin {a : ℝ} (ha : 0 < a) (b : ℝ) :
    Tendsto (fun R => (b - exp (-a * R) * (a * sin (b * R) + b * cos (b * R))) /
      (a ^ 2 + b ^ 2)) atTop (nhds (b / (a ^ 2 + b ^ 2))) := by
  -- exp(-aR) → 0 as R → ∞
  have h_exp_tend := tendsto_exp_neg_mul ha
  -- The trig factor is bounded
  have h_bounded : IsBoundedUnder (· ≤ ·) atTop
      (fun R => ‖a * sin (b * R) + b * cos (b * R)‖) := by
    use |a| + |b|
    rw [Filter.eventually_map]
    exact Eventually.of_forall fun R => by
      calc ‖a * sin (b * R) + b * cos (b * R)‖
          = |a * sin (b * R) + b * cos (b * R)| := Real.norm_eq_abs _
        _ ≤ |a * sin (b * R)| + |b * cos (b * R)| := abs_add_le _ _
        _ = |a| * |sin (b * R)| + |b| * |cos (b * R)| := by rw [abs_mul, abs_mul]
        _ ≤ |a| * 1 + |b| * 1 := by
            gcongr; exact abs_sin_le_one _; exact abs_cos_le_one _
        _ = |a| + |b| := by ring
  -- exp(-aR) * (bounded) → 0
  have h_prod : Tendsto (fun R => exp (-a * R) * (a * sin (b * R) + b * cos (b * R)))
      atTop (nhds 0) :=
    Filter.Tendsto.zero_mul_isBoundedUnder_le h_exp_tend h_bounded
  -- b - 0 = b
  have h_num : Tendsto (fun R => b - exp (-a * R) * (a * sin (b * R) + b * cos (b * R)))
      atTop (nhds (b - 0)) :=
    tendsto_const_nhds.sub h_prod
  rw [sub_zero] at h_num
  exact h_num.div_const _

/-- The FTC formula for ∫₀^R e^{-at} cos(bt) dt converges to a/(a²+b²) as R → ∞. -/
private theorem tendsto_ftc_cos {a : ℝ} (ha : 0 < a) (b : ℝ) :
    Tendsto (fun R => (a + exp (-a * R) * (b * sin (b * R) - a * cos (b * R))) /
      (a ^ 2 + b ^ 2)) atTop (nhds (a / (a ^ 2 + b ^ 2))) := by
  have h_exp_tend := tendsto_exp_neg_mul ha
  have h_bounded : IsBoundedUnder (· ≤ ·) atTop
      (fun R => ‖b * sin (b * R) - a * cos (b * R)‖) := by
    use |b| + |a|
    rw [Filter.eventually_map]
    exact Eventually.of_forall fun R => by
      calc ‖b * sin (b * R) - a * cos (b * R)‖
          = |b * sin (b * R) - a * cos (b * R)| := Real.norm_eq_abs _
        _ = |b * sin (b * R) + -(a * cos (b * R))| := by rw [sub_eq_add_neg]
        _ ≤ |b * sin (b * R)| + |-(a * cos (b * R))| := abs_add_le _ _
        _ = |b| * |sin (b * R)| + |a| * |cos (b * R)| := by rw [abs_neg, abs_mul, abs_mul]
        _ ≤ |b| * 1 + |a| * 1 := by
            gcongr; exact abs_sin_le_one _; exact abs_cos_le_one _
        _ = |b| + |a| := by ring
  have h_prod : Tendsto (fun R => exp (-a * R) * (b * sin (b * R) - a * cos (b * R)))
      atTop (nhds 0) :=
    Filter.Tendsto.zero_mul_isBoundedUnder_le h_exp_tend h_bounded
  have h_num : Tendsto (fun R => a + exp (-a * R) * (b * sin (b * R) - a * cos (b * R)))
      atTop (nhds (a + 0)) :=
    tendsto_const_nhds.add h_prod
  rw [add_zero] at h_num
  exact h_num.div_const _

/-! ## Main theorems -/

/-- **Laplace transform of sine**: ∫₀^∞ e^{-at} sin(bt) dt = b/(a²+b²) for a > 0. -/
theorem integral_Ioi_exp_neg_mul_sin {a : ℝ} (ha : 0 < a) (b : ℝ) :
    ∫ t in Ioi (0:ℝ), exp (-a * t) * sin (b * t) = b / (a ^ 2 + b ^ 2) := by
  -- Step 1: interval integral → Ioi integral
  have h_int := integrableOn_exp_neg_mul_sin ha b
  have h_interval : Tendsto (fun R => ∫ t in (0:ℝ)..R, exp (-a * t) * sin (b * t))
      atTop (nhds (∫ t in Ioi (0:ℝ), exp (-a * t) * sin (b * t))) :=
    intervalIntegral_tendsto_integral_Ioi 0 h_int tendsto_id
  -- Step 2: interval integral = FTC formula (eventually)
  have h_ftc : ∀ᶠ R in atTop, ∫ t in (0:ℝ)..R, exp (-a * t) * sin (b * t) =
      (b - exp (-a * R) * (a * sin (b * R) + b * cos (b * R))) / (a ^ 2 + b ^ 2) := by
    filter_upwards [eventually_ge_atTop 0] with R hR
    exact integral_sin_ftc ha b hR
  -- Step 3: FTC formula → b/(a²+b²)
  have h_limit := tendsto_ftc_sin ha b
  -- Step 4: the FTC limit also equals the integral
  have h_limit' : Tendsto (fun R => ∫ t in (0:ℝ)..R, exp (-a * t) * sin (b * t))
      atTop (nhds (b / (a ^ 2 + b ^ 2))) :=
    h_limit.congr' (h_ftc.mono fun R hR => hR.symm)
  exact tendsto_nhds_unique h_interval h_limit'

/-- **Laplace transform of cosine**: ∫₀^∞ e^{-at} cos(bt) dt = a/(a²+b²) for a > 0. -/
theorem integral_Ioi_exp_neg_mul_cos {a : ℝ} (ha : 0 < a) (b : ℝ) :
    ∫ t in Ioi (0:ℝ), exp (-a * t) * cos (b * t) = a / (a ^ 2 + b ^ 2) := by
  have h_int := integrableOn_exp_neg_mul_cos ha b
  have h_interval : Tendsto (fun R => ∫ t in (0:ℝ)..R, exp (-a * t) * cos (b * t))
      atTop (nhds (∫ t in Ioi (0:ℝ), exp (-a * t) * cos (b * t))) :=
    intervalIntegral_tendsto_integral_Ioi 0 h_int tendsto_id
  have h_ftc : ∀ᶠ R in atTop, ∫ t in (0:ℝ)..R, exp (-a * t) * cos (b * t) =
      (a + exp (-a * R) * (b * sin (b * R) - a * cos (b * R))) / (a ^ 2 + b ^ 2) := by
    filter_upwards [eventually_ge_atTop 0] with R hR
    exact integral_cos_ftc ha b hR
  have h_limit := tendsto_ftc_cos ha b
  have h_limit' : Tendsto (fun R => ∫ t in (0:ℝ)..R, exp (-a * t) * cos (b * t))
      atTop (nhds (a / (a ^ 2 + b ^ 2))) :=
    h_limit.congr' (h_ftc.mono fun R hR => hR.symm)
  exact tendsto_nhds_unique h_interval h_limit'

end
