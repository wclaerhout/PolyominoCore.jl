using PolyominoCore: rotate90, reflect, orientations, canonical, is_equivalent

L4   = poly"""
#.
#.
##
"""                                   # L-tetromino: chiral, 4 rotations, 8 orientations
T4   = poly"""
###
.#.
"""                                   # T-tetromino: mirror-symmetric, 4 orientations
sq   = poly"""
##
##
"""
I3   = poly"###"
mono = poly"#"

# --- transformations ---

# quarter turn: horizontal I becomes vertical I
@test rotate90(I3) == Polyomino(Set([(1, 1), (2, 1), (3, 1)]))
# four quarter turns / two reflections are the identity
@test rotate90(rotate90(rotate90(rotate90(L4)))) == L4
@test reflect(reflect(L4)) == L4
# results stay normalized and keep their cell count
for q in orientations(L4; symmetry = :full)
    @test minimum(r for (r, _) in coordinates(q)) == 1
    @test minimum(c for (_, c) in coordinates(q)) == 1
    @test length(q) == 4
end

# --- orientations ---

@test orientations(L4) == [L4]                               # default: translation only
@test first(orientations(L4; symmetry = :rotation)) == L4    # starts with p itself
@test length(orientations(L4;   symmetry = :rotation)) == 4
@test length(orientations(L4;   symmetry = :full))     == 8
@test length(orientations(T4;   symmetry = :full))     == 4
@test length(orientations(I3;   symmetry = :rotation)) == 2
@test length(orientations(sq;   symmetry = :full))     == 1
@test length(orientations(mono; symmetry = :full))     == 1

# --- canonical / is_equivalent ---

@test canonical(L4) === L4                                   # default: identity
for q in orientations(L4; symmetry = :rotation)
    @test canonical(q; symmetry = :rotation) == canonical(L4; symmetry = :rotation)
end
@test is_equivalent(I3, rotate90(I3); symmetry = :rotation)
@test !is_equivalent(I3, rotate90(I3))                       # default unchanged: different fixed shapes
# a mirror image of a chiral piece is a rotation only under :full
@test !is_equivalent(L4, reflect(L4); symmetry = :rotation)
@test  is_equivalent(L4, reflect(L4); symmetry = :full)
# the 5 free tetrominoes = 7 one-sided = 19 fixed
tetros = Set(Polyomino(Set(c)) for c in
    (Set([(1,1),(1,2),(1,3),(1,4)]), Set([(1,1),(1,2),(2,1),(2,2)]),
     Set([(1,1),(1,2),(1,3),(2,2)]), Set([(1,1),(1,2),(1,3),(2,1)]),
     Set([(1,1),(1,2),(2,2),(2,3)])))
fixed = Set(q for t in tetros for q in orientations(t; symmetry = :full))
@test length(fixed) == 19
@test length(Set(canonical(q; symmetry = :rotation) for q in fixed)) == 7
@test length(Set(canonical(q; symmetry = :full)     for q in fixed)) == 5

@test_throws ArgumentError orientations(L4; symmetry = :bogus)
@test_throws ArgumentError canonical(L4; symmetry = :bogus)
@test_throws ArgumentError is_equivalent(L4, L4; symmetry = :bogus)
@test_throws ArgumentError unique_splits(L4; symmetry = :bogus)

# --- defaults are unchanged (regression against the pre-symmetry implementation) ---

function unique_splits_reference(p)
    KeyT   = Set{Vector{Tuple{Int,Int}}}
    counts = Dict{KeyT,Int}()
    reps   = Dict{KeyT,Tuple{Polyomino,Polyomino}}()
    for (a, b) in all_splits(p)
        key = Set([coordinates(a), coordinates(b)])
        if haskey(counts, key)
            counts[key] += 1
        else
            counts[key] = 1
            reps[key]   = (a, b)
        end
    end
    [(reps[k][1], reps[k][2], counts[k]) for k in keys(counts)]
end

shapes = (mono, I3, sq, L4, T4, poly"""
###
#.#
###
""")
for p in shapes
    # same pairs and multiplicities; the order is first-seen (the reference's is Dict order)
    @test Set(unique_splits(p)) == Set(unique_splits_reference(p))
    @test Set(unique_splits(p; symmetry = :translation)) == Set(unique_splits_reference(p))
end

# --- unique_splits with symmetry ---

# 2x2: under translation the 4 (L-tromino + monomino) cuts are distinct; under rotation they merge
us_rot = unique_splits(sq; symmetry = :rotation)
@test length(unique_splits(sq)) == 6
@test length(us_rot) == 2                                    # {L3, mono} ×4 and {I2, I2} ×2
@test sort([m for (_, _, m) in us_rot]) == [2, 4]
for p in shapes, sym in (:rotation, :full)
    @test sum((m for (_, _, m) in unique_splits(p; symmetry = sym)); init = 0) == length(all_splits(p))
end
