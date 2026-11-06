# Longwall — Lean 4 formalization

Lean 4 / Mathlib formalization of the algebraic identities in
[`long_wall.tex`](../long_wall.tex).

## Build

```sh
lake exe cache get   # optional: fetch prebuilt Mathlib
lake build
```

A clean `lake build` means every theorem in `Longwall/Basic.lean` has been
checked by the Lean kernel.

## Coverage

The table below maps each identity in the paper to its Lean counterpart in
`Longwall/Basic.lean`, and states exactly what is formalized. Where the
Lean theorem captures only the algebraic core rather than the complete
physical claim, that scope is called out.

| Paper equation / claim                          | Lean theorem                   | Scope of the formal statement                                                                                                                     |
| ----------------------------------------------- | ------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------- |
| Eq. (7)  `\|A₊\| = \|A₋\|`                      | `equal_magnitudes`             | The phase part of the paraxial kernel has modulus 1 (prefactor independent of the slit coordinate; cancels in the ratio).                          |
| Eq. (10) `A₋/A₊ = exp(-i k a Y / d)`            | `ratio`                        | Pure ratio of the phase factors, with no `L` dependence by construction.                                                                           |
| Eq. (12) `A₊ + A₋` factorization                | `sum_factorization`            | Factorization of the phase sum as `exp(-i k (Y² + a²/4)/(2d)) · 2 cos(k a Y / (2d))`.                                                              |
| Eq. (14) `\|A₊ + A₋\|² ∝ 4 cos²(k a Y / 2d)`    | — (follows from above)         | Not stated as its own theorem; a direct corollary of `sum_factorization` together with `equal_magnitudes`.                                         |
| §4 proposition  `(T·B)/(T·A) = B/A`             | `common_mode`                  | Algebraic common-factor cancellation for nonzero scalar `T` in `ℂ`.                                                                                |
| §5 `U(θ)` acts on `(1, i)ᵀ`                     | `U_first_component`            | First-component expression `cos θ − sin θ` (Lean uses the explicit entry; it does not instantiate a 2×2 matrix type).                              |
| §5 `U(π/4)` kills the first component           | `U_pi_div_four_kills_first`    | `cos(π/4) − sin(π/4) = 0`.                                                                                                                         |
| §5 `U(θ)` unitary                               | `U_unitary_core`               | **Scope note:** only the Pythagorean identity `cos² θ + sin² θ = 1` is formalized — the trigonometric content that *would* imply matrix unitarity. The full matrix-level statement `U(θ)† U(θ) = I` and the commutation `U J = J U` are verified in `verify.py` (`sp.Matrix`) but not re-proved here. |
| Eq. (5)  `V(L) = 2r / (1 + r²)`                 | `visibility`                   | `((1+r)² − (1−r)²) / ((1+r)² + (1−r)²) = 2r / (1 + r²)`; takes the extrema of `1 + r² + 2r cos δ` as inputs (not re-derived in Lean).              |
| Eq. (29) total-field visibility at `t = +1`     | `V_total_at_one`               | `V_total 1 = 4/5`.                                                                                                                                 |
| Eq. (29) total-field visibility at `t = −1`     | `V_total_at_neg_one`           | `V_total (-1) = 0`.                                                                                                                                |
| §6 `V_total(t) → 0` as `t → 0⁺`                 | — (SymPy only)                 | **Scope note:** the one-sided real limit is checked in `verify.py` (`sp.limit`) but not formalized in Lean.                                        |

### What is *not* formalized here

- A forward paraxial kernel object with the full `√(k / (2π i ℓ))`
  prefactor. The paper's algebraic identities all cancel that prefactor, so
  the Lean file works with the phase part (`Aphase`) only; see the file's
  header comment.
- The transfer operator for any specific wall geometry. The paper is
  explicit that `T₊(L) = T₋(L)` is an assumption, not a derived result;
  nothing in the Lean file claims otherwise.
- The limit `V_total(t) → 0` as `t → 0⁺` (checked symbolically in
  `verify.py`).
- Full matrix-level unitarity and commutation of `U(θ)` with the exchange
  `J` (checked symbolically in `verify.py`).
