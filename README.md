<p align="center">
  <img src="assets/logo.svg" alt="Polyominoes.jl logo" width="700">
</p>

# Polyominoes.jl

A Julia implementation of polyominoes (sets of unit cells on a grid), compared up to
translation by default (`==` and `hash` stay translation-only). Rotation and reflection
are opt-in through the `symmetry` keyword (`:translation`, `:rotation` or `:full`) on
`unique_splits` and `all_valid_concatenations`. Extracted from
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
```

## Core Concepts

- **`Polyomino`**: a connected set of grid cells `(r, c)` (rows grow upward), normalized
  to a canonical translation. Behaves like a read-only set of cells: `length`, `size`
  (bounding box), `in` and iteration. Printing one shows its `#`/`.` drawing.
- **Parsing**: build a `Polyomino` from an ASCII drawing via `parse_polyomino` / `poly"..."`.
- **Concatenation**: attach one polyomino to another along a side (`concatenate`),
  with helpers to check validity and enumerate valid attachments.
- **Splitting**: enumerate ways to split a polyomino into connected pieces (`all_splits`,
  `unique_splits`).
- **Visualization**: plot a single polyomino or a sequence of polyominoes
  (`visualize_polyomino`, `visualize_pathway`). Plotting is a package extension: it
  becomes available once a Makie backend is loaded (`using CairoMakie`), so
  `using Polyominoes` alone does not pull in Makie.

## Status

Work in progress.
