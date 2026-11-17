# Representation benchmarks (research question R1 in CLAUDE.md).
#
#   julia --project=benchmark benchmark/benchmarks.jl
#
# Uses only API that exists since v0.1, so the same script can be pointed at an older
# checkout to compare (put that checkout's path in a scratch environment instead).

using Polyominoes, BenchmarkTools
using Polyominoes: canonical

# Level-by-level growth: every fixed n-omino is a fixed (n-1)-omino plus one neighbour.
function fixed_polyominoes(n)
    level = Set([Polyomino([(1, 1)])])
    for _ in 2:n
        next = Set{Polyomino}()
        for p in level
            cells = coordinates(p)
            occupied = Set(cells)
            for (r, c) in cells, nb in ((r + 1, c), (r - 1, c), (r, c + 1), (r, c - 1))
                nb in occupied && continue
                push!(next, Polyomino(push!(copy(cells), nb)))
            end
        end
        level = next
    end
    return collect(level)
end

shapes8 = fixed_polyominoes(8)
@assert length(shapes8) == 2725
@assert length(fixed_polyominoes(10)) == 36446

count_shapes(ps) = (d = Dict{Polyomino,Int}(); for p in ps; d[p] = get(d, p, 0) + 1; end; d)
keys8 = [Polyomino(coordinates(p)) for p in shapes8 for _ in 1:4]  # repeated, equal shapes

results = (
    enumerate_10 = @belapsed(fixed_polyominoes(10), samples = 3, evals = 1),
    canonical_full_8 = @belapsed(foreach(p -> canonical(p; symmetry = :full), $shapes8)),
    all_splits_8 = @belapsed(foreach(all_splits, $shapes8), samples = 5, evals = 1),
    unique_splits_8 = @belapsed(foreach(unique_splits, $shapes8), samples = 5, evals = 1),
    dict_keys_8 = @belapsed(count_shapes($keys8)),
)

for (k, t) in pairs(results)
    println(rpad(k, 18), lpad(round(t * 1e3; digits = 2), 10), " ms")
end
