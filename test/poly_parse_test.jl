# single row
@test parse_polyomino("###") == Polyomino(Set([(1, 1), (1, 2), (1, 3)]))

# string macro equals the function
@test poly"###" == parse_polyomino("###")

# '.' marks empty cells; top line is the top of the shape
L = poly"""
.#
##
"""
@test L == Polyomino(Set([(2, 2), (1, 1), (1, 2)]))

# 2x2 square
@test poly"""
##
##
""" == Polyomino(Set([(1, 1), (1, 2), (2, 1), (2, 2)]))

# indentation / trailing spaces are ignored; gaps must use '.'
@test poly"""
   .#
   ##
""" == L

# leading/trailing blank lines ignored
@test poly"""

##

""" == Polyomino(Set([(1, 1), (1, 2)]))

# round-trips through the rest of the toolbox
@test length(all_splits(poly"##")) == 1

# --- validity ---

@test is_connected(poly"##")
@test is_connected(Set([(1, 1), (1, 3)])) == false              # detached cells (raw set)

# the constructor itself rejects invalid molecules
@test_throws ErrorException Polyomino(Set([(1, 1), (1, 3)]))    # disconnected
@test_throws ErrorException Polyomino(Set{Tuple{Int,Int}}())    # empty

# errors: empty, unknown char, disconnected drawing
@test_throws ErrorException parse_polyomino("   ")
@test_throws ErrorException parse_polyomino("#X#")
@test_throws ErrorException parse_polyomino("#.#")              # gap splits it in two
