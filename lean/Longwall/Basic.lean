import Mathlib

/-!
# Formalization of the key equations in `long_wall.tex`

Each `theorem` below corresponds to a boxed / numbered equation in the paper.
All claims are elementary identities in `ℂ`, so the proofs are short.

The forward paraxial kernel is
  `K_ℓ(y₂, y₁) = √(k / (2π i ℓ)) · exp(i k (y₂ - y₁)² / (2ℓ))`.
Its adjoint is the complex conjugate.  Since the prefactor is independent of
the slit coordinate, it cancels from every ratio claim in the paper, so we
work with the phase part only.
-/

namespace LongWall

open Complex Real

/-- Phase part of the adjoint paraxial kernel evaluated at `(Y, y₁)` over
    longitudinal distance `d`.  All inputs are real; the result is complex. -/
noncomputable def Aphase (k Y d y₁ : ℝ) : ℂ :=
  Complex.exp (-Complex.I * (k : ℂ) * ((Y - y₁ : ℝ) : ℂ) ^ 2 / (2 * (d : ℂ)))

/-! ### Eq. (10): detector-to-slit ratio has no `L` dependence -/

/-- `A₋ / A₊ = exp(-i k a Y / d)` with no splitter-length dependence. -/
theorem ratio (k Y a d : ℝ) (hd : d ≠ 0) :
    Aphase k Y d (-(a/2)) / Aphase k Y d (a/2) =
      Complex.exp (-Complex.I * (k : ℂ) * (a : ℂ) * (Y : ℂ) / (d : ℂ)) := by
  simp only [Aphase]
  rw [← Complex.exp_sub]
  congr 1
  have hdc : ((d : ℂ)) ≠ 0 := by exact_mod_cast hd
  push_cast
  field_simp
  ring

/-! ### Eq. (7): equal magnitudes

The phase part has modulus one, hence `|A₊| = |A₋|`. -/

theorem equal_magnitudes (k Y d y₁ : ℝ) :
    ‖Aphase k Y d y₁‖ = 1 := by
  simp only [Aphase, Complex.norm_exp]
  have h : (-Complex.I * (k : ℂ) * ((Y - y₁ : ℝ) : ℂ) ^ 2 / (2 * (d : ℂ))).re = 0 := by
    simp [Complex.div_re, Complex.mul_re, Complex.mul_im, Complex.I_re, Complex.I_im,
          Complex.ofReal_re, Complex.ofReal_im, Complex.neg_re, Complex.neg_im,
          pow_two]
  rw [h, Real.exp_zero]

/-! ### Section 4 Proposition: common-mode cancellation -/

/-- Multiplying numerator and denominator by the same nonzero scalar preserves
    the ratio.  This is the content of the paper's §4 proposition for `ℂ`. -/
theorem common_mode (T A B : ℂ) (hT : T ≠ 0) :
    (T * B) / (T * A) = B / A :=
  mul_div_mul_left _ _ hT

/-! ### Section 5: exchange symmetry alone is weaker than scalar transfer

`U(θ) = cos θ · I + i sin θ · J` acts on `(1, i)^T` with first component
`cos θ · 1 + (i · sin θ) · i = cos θ - sin θ`, which vanishes at `θ = π/4`.
This shows that an exchange-symmetric unitary need not preserve an amplitude
ratio.  No Matrix library is needed. -/

/-- First component of `U(θ) · (1, i)^T`. -/
theorem U_first_component (θ : ℝ) :
    ((Real.cos θ : ℂ) * 1 + (Complex.I * Real.sin θ) * Complex.I) =
      ((Real.cos θ : ℂ) - (Real.sin θ : ℂ)) := by
  rw [show (Complex.I * (Real.sin θ : ℂ)) * Complex.I =
        (Complex.I * Complex.I) * (Real.sin θ : ℂ) by ring,
      Complex.I_mul_I]
  ring

/-- At `θ = π/4` the first component is identically zero. -/
theorem U_pi_div_four_kills_first :
    ((Real.cos (π/4) : ℂ) - (Real.sin (π/4) : ℂ)) = 0 := by
  rw [Real.cos_pi_div_four, Real.sin_pi_div_four]
  simp

/-- `U(θ)` is unitary because `cos²θ + sin²θ = 1`. -/
theorem U_unitary_core (θ : ℝ) :
    Real.cos θ ^ 2 + Real.sin θ ^ 2 = 1 :=
  Real.cos_sq_add_sin_sq θ

/-! ### Eq. (5): visibility `V = 2r / (1 + r²)` from the two-wave formula -/

/-- Maximizing/minimizing `1 + r² + 2r cos δ` over `δ ∈ ℝ` gives extrema
    `(1 ± r)²`.  Dividing yields `V = 2r / (1 + r²)`. -/
theorem visibility (r : ℝ) :
    ((1 + r)^2 - (1 - r)^2) / ((1 + r)^2 + (1 - r)^2) = 2 * r / (1 + r ^ 2) := by
  have h1 : (1 + r) ^ 2 + (1 - r) ^ 2 = 2 * (1 + r ^ 2) := by ring
  have h2 : (1 + r) ^ 2 - (1 - r) ^ 2 = 4 * r := by ring
  rw [h1, h2]
  have hne : (1 : ℝ) + r ^ 2 ≠ 0 := by positivity
  field_simp
  ring

/-! ### Section 6: total-field counterexamples -/

/-- Two-wave total-field visibility, maximized over a relative phase. -/
noncomputable def V_total (t : ℂ) : ℝ :=
  (2 * ‖(1 : ℂ) + t‖ * ‖t‖) / (‖(1 : ℂ) + t‖ ^ 2 + ‖t‖ ^ 2)

/-- With `R₊ = 1, R₋ = 0, A± = 1, t = 1`, the total visibility is `4/5`. -/
theorem V_total_at_one : V_total 1 = 4/5 := by
  simp [V_total]
  norm_num

/-- With `t = -1`, the first channel vanishes and the total visibility is `0`. -/
theorem V_total_at_neg_one : V_total (-1) = 0 := by
  simp [V_total]

/-! ### Eq. (12): coherent sum factorization

`A₊ + A₋ = exp(-i k (Y² + a²/4)/(2d)) · 2 cos(k a Y / (2d))`. -/

/-- `exp(i t) + exp(-i t) = 2 cos t` for real `t`. -/
lemma two_cos_eq_exp_add_neg (t : ℝ) :
    Complex.exp (Complex.I * (t : ℂ)) + Complex.exp (-(Complex.I * (t : ℂ))) =
      2 * (Real.cos t : ℂ) := by
  rw [show Complex.I * (t : ℂ) = (t : ℂ) * Complex.I from mul_comm _ _,
      show -((t : ℂ) * Complex.I) = (-(t : ℂ)) * Complex.I by ring,
      Complex.exp_mul_I, Complex.exp_mul_I,
      Complex.cos_neg, Complex.sin_neg]
  have hcos : Complex.cos ((t : ℂ)) = ((Real.cos t : ℝ) : ℂ) := by
    exact_mod_cast rfl
  rw [hcos]
  ring

theorem sum_factorization (k Y a d : ℝ) (hd : d ≠ 0) :
    Aphase k Y d (a/2) + Aphase k Y d (-(a/2)) =
      Complex.exp (-Complex.I * (k : ℂ) * ((Y : ℂ) ^ 2 + (a : ℂ) ^ 2 / 4) / (2 * (d : ℂ))) *
        (2 * (Real.cos (k * a * Y / (2 * d)) : ℂ)) := by
  simp only [Aphase]
  have hdc : ((d : ℂ)) ≠ 0 := by exact_mod_cast hd
  have h_plus :
      Complex.exp (-Complex.I * (k : ℂ) * (((Y - a/2 : ℝ)) : ℂ) ^ 2 / (2 * (d : ℂ))) =
        Complex.exp (-Complex.I * (k : ℂ) * ((Y : ℂ) ^ 2 + (a : ℂ) ^ 2 / 4) / (2 * (d : ℂ))) *
          Complex.exp (Complex.I * ((k * a * Y / (2 * d) : ℝ) : ℂ)) := by
    rw [← Complex.exp_add]
    congr 1
    push_cast
    field_simp
    ring
  have h_minus :
      Complex.exp (-Complex.I * (k : ℂ) * (((Y - -(a/2) : ℝ)) : ℂ) ^ 2 / (2 * (d : ℂ))) =
        Complex.exp (-Complex.I * (k : ℂ) * ((Y : ℂ) ^ 2 + (a : ℂ) ^ 2 / 4) / (2 * (d : ℂ))) *
          Complex.exp (-(Complex.I * ((k * a * Y / (2 * d) : ℝ) : ℂ))) := by
    rw [← Complex.exp_add]
    congr 1
    push_cast
    field_simp
    ring
  rw [h_plus, h_minus, ← mul_add, two_cos_eq_exp_add_neg (k * a * Y / (2 * d))]

end LongWall
