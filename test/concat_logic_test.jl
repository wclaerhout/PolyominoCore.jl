p1 = Polyomino(Set([(1, 1), (1,2), (2,1)]))
p2 = concatenate(p1, p1; side =:bottom, pos1 = 1, pos2 = 1)

@test concatenation_possible(p1, p1; side ="bottom", pos1 = 1, pos2 = 1) == true

p3 = Polyomino(Set([(1,1), (2,1), (2,2)]))
p4 = Polyomino(Set([(1,1), (1,2), (1,3)]))

@test concatenation_possible(p3, p4; side = "bottom", pos1 = 2, pos2 = 2) == false

# --- splitting ---

# single cell cannot split
@test isempty(all_splits(Polyomino(Set([(1, 1)]))))

# domino: one split, two unit cells
dom = Polyomino(Set([(1, 1), (1, 2)]))
sp = all_splits(dom)
@test length(sp) == 1
@test all(coordinates(a) == [(1, 1)] && coordinates(b) == [(1, 1)] for (a, b) in sp)

# every split partitions all cells into two connected, disjoint, non-empty pieces
sq = Polyomino(Set([(1, 1), (1, 2), (2, 1), (2, 2)]))   # 2x2
for (a, b) in all_splits(sq)
    ca, cb = coordinates(a), coordinates(b)
    @test !isempty(ca) && !isempty(cb)
    @test length(ca) + length(cb) == 4       # pieces partition all cells (mass conserved)
    @test is_connected(ca) && is_connected(cb)
end

# splits are unordered: each counted once (2x2 has 4 L-tromino+monomino + 2 domino+domino = 6)
@test length(all_splits(sq)) == 6

# the hole case: full 3x3 splits into ring + centre
full3 = Polyomino(Set([(r, c) for r in 1:3 for c in 1:3]))
ring  = Set([(r, c) for r in 1:3 for c in 1:3 if (r, c) != (2, 2)])
@test any(coordinates(a) == coordinates(Polyomino(ring)) && length(coordinates(b)) == 1 ||
          coordinates(b) == coordinates(Polyomino(ring)) && length(coordinates(a)) == 1
          for (a, b) in all_splits(full3))

# --- unique splits with multiplicity ---

# 1x3 straight tromino: two cuts, both give monomino + domino => one pair, multiplicity 2
tri = Polyomino(Set([(1, 1), (1, 2), (1, 3)]))
us = unique_splits(tri)
@test length(us) == 1
@test us[1][3] == 2

# multiplicities always sum back to the raw split count
for poly in (dom, sq, tri, full3)
    @test sum(m for (_, _, m) in unique_splits(poly)) == length(all_splits(poly))
end

# 2x2 has no translation-equivalent product pairs: 6 raw splits, 6 unique, all multiplicity 1
@test length(unique_splits(sq)) == 6
@test all(m == 1 for (_, _, m) in unique_splits(sq))
# --- concatenation_possible: no try/catch ---

@test concatenation_possible(p1, p1; side = :bottom) == concatenation_possible(p1, p1; side = "bottom")
@test concatenation_possible(p1, p1; side = :bottom, pos1 = 99) == false     # out of range
@test concatenation_possible(p1, p1; side = :bottom, pos2 = 0) == false
@test_throws ArgumentError concatenation_possible(p1, p1; side = :diagonal)  # caller bug surfaces
@test_throws ArgumentError concatenate(p1, p1; side = :diagonal)
@test_throws ErrorException concatenate(p1, p1; side = :bottom, pos1 = 99)
# agrees with whether `concatenate` succeeds, for every side and position
for a in (p1, p3, p4, poly"""
    ###
    #.#
    """), b in (p1, p3, p4), side in (:top, :bottom, :left, :right)
    n1 = length(Polyominoes.boundary_cells(a, side))
    n2 = length(Polyominoes.boundary_cells(b, Polyominoes.opposite_side(side)))
    for i in 0:n1 + 1, j in 0:n2 + 1
        ok = try
            concatenate(a, b; side, pos1 = i, pos2 = j); true
        catch e
            e isa ErrorException || rethrow()
            false
        end
        @test concatenation_possible(a, b; side, pos1 = i, pos2 = j) == ok
    end
end

# --- all_splits matches a naive subset enumeration ---

# every partition into two connected parts, each unordered pair once (cell 1 is in A),
# tallied by the pair of shapes
function split_tally(splits)
    d = Dict{Set{Polyomino},Int}()
    for (a, b) in splits
        k = Set([a, b])
        d[k] = get(d, k, 0) + 1
    end
    d
end
function all_splits_reference(p)
    cells = coordinates(p)
    n = length(cells)
    out = Tuple{Polyomino,Polyomino}[]
    for mask in 1:2:(2^n - 2)                      # odd masks: cell 1 always in A
        A = [cells[i] for i in 1:n if (mask >> (i - 1)) & 1 == 1]
        B = setdiff(cells, A)
        is_connected(A) && is_connected(B) && push!(out, (Polyomino(A), Polyomino(B)))
    end
    out
end
for p in (p1, p3, p4, poly"#", poly"""
    ###
    #.#
    ###
    """, poly"""
    .##.
    ####
    .#..
    """)
    @test split_tally(all_splits(p)) == split_tally(all_splits_reference(p))
    @test all(length(a) + length(b) == length(p) for (a, b) in all_splits(p))
end
