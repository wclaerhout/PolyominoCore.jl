const NEIGHBOURS = ((1, 0), (-1, 0), (0, 1), (0, -1))

# Does `b` shifted by `(dr, dc)` overlap `a`?
function overlaps(a::Polyomino, b::Polyomino, (dr, dc))
    for (r, c) in coordinates(b)
        shifted_cell = (r + dr, c + dc)

        if shifted_cell in a
            return true
        end
    end

    return false
end

function touches(a::Polyomino, b::Polyomino, (dr, dc))
    for (r, c) in coordinates(b)
        shifted_r = r + dr
        shifted_c = c + dc

        for (er, ec) in NEIGHBOURS
            neighbour = (shifted_r + er, shifted_c + ec)

            if neighbour in a
                return true
            end
        end
    end

    return false
end

# Union of `a` and `b` shifted by `offset`.
# Caller guarantees no overlap and contact.
function join_unchecked(a::Polyomino, b::Polyomino, (dr, dc))
    cells = copy(coordinates(a))

    for (r, c) in coordinates(b)
        push!(cells, (r + dr, c + dc))
    end

    return _polyomino_unchecked(cells)
end
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
function attachments(a::Polyomino, b::Polyomino;
                     symmetry::Symbol = :translation,
                     placements::Bool = false)

    check_symmetry(symmetry)

    seen = Set{Polyomino}()
    out = @NamedTuple{
        shape::Polyomino,
        piece::Polyomino,
        offset::Tuple{Int,Int}
    }[]

    # Try every allowed orientation of b.
    for piece in orientations(b; symmetry)

        offsets = Set{Tuple{Int,Int}}()

        # 1. Find all empty cells directly neighbouring a 
        # 2. Calculate all the translations for b that would touch a
        # 3. No duplicate translations -> Set()
        # 4. Check if you translate b by the offset if it overlaps a -> reject if they do 
        # 5. Construct the attachment 
        # 6. Remove symmetric duplicates
        
        for (r, c) in coordinates(a)
            for (dr, dc) in NEIGHBOURS
                neighbour = (r + dr, c + dc)

                # Skip positions already occupied by a.
                neighbour in a && continue

                # Align every cell of piece with this empty neighbour.
                for (pr, pc) in coordinates(piece)
                    offset = (neighbour[1] - pr, neighbour[2] - pc)
                    push!(offsets, offset)
                end
            end
        end

        # Evaluate candidate placements. Test if the pieces touch or overlap.
        for offset in sort!(collect(offsets))

            # Reject placements that overlap a.
            overlaps(a, piece, offset) && continue

            # Construct the combined polyomino.
            shape = join_unchecked(a, piece, offset)

            # Avoid shapes equivalent under the requested symmetry.
            key = canonical(shape; symmetry)
            key in seen && continue

            push!(seen, key)

            push!(out, (
                shape = shape,
                piece = piece,
                offset = offset
            ))
        end
    end

    # Sort results by their coordinates.
    sort!(out; by = x -> coordinates(x.shape))

    return placements ? out : [x.shape for x in out]
end
