"""
Symmetry support (opt-in). A `Polyomino` itself is always a *fixed* polyomino: `==` and
`hash` compare shapes up to translation only. Rotation/reflection equivalence is requested
explicitly through a `symmetry` keyword:

- `:translation` — fixed polyominoes (default everywhere; the original behaviour)
- `:rotation`    — one-sided polyominoes (the 4 rotations are equivalent)
- `:full`        — free polyominoes (rotations and reflections, up to 8 orientations)
"""

const SYMMETRIES = (:translation, :rotation, :full)

check_symmetry(symmetry::Symbol) = symmetry in SYMMETRIES ||
    throw(ArgumentError("symmetry must be one of $SYMMETRIES, got :$symmetry"))

"""
    rotate90(p) -> Polyomino

Rotate `p` a quarter turn counter-clockwise (rows point up, columns point right).
"""
rotate90(p::Polyomino) = _polyomino_unchecked([(c, -r) for (r, c) in coordinates(p)])

"""
    reflect(p) -> Polyomino

Mirror `p` left-right.
"""
reflect(p::Polyomino) = _polyomino_unchecked([(r, -c) for (r, c) in coordinates(p)])

"""
    orientations(p; symmetry = :translation) -> Vector{Polyomino}

All distinct orientations of `p` under `symmetry`, starting with `p` itself.
`:translation` gives `[p]`, `:rotation` up to 4, `:full` up to 8.
"""
function orientations(p::Polyomino; symmetry::Symbol = :translation)
    check_symmetry(symmetry)
    symmetry == :translation && return [p]
    rots = accumulate((q, _) -> rotate90(q), 1:3; init = p)
    out  = [p; rots]
    symmetry == :full && append!(out, reflect.(out))
    unique(out)
end

"""
    canonical(p; symmetry = :translation) -> Polyomino

A fixed representative of `p`'s equivalence class under `symmetry`: the orientation whose
sorted `coordinates` are lexicographically smallest. Two polyominoes are equivalent iff
their canonical forms are `==`, so this is the key to use for `Set`s / `Dict`s.
"""
function canonical(p::Polyomino; symmetry::Symbol = :translation)
    check_symmetry(symmetry)
    symmetry == :translation && return p
    argmin(coordinates, orientations(p; symmetry))
end

"""
    is_equivalent(p, q; symmetry = :translation) -> Bool

True if `p` and `q` are the same shape under `symmetry`. With the default this is `p == q`.
"""
is_equivalent(p::Polyomino, q::Polyomino; symmetry::Symbol = :translation) =
    canonical(p; symmetry) == canonical(q; symmetry)
