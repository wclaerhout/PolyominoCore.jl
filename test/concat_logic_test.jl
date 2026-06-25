p1 = Polyomino(Set([(1, 1), (1,2), (2,1)]))
p2 = concatenate(p1, p1; side =:bottom, pos1 = 1, pos2 = 1)

@test concatenation_possible(p1, p1; side ="bottom", pos1 = 1, pos2 = 1) == true

p3 = Polyomino(Set([(1,1), (2,1), (2,2)]))
p4 = Polyomino(Set([(1,1), (1,2), (1,3)]))

@test concatenation_possible(p3, p4; side = "bottom", pos1 = 2, pos2 = 2) == false

# --- splitting (reverse reaction) ---

# single cell cannot split
@test isempty(all_splits(Polyomino(Set([(1, 1)]))))

# domino: one split, two unit cells
dom = Polyomino(Set([(1, 1), (1, 2)]))
sp = all_splits(dom)
@test length(sp) == 1
@test all(coordinates(a) == Set([(1, 1)]) && coordinates(b) == Set([(1, 1)]) for (a, b) in sp)

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

# the cavity case: full 3x3 splits into ring + centre (reverse legal; assembly is not)
full3 = Polyomino(Set([(r, c) for r in 1:3 for c in 1:3]))
ring  = Set([(r, c) for r in 1:3 for c in 1:3 if (r, c) != (2, 2)])
@test any(coordinates(a) == Polyomino(ring).coordinates && length(coordinates(b)) == 1 ||
          coordinates(b) == Polyomino(ring).coordinates && length(coordinates(a)) == 1
          for (a, b) in all_splits(full3))