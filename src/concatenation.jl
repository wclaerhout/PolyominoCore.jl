function opposite_side(side::Symbol)
    side == :right  && return :left
    side == :left   && return :right
    side == :top    && return :bottom
    side == :bottom && return :top
    error("side must be :top, :bottom, :left, or :right")
end

"""
    boundary_cells(poly, side) -> Vector{Tuple{Int,Int}}

Return cells of `poly` that are exposed on `side` (:top/:bottom/:left/:right),
sorted along the edge (by column for top/bottom, by row for left/right).
"""
function boundary_cells(poly::Polyomino, side::Symbol)
    coords = coordinates(poly)
    cells, sortkey, primary = if side == :right
        [(r, c) for (r, c) in coords if (r, c+1) ∉ coords], x -> (x[1], -x[2]), x -> x[1]
    elseif side == :left
        [(r, c) for (r, c) in coords if (r, c-1) ∉ coords], x -> (x[1],  x[2]), x -> x[1]
    elseif side == :top
        [(r, c) for (r, c) in coords if (r+1, c) ∉ coords], x -> (x[2], -x[1]), x -> x[2]
    elseif side == :bottom
        [(r, c) for (r, c) in coords if (r-1, c) ∉ coords], x -> (x[2],  x[1]), x -> x[2]
    else
        error("side must be :top, :bottom, :left, or :right")
    end

    sorted = sort(cells, by = sortkey)

    # one cell per primary coordinate — outermost wins, interior concavities skipped
    seen = Set{Int}()
    filter(sorted) do c
        k = primary(c)
        k ∈ seen ? false : (push!(seen, k); true)
    end
end

"""
    concatenate(poly1, poly2; side, pos1, pos2) -> Polyomino

Attach `poly2` to `poly1` along `side` of `poly1`.

- `side`  : which face of `poly1` to attach to (:top/:bottom/:left/:right)
- `pos1`  : 1-based index into `poly1`'s boundary cells on that side (sorted along edge,
            outermost first when concavities create ties)
- `pos2`  : 1-based index into `poly2`'s boundary cells on the opposite side

Use `boundary_cells(poly, side)` to inspect the available positions and their order.
Throws if the placement causes overlap.

**Intuitively**: you translate the anchor point of polyomino 2 next to the anchor point of polyomino 1. Then you translate all the other points in the same way. Lastly you check the intersection between polyomino 1 and the translated second polyomino, if this is not empty there is overlap and it is not possible.
"""
function concatenate(poly1::Polyomino, poly2::Polyomino;
                     side::Symbol = :right, pos1::Int = 1, pos2::Int = 1)
    b1 = boundary_cells(poly1, side)
    b2 = boundary_cells(poly2, opposite_side(side))

    1 <= pos1 <= length(b1) || error("pos1=$pos1 out of range [1, $(length(b1))]")
    1 <= pos2 <= length(b2) || error("pos2=$pos2 out of range [1, $(length(b2))]")

    anchor1 = b1[pos1]
    anchor2 = b2[pos2]

    target = if side == :right
        (anchor1[1], anchor1[2] + 1)
    elseif side == :left
        (anchor1[1], anchor1[2] - 1)
    elseif side == :top
        (anchor1[1] + 1, anchor1[2])
    else  # :bottom
        (anchor1[1] - 1, anchor1[2])
    end

    dr = target[1] - anchor2[1]
    dc = target[2] - anchor2[2]

    translated = Set((r + dr, c + dc) for (r, c) in coordinates(poly2))

    isempty(intersect(coordinates(poly1), translated)) ||
        error("Concatenation results in overlap (pos1=$pos1, pos2=$pos2, side=$side)")

    return Polyomino(union(coordinates(poly1), translated))
end