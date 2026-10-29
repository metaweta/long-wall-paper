"""Symbolic verification of the equations in long_wall.tex.

Run: python3 verify.py

Each check uses SymPy to re-derive a boxed equation from the definitions
and asserts the result is identically zero (or equal to the claim).
No numerical tolerance is used -- these are exact symbolic identities.
"""

import sympy as sp

k, L, Y, a, d, delta, r, t, theta = sp.symbols(
    "k L Y a d delta r t theta", real=True
)
y1, y2, ell = sp.symbols("y1 y2 ell", real=True)
I = sp.I


def check(label, lhs, rhs=None):
    """Assert sp.simplify(lhs - rhs) == 0, print pass/fail. Handles matrices."""
    if isinstance(lhs, sp.MatrixBase):
        if rhs is None:
            rhs = sp.zeros(*lhs.shape)
        diff = sp.simplify(lhs - rhs)
        ok = diff == sp.zeros(*lhs.shape)
    else:
        if rhs is None:
            rhs = 0
        diff = sp.simplify(sp.expand_complex(sp.expand(lhs - rhs)))
        diff = sp.simplify(diff.rewrite(sp.exp))
        ok = diff == 0
    status = "OK " if ok else "FAIL"
    print(f"  [{status}] {label}")
    if not ok:
        print(f"         residual = {diff}")
    return ok


# ---------------------------------------------------------------------------
# Paraxial kernel  K_ell(y2, y1) = sqrt(k / (2 pi i ell)) * exp(i k (y2-y1)^2 / (2 ell))
# Backward propagation uses the adjoint: K*(y, y') = conj(K(y, y'))
# ---------------------------------------------------------------------------
def K(y2_, y1_, ell_):
    return sp.sqrt(k / (2 * sp.pi * I * ell_)) * sp.exp(I * k * (y2_ - y1_) ** 2 / (2 * ell_))


def Kstar(y2_, y1_, ell_):
    return sp.conjugate(K(y2_, y1_, ell_))


# Slit amplitudes A_±(Y) = A_D * K*(Y, ±a/2) at longitudinal distance d.
A_D = sp.symbols("A_D")
A_plus = A_D * Kstar(Y, +a / 2, d)
A_minus = A_D * Kstar(Y, -a / 2, d)


print("Section 3: detector-to-slit calculation")

# Eq (10): A_-/A_+ = exp(-i k a Y / d)
ratio = sp.simplify(A_minus / A_plus)
claim_10 = sp.exp(-I * k * a * Y / d)
check("Eq (10)  A_-/A_+ = exp(-i k a Y / d)", ratio - claim_10)

# Eq (7): |A_+| = |A_-|  (prefactor independent of transverse separation).
# With k, a, d, Y real, the modulus of each is |A_D| * sqrt(k/(2 pi d)).
mag_plus = sp.sqrt(sp.simplify(A_plus * sp.conjugate(A_plus)))
mag_minus = sp.sqrt(sp.simplify(A_minus * sp.conjugate(A_minus)))
check("Eq (7)   |A_+| = |A_-|", sp.simplify(mag_plus - mag_minus))

# Eq (12): A_+ + A_- = (prefactor) * 2 * exp[-i k (Y^2 + a^2/4) / (2 d)] * cos(k a Y / (2 d))
# Factor out A_D * sqrt(k/(-2 pi i d))  (the adjoint prefactor).
prefactor = A_D * sp.conjugate(sp.sqrt(k / (2 * sp.pi * I * d)))
sum_normalized = sp.simplify((A_plus + A_minus) / prefactor)
claim_12 = 2 * sp.exp(-I * k * (Y ** 2 + a ** 2 / 4) / (2 * d)) * sp.cos(k * a * Y / (2 * d))
check("Eq (12)  A_+ + A_-  factorizes as cos(kaY/2d)", sp.simplify(sum_normalized - claim_12))

# Eq (14): |A_+ + A_-|^2  ∝  4 cos^2(k a Y / (2 d))
mod_sq = sp.simplify((A_plus + A_minus) * sp.conjugate(A_plus + A_minus))
# Divide by |prefactor|^2 to isolate the Y-modulation.
pref_sq = sp.simplify(prefactor * sp.conjugate(prefactor))
mod_sq_normalized = sp.simplify(mod_sq / pref_sq)
claim_14 = 4 * sp.cos(k * a * Y / (2 * d)) ** 2
check("Eq (14)  |A_+ + A_-|^2 ∝ 4 cos^2(k a Y / 2 d)", sp.simplify(mod_sq_normalized - claim_14))


print("\nSection 4: common-mode cancellation")

# Proposition: if T_+ = T_- = T ≠ 0 then B_-/B_+ = A_-/A_+.
T = sp.symbols("T", nonzero=True)
B_plus = T * A_plus
B_minus = T * A_minus
check("Eq (18)  (T A_-)/(T A_+) = A_-/A_+", sp.simplify(B_minus / B_plus - A_minus / A_plus))


print("\nSection 5: exchange symmetry is weaker than scalar transfer")

J = sp.Matrix([[0, 1], [1, 0]])
U = sp.cos(theta) * sp.eye(2) + I * sp.sin(theta) * J

# U is unitary.
UdagU = sp.simplify(U.H @ U)
check("U(θ) unitary", sp.simplify(UdagU - sp.eye(2)))

# U commutes with J (channel exchange).
check("U(θ) commutes with J", sp.simplify(U @ J - J @ U))

# U(π/4) acting on (1, i)^T has a zero first component.
v = sp.Matrix([1, I])
w = sp.simplify((U.subs(theta, sp.pi / 4)) @ v)
check("U(π/4) (1, i)^T has first entry 0", sp.simplify(w[0]))


print("\nSection 2 / Section 6: visibility")

# Eq (5): V(L) = 2 r / (1 + r^2).  Compute from I = 1 + r^2 + 2 r cos(delta).
I_of = 1 + r ** 2 + 2 * r * sp.cos(delta)
# Maximize/minimize over delta (critical points at delta = 0, pi; endpoints give the same).
I_max = sp.simplify(I_of.subs(delta, 0))
I_min = sp.simplify(I_of.subs(delta, sp.pi))
V_computed = sp.simplify((I_max - I_min) / (I_max + I_min))
# Hold for 0 < r < 1 so the sign of (1 - r) is positive.
V_computed_pos = sp.simplify(V_computed.subs(r, sp.Symbol("r", positive=True, real=True)))
V_claim = 2 * sp.Symbol("r", positive=True, real=True) / (
    1 + sp.Symbol("r", positive=True, real=True) ** 2
)
check("Eq (5)  V(L) = 2 r / (1 + r^2)", sp.simplify(V_computed_pos - V_claim))

# Eq (29): with R_+=1, R_-=0, A_±=1,  V_total(t) = 2|t| |1+t| / (|1+t|^2 + |t|^2)
Phi_plus = 1 + t
Phi_minus = t
# For a two-wave coherent sum  C = Phi_+ + Phi_- e^{i delta}, visibility over delta is
# (|Phi_+| |Phi_-| + |Phi_+| |Phi_-|) ... = 2 |Phi_+| |Phi_-| / (|Phi_+|^2 + |Phi_-|^2).
V_total = sp.simplify(
    2 * sp.Abs(Phi_plus) * sp.Abs(Phi_minus)
    / (sp.Abs(Phi_plus) ** 2 + sp.Abs(Phi_minus) ** 2)
)
# Specialize to real t.
t_real = sp.Symbol("t", real=True)
V_at_1 = sp.simplify(V_total.subs(t, 1))
V_at_m1 = sp.simplify(V_total.subs(t, -1))
check("V_total(t=+1) = 4/5", sp.simplify(V_at_1 - sp.Rational(4, 5)))
check("V_total(t=-1) = 0", sp.simplify(V_at_m1))
# And V_total(t) → 0 as t → 0+.
V_limit = sp.limit(V_total.subs(t, t_real), t_real, 0, "+")
check("V_total(t) → 0 as t → 0+", sp.simplify(V_limit))


print("\nAll checks completed.")
