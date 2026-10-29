# The Long Wall in a Time-Symmetric Two-Boundary Model

Mike Stay — draft, October 2026.

This repository contains the LaTeX source and compiled PDF for the paper.

## Files

- `long_wall.tex` — manuscript source
- `long_wall.pdf` — compiled manuscript
- `Makefile` — rebuilds the PDF with `pdflatex`

## Build

A TeX distribution with `pdflatex` is required.

```sh
make
```

The build runs `pdflatex` twice so that cross-references settle. Temporary LaTeX files are ignored by Git.

## Repository bundle

A Git bundle can be cloned with:

```sh
git clone long-wall-paper.bundle long-wall-paper
```

No license has been specified in this repository.
