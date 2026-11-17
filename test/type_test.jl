p1 = Polyomino(Set([(1,1), (2,1), (3,1)]))

@test size(p1) == (3, 1)
@test size(p1, 1) == 3 && size(p1, 2) == 1
@test_throws MethodError size("Throw MethodError please", 1, 2, 3)

# --- construction and normalization ---

L = poly"""
#.
##
"""
@test coordinates(L) == [(1, 1), (1, 2), (2, 1)]                       # sorted
@test Polyomino([(5, 7), (5, 8), (6, 7)]) == L                          # translation-normalized
@test Polyomino([(1, 1), (1, 2), (2, 1), (1, 1)]) == L                  # duplicates ignored
@test Polyomino((r, c) for (r, c) in coordinates(L)) == L               # any iterable
@test Polyomino(L) == L
@test hash(Polyomino([(9, 9), (9, 10), (10, 9)])) == hash(L)
@test L != poly"##"
@test length(Set([L, Polyomino([(0, 0), (0, 1), (1, 0)]), poly"##"])) == 2
@test_throws MethodError Polyomino(Set([(1, 1)]), UInt(0))              # no default constructor
@test_throws MethodError Polyomino("not a polyomino")

# --- collection interface ---

@test length(L) == 3
@test size(L) == (2, 2)
@test (2, 1) in L
@test (2, 2) ∉ L
@test (0, 0) ∉ L
@test collect(L) == coordinates(L)
@test eltype(L) == Tuple{Int,Int}
@test [r for (r, _) in L] == [1, 1, 2]

# --- display ---

@test sprint(show, MIME"text/plain"(), L) == "3-cell Polyomino (2×2):\n #.\n ##"
@test sprint(show, L) == "Polyomino([(1, 1), (1, 2), (2, 1)])"
@test eval(Meta.parse(sprint(show, L))) == L                            # compact form round-trips
# the drawing can be pasted back into the parser (header line dropped)
for p in (L, poly"###", p1, poly"""
    ###
    #.#
    ###
    """)
    drawing = join(split(sprint(show, MIME"text/plain"(), p), '\n')[2:end], '\n')
    @test parse_polyomino(drawing) == p
end
