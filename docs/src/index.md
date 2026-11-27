# PolyominoTools.jl

A small Julia package for **polyominoes**: finite, edge-connected sets of unit squares
on the grid. It covers the basics that most work with polyominoes needs:

- a `Polyomino` type, normalized for translation, that you can draw and parse as ASCII;
- rotations, reflections and canonical forms, with symmetry always **opt-in**;
- enumeration of fixed, one-sided and free polyominoes, tested against OEIS;
- splitting a shape into two connected pieces, and joining two shapes;
- a few properties: perimeter, holes, symmetry group;
- optional plotting through Makie.

It has no dependencies. Plotting is a package extension that loads when a Makie
backend such as CairoMakie is loaded.

```julia
using PolyominoTools

L = poly"""
#.
##
"""
length(polyominoes(5; symmetry = :full))   # 12 free pentominoes
attachments(L, poly"#"; symmetry = :full)  # the tetrominoes that contain L
```

## Conventions

- **Cells are `(r, c)` tuples: row, then column.** Rows grow **upward** and columns grow
  to the right, so `(1, 1)` is the bottom-left cell of the bounding box. In an ASCII
  drawing the top line is the highest row.
- **A `Polyomino` is a fixed polyomino.** `==` and `hash` compare shapes up to
  translation only. To identify rotations (one-sided polyominoes) or rotations and
  reflections (free polyominoes), pass `symmetry = :rotation` or `symmetry = :full` to
  the functions that take it, or compare `PolyominoTools.canonical` forms.

## Installation

```julia
using Pkg
Pkg.add(url = "https://github.com/wclaerhout/PolyominoTools.jl")
```

## Related packages

[Polyomino.jl](https://github.com/PhoenixSmaug/Polyomino.jl) (singular) generates random
polyominoes (Eden model, uniform sampling) and solves chess problems on them: rook and
queen placement, guarding sets, minimal line covers. PolyominoTools.jl does none of that;
it is a general core for the shapes themselves: representation, symmetry, exhaustive
enumeration, splitting and joining.
