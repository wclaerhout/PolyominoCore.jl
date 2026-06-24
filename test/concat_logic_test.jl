p1 = Polyomino(Set([(1, 1), (1,2), (2,1)]))
p2 = concatenate(p1, p1; side =:bottom, pos1 = 1, pos2 = 1)

@test concatenation_possible(p1, p1; side ="bottom", pos1 = 1, pos2 = 1) == true

p3 = Polyomino(Set([(1,1), (2,1), (2,2)]))
p4 = Polyomino(Set([(1,1), (1,2), (1,3)]))

@test concatenation_possible(p3, p4; side = "bottom", pos1 = 2, pos2 = 2) == false