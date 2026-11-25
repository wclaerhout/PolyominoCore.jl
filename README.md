<p align="center">
  <img src="assets/logo.svg" alt="Polyominoes.jl logo" width="700">
</p>

# Polyominoes.jl

[![CI](https://github.com/wclaerhout/Polyominoes.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/wclaerhout/Polyominoes.jl/actions/workflows/CI.yml)
[![Docs](https://img.shields.io/badge/docs-dev-blue.svg)](https://wclaerhout.github.io/Polyominoes.jl/dev/)

A small, dependency-free Julia package for **polyominoes**: edge-connected sets of unit
squares on the grid. It gives you a shape type you can draw and parse as ASCII,
opt-in rotation/reflection symmetry, enumeration of fixed, one-sided and free
polyominoes (tested against OEIS), splitting and joining, a few shape properties, and
optional plotting through Makie.

## Example

```julia
using Polyominoes

L = poly"""
#.
##
"""                                          # '#' filled, '.' empty; prints the same way
length(L), size(L)                           # (3, (2, 2)): 3 cells, 2×2 bounding box
length(polyominoes(5; symmetry = :full))     # 12 free pentominoes
attachments(L, poly"#"; symmetry = :full)    # the L, T, S and O tetrominoes (all contain L)
unique_splits(L; symmetry = :rotation)       # 1 distinct cut (domino + monomino), done 2 ways
perimeter(L), nholes(L)                      # (8, 0)
Polyominoes.symmetry_group(L)                # [:identity, :mirror_diag]
using CairoMakie; visualize_polyomino(L)     # plotting loads with a Makie backend
```

## Conventions

- Cells are `(r, c)` tuples. **Rows grow upward**, columns to the right; `(1, 1)` is the
  bottom-left cell of the bounding box. In ASCII drawings the top line is the top row.
- A `Polyomino` is a **fixed** polyomino: `==` and `hash` compare up to translation only.
  Pass `symmetry = :rotation` (one-sided) or `symmetry = :full` (free) to the functions
  that accept it, or compare `Polyominoes.canonical` forms.

## What's included

| Area | Names |
|---|---|
| Type and construction | `Polyomino`, `parse_polyomino`, `poly"..."`, `coordinates`, `length`, `size`, `in`, iteration |
| Symmetry (public, not exported) | `rotate90`, `reflect`, `orientations`, `canonical`, `is_equivalent`, `symmetry_group` |
| Enumeration | `polyominoes(n; symmetry)` |
| Structure | `is_connected`, `perimeter`, `nholes` |
| Splitting | `all_splits`, `unique_splits(p; symmetry)` |
| Joining | `attach(a, b, offset)`, `attachments(a, b; symmetry)` |
| Plotting (with Makie) | `visualize_polyomino`, `visualize_polyominoes` |

See the [documentation](https://wclaerhout.github.io/Polyominoes.jl/dev/) for tutorials
and the full API.

## How it differs from Polyomino.jl

[Polyomino.jl](https://github.com/PhoenixSmaug/Polyomino.jl) (singular) generates random
polyominoes and solves chess problems on them: rook and queen placement, guarding sets
and minimal line covers. Polyominoes.jl does none of that. It is a general core for the
shapes themselves: representation, symmetry, exhaustive enumeration, splitting and
joining.

## Use of AI

This code was written with the help of generative AI. The author has reviewed all of
it manually and is responsible for it.
