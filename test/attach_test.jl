using Polyominoes: canonical, orientations, is_equivalent

mono = poly"#"
dom  = poly"##"
L3 = poly"""
#.
##
"""
U = poly"""
#.#
###
"""

# --- attach ---

@test attach(mono, mono, (0, 1)) == dom
@test attach(mono, mono, (1, 0)) == poly"""
#
#
"""
@test attach(dom, mono, (1, 0)) == L3                    # on top of the left cell
@test attach(dom, mono, (0, -1)) == poly"###"            # negative offsets are fine
@test attach(U, mono, (1, 1)) == poly"""
###
###
"""                                                      # fills the hole of the U
@test_throws ArgumentError attach(dom, mono, (0, 1))     # overlap
@test_throws ArgumentError attach(dom, mono, (1, 2))     # diagonal contact only
@test_throws ArgumentError attach(dom, mono, (5, 5))     # far away

# --- attachments: small hand-checked cases ---

@test attachments(mono, mono) == sort([dom, poly"""
#
#
"""]; by = coordinates)
@test length(attachments(dom, mono)) == 5                # I3 (both ends merge) + 4 L-trominoes
@test length(attachments(dom, mono; symmetry = :full)) == 2       # I3, L3
@test length(attachments(dom, dom; symmetry = :full)) == 4        # I4, O4, S4, L4
@test poly"""
###
###
""" in attachments(U, mono)                              # the hole can be filled
@test issorted(attachments(U, L3); by = coordinates)

# placements reproduce the shapes through `attach`
for sym in (:translation, :rotation, :full)
    ps = attachments(U, L3; symmetry = sym, placements = true)
    @test [x.shape for x in ps] == attachments(U, L3; symmetry = sym)
    @test all(attach(U, x.piece, x.offset) == x.shape for x in ps)
    @test all(any(q == x.piece for q in orientations(L3; symmetry = sym)) for x in ps)
end

@test_throws ErrorException attachments(dom, mono; symmetry = :bogus)

# --- property tests ---

shapes = [polyominoes(n) for n in 1:4]
test_pairs = [(a, b) for a in reduce(vcat, shapes[1:4]) for b in reduce(vcat, shapes[1:3])]
for sym in (:translation, :rotation, :full), (a, b) in test_pairs[1:7:end]
    res = attachments(a, b; symmetry = sym)
    # the right size, distinct under the symmetry
    @test all(length(s) == length(a) + length(b) for s in res)
    @test allunique(canonical(s; symmetry = sym) for s in res)
    # every result splits back into (a, b)
    @test all(any((is_equivalent(x, a) && is_equivalent(y, b; symmetry = sym)) ||
                  (is_equivalent(y, a) && is_equivalent(x, b; symmetry = sym))
                  for (x, y) in all_splits(s)) for s in res)
end

# Growth oracle: adding a monomino in every way to every (n-1)-omino gives every n-omino.
for n in 2:6, sym in (:translation, :full)
    grown = Set(canonical(s; symmetry = sym)
                for p in polyominoes(n - 1; symmetry = sym)
                for s in attachments(p, mono; symmetry = sym))
    @test grown == Set(polyominoes(n; symmetry = sym))
end
