"""
    polyominoes(n; symmetry = :translation) -> Vector{Polyomino}

All polyominoes with `n` cells, one per equivalence class under `symmetry`:

- `:translation`: fixed polyominoes (OEIS A001168: 1, 2, 6, 19, 63, 216, …)
- `:rotation`:    one-sided polyominoes (A000988: 1, 1, 2, 7, 18, 60, …)
- `:full`:        free polyominoes (A000105: 1, 1, 2, 5, 12, 35, …)

Each class is represented by its [`Polyominoes.canonical`](@ref) form, and the result is
sorted by `coordinates`, so the output is deterministic.

Shapes are grown level by level: every `n`-omino is an `(n-1)`-omino plus one
edge-adjacent cell. Memory grows with the number of shapes, which is fine up to about
`n = 12` (505,861 fixed 12-ominoes).

```julia
length(polyominoes(5; symmetry = :full))   # 12 free pentominoes
```
"""
function polyominoes(n::Integer; symmetry::Symbol = :translation)
    check_symmetry(symmetry)
    n >= 1 || throw(ArgumentError("polyominoes: n must be at least 1, got $n"))

    level = [_polyomino_unchecked([(1, 1)])]
    for _ in 2:n
        next = Set{Polyomino}()
        for p in level
            cells = coordinates(p)
            for (r, c) in cells, nb in ((r + 1, c), (r - 1, c), (r, c + 1), (r, c - 1))
                nb in p && continue
                # a polyomino plus an edge-adjacent cell is still connected
                q = _polyomino_unchecked(push!(copy(cells), nb))
                push!(next, canonical(q; symmetry))
            end
        end
        level = collect(next)
    end
    sort!(level; by = coordinates)
end
