const SIDES = (:top, :bottom, :left, :right)

check_side(side::Symbol) = side in SIDES ||
    throw(ArgumentError("side must be :top, :bottom, :left, or :right, got :$side"))

function opposite_side(side::Symbol)
    side == :right  && return :left
    side == :left   && return :right
    side == :top    && return :bottom
    side == :bottom && return :top
    check_side(side)
end

"""
    boundary_cells(poly, side) -> Vector{Tuple{Int,Int}}

Return cells of `poly` that are exposed on `side` (:top/:bottom/:left/:right),
sorted along the edge (by column for top/bottom, by row for left/right).
"""
function boundary_cells(poly::Polyomino, side::Symbol)
    check_side(side)
    coords = coordinates(poly)
    cells, sortkey, primary = if side == :right
        [(r, c) for (r, c) in coords if (r, c+1) ∉ poly], x -> (x[1], -x[2]), x -> x[1]
    elseif side == :left
        [(r, c) for (r, c) in coords if (r, c-1) ∉ poly], x -> (x[1],  x[2]), x -> x[1]
    elseif side == :top
        [(r, c) for (r, c) in coords if (r+1, c) ∉ poly], x -> (x[2], -x[1]), x -> x[2]
    else  # :bottom
        [(r, c) for (r, c) in coords if (r-1, c) ∉ poly], x -> (x[2],  x[1]), x -> x[2]
    end

    sorted = sort(cells, by = sortkey)

    # one cell per primary coordinate — outermost wins, interior concavities skipped
    seen = Set{Int}()
    filter(sorted) do c
        k = primary(c)
        k ∈ seen ? false : (push!(seen, k); true)
    end
end

# Offset (dr, dc) that moves `poly2`'s anchor cell next to `poly1`'s anchor cell, or
# `nothing` if `pos1`/`pos2` is out of range. Does not check for overlap.
function attach_offset(poly1::Polyomino, poly2::Polyomino, side::Symbol, pos1::Int, pos2::Int)
    b1 = boundary_cells(poly1, side)
    b2 = boundary_cells(poly2, opposite_side(side))
    (1 <= pos1 <= length(b1) && 1 <= pos2 <= length(b2)) || return nothing

    (r1, c1) = b1[pos1]
    (r2, c2) = b2[pos2]
    target = side == :right ? (r1, c1 + 1) :
             side == :left  ? (r1, c1 - 1) :
             side == :top   ? (r1 + 1, c1) : (r1 - 1, c1)
    return (target[1] - r2, target[2] - c2)
end

overlaps(poly1::Polyomino, poly2::Polyomino, (dr, dc)) =
    any(((r, c),) -> (r + dr, c + dc) in poly1, coordinates(poly2))

"""
    concatenate(poly1, poly2; side, pos1, pos2) -> Polyomino

Attach `poly2` to `poly1` along `side` of `poly1`.

- `side`  : which face of `poly1` to attach to (:top/:bottom/:left/:right)
- `pos1`  : 1-based index into `poly1`'s boundary cells on that side (sorted along edge,
            outermost first when concavities create ties)
- `pos2`  : 1-based index into `poly2`'s boundary cells on the opposite side

Use `boundary_cells(poly, side)` to inspect the available positions and their order.
Throws if a position is out of range or the placement causes overlap.

`poly2` is translated so that its anchor cell sits next to `poly1`'s anchor cell; the
result is the union of the two, provided they do not overlap.
"""
function concatenate(poly1::Polyomino, poly2::Polyomino;
                     side::Symbol = :right, pos1::Int = 1, pos2::Int = 1)
    offset = attach_offset(poly1, poly2, side, pos1, pos2)
    if offset === nothing
        n1 = length(boundary_cells(poly1, side))
        n2 = length(boundary_cells(poly2, opposite_side(side)))
        1 <= pos1 <= n1 || error("pos1=$pos1 out of range [1, $n1]")
        error("pos2=$pos2 out of range [1, $n2]")
    end
    overlaps(poly1, poly2, offset) &&
        error("Concatenation results in overlap (pos1=$pos1, pos2=$pos2, side=$side)")

    (dr, dc) = offset
    # the pieces are connected, disjoint and edge-adjacent at the anchors
    _polyomino_unchecked([coordinates(poly1); [(r + dr, c + dc) for (r, c) in coordinates(poly2)]])
end
