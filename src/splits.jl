"""
    all_splits(p) -> Vector{Tuple{Polyomino,Polyomino}}

Enumerate every way to partition `p` into two non-empty connected polyominoes
`(A, B)` with `A ∪ B == p`, `A ∩ B == ∅`. Each unordered split is returned once.

Adjacency of `A` and `B` is automatic: `p` is connected, so two connected pieces
that partition it must touch. No other restriction applies; for example, a shape
may be split into a ring and the piece that fills its hole.
"""
function all_splits(p::Polyomino)
    cells = coordinates(p)
    n = length(cells)
    out = Tuple{Polyomino,Polyomino}[]
    n < 2 && return out
    n <= 63 || throw(ArgumentError("all_splits: polyomino too large ($n cells; max 63)"))

    # cell i <-> bit i-1; nbrs[i] = bitmask of the edge-neighbours of cell i
    nbrs = [reduce(|, (UInt64(1) << (j - 1) for j in 1:n if abs(r - cells[j][1]) + abs(c - cells[j][2]) == 1);
                   init = UInt64(0)) for (r, c) in cells]
    full = (UInt64(1) << n) - 1

    # cell 1 is pinned into A so each unordered split is counted once
    for mask in UInt64(0):((UInt64(1) << (n - 1)) - 1)
        A = UInt64(1) | (mask << 1)
        A == full && continue                   # B would be empty
        B = full & ~A
        (connected_bits(A, nbrs) && connected_bits(B, nbrs)) || continue
        push!(out, (cells_piece(cells, A), cells_piece(cells, B)))
    end
    out
end

# Is the cell subset `S` (a bitmask) edge-connected? Flood fill from its lowest cell.
function connected_bits(S::UInt64, nbrs::Vector{UInt64})
    seen = S & -S
    while true
        grown = seen
        b = seen
        while b != 0
            grown |= nbrs[trailing_zeros(b) + 1] & S
            b &= b - 1
        end
        grown == seen && return seen == S
        seen = grown
    end
end

function cells_piece(cells, S::UInt64)
    piece = Vector{Tuple{Int,Int}}(undef, count_ones(S))
    k = 0
    while S != 0
        piece[k += 1] = cells[trailing_zeros(S) + 1]
        S &= S - 1
    end
    _polyomino_unchecked(piece)   # connectivity already checked
end

"""
    unique_splits(p) -> Vector{Tuple{Polyomino,Polyomino,Int}}

Collapse `all_splits(p)` to **unique unordered pairs of shapes**, each tagged with its
**multiplicity**: the number of distinct cuts of `p` that yield that same pair of shapes
(compared up to translation by default). `sum(m for (_,_,m) in unique_splits(p))`
equals `length(all_splits(p))`.

With `symmetry = :rotation` (or `:full`) product shapes are additionally compared up to
rotation (and reflection), so pairs that are rotated copies of each other merge and their
multiplicities add. The returned representatives are the shapes as actually cut from `p`,
in the order they first appear in `all_splits(p)`.
"""
function unique_splits(p::Polyomino; symmetry::Symbol = :translation)
    check_symmetry(symmetry)
    index = Dict{Tuple{Polyomino,Polyomino},Int}()   # unordered shape pair -> slot in `out`
    out   = Tuple{Polyomino,Polyomino,Int}[]
    for (a, b) in all_splits(p)
        ca, cb = canonical(a; symmetry), canonical(b; symmetry)
        key = coordinates(ca) <= coordinates(cb) ? (ca, cb) : (cb, ca)
        i = get(index, key, 0)
        if i == 0
            push!(out, (a, b, 1))
            index[key] = length(out)
        else
            out[i] = (out[i][1], out[i][2], out[i][3] + 1)
        end
    end
    out
end
