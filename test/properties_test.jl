using Polyominoes: symmetry_group, orientations, rotate90, reflect

ring = poly"""
###
#.#
###
"""
# two empty cells touching only at a corner: two separate holes
two_holes = poly"""
###.
#.##
##.#
.###
"""
# only the enclosed hole should be counted
notch = poly"""
##.
#.#
###
"""
U = poly"""
#.#
###
"""

# --- perimeter ---

@test perimeter(poly"#") == 4
@test perimeter(poly"##") == 6
@test perimeter(poly"####") == 10
@test perimeter(poly"""
##
##
""") == 8
@test perimeter(ring) == 16                         # 12 outside + 4 around the hole
@test perimeter(U) == 12

# oracle: count the cell sides that face an empty cell
exposed_sides(p) = sum(count(nb -> nb ∉ p, ((r + 1, c), (r - 1, c), (r, c + 1), (r, c - 1)))
                       for (r, c) in coordinates(p))
for n in 1:7, p in polyominoes(n)
    @test perimeter(p) == exposed_sides(p)
end
@test perimeter(two_holes) == exposed_sides(two_holes)
# extreme values: a line has the largest perimeter, 2n + 2
@test all(perimeter(p) <= 2n + 2 for n in 1:8 for p in polyominoes(n))

# --- nholes ---

@test nholes(poly"#") == 0
@test nholes(U) == 0
@test nholes(ring) == 1
@test nholes(two_holes) == 2
@test nholes(notch) == 1
@test nholes(poly"""
#####
#.#.#
#####
""") == 2
@test nholes(poly"""
#####
#...#
#####
""") == 1
# the smallest polyomino with a hole has 7 cells (A001419: 1 heptomino with a hole)
@test all(nholes(p) == 0 for n in 1:6 for p in polyominoes(n))
@test count(p -> nholes(p) > 0, polyominoes(7; symmetry = :full)) == 1
@test count(p -> nholes(p) > 0, polyominoes(8; symmetry = :full)) == 6
# invariant under rotation and reflection
for p in (ring, two_holes, notch), q in orientations(p; symmetry = :full)
    @test nholes(q) == nholes(p)
end

# --- symmetry_group ---

@test symmetry_group(poly"#") == [:identity, :rot90, :rot180, :rot270,
                                  :mirror_lr, :mirror_ud, :mirror_diag, :mirror_antidiag]
@test symmetry_group(poly"##") == [:identity, :rot180, :mirror_lr, :mirror_ud]
@test symmetry_group(U) == [:identity, :mirror_lr]
@test symmetry_group(poly"""
#.
##
""") == [:identity, :mirror_diag]                  # mirrored in the line r = c
@test symmetry_group(poly"""
##.
.##
""") == [:identity, :rot180]                        # S/Z tetromino: no mirror symmetry
@test symmetry_group(poly"""
.#.
###
.#.
""") == symmetry_group(poly"#")                     # the plus has full D4 symmetry

# orbit–stabilizer, for every fixed polyomino up to 8 cells
for n in 1:8, p in polyominoes(n)
    G = symmetry_group(p)
    @test length(G) * length(orientations(p; symmetry = :full)) == 8
    @test first(G) == :identity
    @test (:rot90 in G) == (rotate90(p) == p)
    @test (:mirror_lr in G) == (reflect(p) == p)
end
