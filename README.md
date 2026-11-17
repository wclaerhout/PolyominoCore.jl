<p align="center">
  <img src="assets/logo.svg" alt="Polyominoes.jl logo" width="700">
</p>

# Polyominoes.jl

A Julia implementation of polyominoes (sets of unit cells on a grid), compared up to
translation by default (`==` and `hash` stay translation-only). Rotation and reflection
are opt-in through the `symmetry` keyword (`:translation`, `:rotation` or `:full`) on
`unique_splits`, `attachments` and `polyominoes`. Extracted from
[`polyomino_crn`](https://github.com/wclaerhout/polyomino_crn), which builds a
hypergraph chemical reaction network and quality-diversity search on top of this core.

## Example

```julia
using Polyominoes

L = poly"""
#.
##
"""                                         # an L-tromino: '#' filled, '.' empty
length(L), size(L)                          # 3 cells, 2×2 bounding box; (1, 1) in L == true
length(all_splits(L))                       # 2 ways to cut it into two connected pieces
unique_splits(L; symmetry = :rotation)      # 1 distinct pair (monomino + domino), multiplicity 2
length(polyominoes(5; symmetry = :full))    # 12 free pentominoes
attachments(L, poly"#"; symmetry = :full)   # the 4 free tetrominoes that contain L (all but I)
```

## Core Concepts

- **`Polyomino`**: a connected set of grid cells `(r, c)` (rows grow upward), normalized
  to a canonical translation. Behaves like a read-only set of cells: `length`, `size`
  (bounding box), `in` and iteration. Printing one shows its `#`/`.` drawing.
- **Enumeration**: `polyominoes(n; symmetry)` lists every fixed (`:translation`),
  one-sided (`:rotation`) or free (`:full`) polyomino with `n` cells; the counts are
  tested against OEIS A001168, A000988 and A000105 for n = 1…10.
- **Parsing**: build a `Polyomino` from an ASCII drawing via `parse_polyomino` / `poly"..."`.
- **Joining**: `attach(a, b, offset)` joins two shapes at an explicit offset;
  `attachments(a, b; symmetry)` lists every distinct shape obtained by placing `b`
  (in any orientation `symmetry` allows) edge-to-edge with `a`. The older `side`/`pos`
  functions (`concatenate`, `concatenation_possible`, `all_valid_concatenations`) are
  deprecated and will be removed in v0.2.
- **Splitting**: enumerate ways to split a polyomino into connected pieces (`all_splits`,
  `unique_splits`).
- **Visualization**: plot a single polyomino or a sequence of polyominoes
  (`visualize_polyomino`, `visualize_pathway`). Plotting is a package extension: it
  becomes available once a Makie backend is loaded (`using CairoMakie`), so
  `using Polyominoes` alone does not pull in Makie.

## Status

Work in progress.
