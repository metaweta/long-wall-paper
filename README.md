# The Long Wall in a Time-Symmetric Two-Boundary Model

Mike Stay — October 2026.

This repository contains the LaTeX source and compiled PDF for the paper,
along with a SymPy script and a Lean 4 formalization that verify the key
computations.

## Files

- `long_wall.tex` — manuscript source
- `long_wall.pdf` — compiled manuscript
- `Makefile` — rebuilds the PDF with `pdflatex`
- `verify.py` — SymPy script that re-derives the paper's identities
- `lean/` — Lean 4 / Mathlib formalization of the boxed equations

## Build

A TeX distribution with `pdflatex` is required.

```sh
make
```

The build runs `pdflatex` twice so that cross-references settle. Temporary LaTeX files are ignored by Git.

## Verify the computations with Lean

The `lean/` directory contains a Lean 4 project whose theorems correspond to
the boxed and numbered equations in the paper. The pinned toolchain is in
`lean/lean-toolchain`; the easiest way to pick it up is via
[`elan`](https://github.com/leanprover/elan).

```sh
# install elan once (skip if you already have it)
curl https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh -sSf | sh

cd lean
lake exe cache get   # fetch prebuilt Mathlib artifacts (optional but much faster)
lake build
```

A successful `lake build` with no errors means every theorem in
`lean/Longwall/Basic.lean` has been checked by the Lean kernel. The first
build downloads Mathlib and can take a while; subsequent builds are
incremental.

## Verify the computations with SymPy

As a lighter-weight cross-check, `verify.py` re-derives the same identities
symbolically:

```sh
python3 verify.py
```

It requires only [SymPy](https://www.sympy.org/).

## Repository bundle

A Git bundle can be cloned with:

```sh
git clone long-wall-paper.bundle long-wall-paper
```

No license has been specified in this repository.
