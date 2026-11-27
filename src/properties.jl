"""
    perimeter(p) -> Int

Number of unit edges on the boundary of `p`, including the edges around holes:
`4·length(p) − 2·(number of edge-adjacent cell pairs)`.
Every cell initially contributes 4 cells to the perimeter, but for each pair that is formed
2 edges are substracted.

```julia
perimeter(poly"##") == 6
```
"""
function perimeter(p::Polyomino)
    pairs = count(((r, c),) -> (r + 1, c) in p, coordinates(p)) +
            count(((r, c),) -> (r, c + 1) in p, coordinates(p))
    4 * length(p) - 2 * pairs
end

"""
    nholes(p) -> Int

Number of holes in `p`: 4-connected regions of empty cells that cannot reach the
outside. Empty cells connect only through shared edges, so two filled cells touching
at a corner separate the empty cells around them.

```julia
nholes(poly\"\"\"
###
#.#
###
\"\"\") == 1
```
"""
function nholes(p::Polyomino)
    h, w = size(p)
    # empty cells in the bounding box padded by 1; the padding ring is all outside
    empty = Set((r, c) for r in 0:h + 1, c in 0:w + 1 if (r, c) ∉ p)
    holes = 0
    outside = true                   # the first region filled is the one around (0, 0)
    while !isempty(empty)
        start = outside ? (0, 0) : first(empty)
        delete!(empty, start)
        stack = [start]
        while !isempty(stack)
            (r, c) = pop!(stack)
            for nb in ((r + 1, c), (r - 1, c), (r, c + 1), (r, c - 1))
                nb in empty || continue
                delete!(empty, nb)
                push!(stack, nb)
            end
        end
        outside ? (outside = false) : (holes += 1)
    end
    holes
end

# The 8 symmetries of the square (dihedral group D4) as maps on cells, rows pointing up.
# `rotate90` is :rot90 and `reflect` is :mirror_lr.
const D4 = (
    :identity        => ((r, c),) -> (r, c),
    :rot90           => ((r, c),) -> (c, -r),
    :rot180          => ((r, c),) -> (-r, -c),
    :rot270          => ((r, c),) -> (-c, r),
    :mirror_lr       => ((r, c),) -> (r, -c),
    :mirror_ud       => ((r, c),) -> (-r, c),
    :mirror_diag     => ((r, c),) -> (c, r),
    :mirror_antidiag => ((r, c),) -> (-c, -r),
)

"""
    symmetry_group(p) -> Vector{Symbol}

The symmetries of the square that map `p` onto itself (up to translation): a subgroup
of the dihedral group D4, listed in the order

`:identity, :rot90, :rot180, :rot270, :mirror_lr, :mirror_ud, :mirror_diag, :mirror_antidiag`.

`:rot90` is a quarter turn counter-clockwise ([`PolyominoTools.rotate90`](@ref)) and
`:mirror_lr` the left-right mirror ([`PolyominoTools.reflect`](@ref)). The group has
`8 ÷ length(orientations(p; symmetry = :full))` elements.

```julia
PolyominoTools.symmetry_group(poly"##") == [:identity, :rot180, :mirror_lr, :mirror_ud]
```
"""
symmetry_group(p::Polyomino) =
    [name for (name, f) in D4 if _polyomino_unchecked(map(f, coordinates(p))) == p]
