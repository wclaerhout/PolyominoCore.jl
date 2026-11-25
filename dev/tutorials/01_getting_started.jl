using Polyominoes
using Polyominoes: rotate90, reflect, orientations, canonical, is_equivalent, symmetry_group

T = poly"""
###
.#.
"""

[T, poly"##"]

Polyomino([(10, 10), (10, 11), (11, 10)]) == poly"""
#.
#
"""

length(T), size(T)          # 4 cells, 2 rows × 3 columns

coordinates(T)              # sorted (r, c) cells; (1, 2) is the stem

(1, 2) in T, (1, 1) in T

[r for (r, c) in T]         # iterate over the cells

rotate90(T)                 # a quarter turn counter-clockwise

rotate90(T) == T, is_equivalent(rotate90(T), T; symmetry = :rotation)

S = poly"""
.##
##.
"""
Z = reflect(S)
canonical(S; symmetry = :full) == canonical(Z; symmetry = :full)

length(orientations(S; symmetry = :full)), symmetry_group(S)

[length(polyominoes(n; symmetry = :full)) for n in 1:8]      # OEIS A000105

polyominoes(4; symmetry = :full)                             # the 5 free tetrominoes

ring = poly"""
###
#.#
###
"""
perimeter(ring), nholes(ring)

count(p -> nholes(p) > 0, polyominoes(8; symmetry = :full))

all_splits(T)

unique_splits(T; symmetry = :rotation)

attach(T, poly"#", (2, 1))      # the monomino lands on (3, 2), above the T's middle cell: a plus

L = poly"""
#.
#
"""
attachments(L, poly"#"; symmetry = :full)

using CairoMakie
visualize_polyomino(poly"""
.#.
###
.#.
.##
""")

visualize_polyominoes([poly"#", poly"##", L, T])

visualize_polyomino(T; annotation = :full)

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl
