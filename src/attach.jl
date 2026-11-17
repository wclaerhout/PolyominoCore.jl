const NEIGHBOURS = ((1, 0), (-1, 0), (0, 1), (0, -1))

touches(a::Polyomino, b::Polyomino, (dr, dc)) =
    any(((r, c),) -> any(((er, ec),) -> (r + dr + er, c + dc + ec) in a, NEIGHBOURS),
        coordinates(b))

# Union of `a` and `b` shifted by `offset`; caller guarantees no overlap and contact.
join_unchecked(a::Polyomino, b::Polyomino, (dr, dc)) =
    _polyomino_unchecked([coordinates(a); [(r + dr, c + dc) for (r, c) in coordinates(b)]])

"""
    attach(a, b, offset) -> Polyomino

The union of `a` and `b` shifted by `offset = (dr, dc)`: cell `(r, c)` of `b` lands on
`(r + dr, c + dc)` in `a`'s coordinates (both as given by [`coordinates`](@ref)).
Throws an `ArgumentError` if the two overlap or do not share an edge.

```julia
attach(poly"#", poly"#", (0, 1)) == poly"##"
```
"""
function attach(a::Polyomino, b::Polyomino, offset::Tuple{Integer,Integer})
    off = (Int(offset[1]), Int(offset[2]))
    overlaps(a, b, off) &&
        throw(ArgumentError("attach: b shifted by $off overlaps a"))
    touches(a, b, off) ||
        throw(ArgumentError("attach: b shifted by $off does not share an edge with a"))
    join_unchecked(a, b, off)
end

"""
    attachments(a, b; symmetry = :translation, placements = false)

Every distinct polyomino formed by placing `b` edge-adjacent to `a` without overlap.
`b` may first be put in any orientation allowed by `symmetry` (see
[`Polyominoes.orientations`](@ref)); `a` stays fixed.

Results are distinct under `symmetry`: no two are equal after
[`Polyominoes.canonical`](@ref)`(_; symmetry)`. Each class is represented by the first
placement found, so each shape is `a` plus one copy of `b` (up to translation). The
results are sorted by `coordinates`.

With `placements = true`, returns `(shape, piece, offset)` named tuples instead, where
`piece` is the orientation of `b` that was used and `attach(a, piece, offset) == shape`.

Every result can be split back into `a` and `b`: `all_splits(shape)` contains the pair
(up to translation, and up to `symmetry` for the `b` piece).
"""
function attachments(a::Polyomino, b::Polyomino; symmetry::Symbol = :translation,
                     placements::Bool = false)
    check_symmetry(symmetry)
    seen = Set{Polyomino}()
    out  = @NamedTuple{shape::Polyomino, piece::Polyomino, offset::Tuple{Int,Int}}[]
    for q in orientations(b; symmetry)
        offsets = Set{Tuple{Int,Int}}()
        # some cell z of q must land on an empty neighbour y of a: offset = y - z
        for (r, c) in coordinates(a), (er, ec) in NEIGHBOURS
            y = (r + er, c + ec)
            y in a && continue
            for z in coordinates(q)
                push!(offsets, (y[1] - z[1], y[2] - z[2]))
            end
        end
        for off in sort!(collect(offsets))
            overlaps(a, q, off) && continue
            shape = join_unchecked(a, q, off)
            key = canonical(shape; symmetry)
            key in seen && continue
            push!(seen, key)
            push!(out, (shape = shape, piece = q, offset = off))
        end
    end
    sort!(out; by = x -> coordinates(x.shape))
    placements ? out : [x.shape for x in out]
end
