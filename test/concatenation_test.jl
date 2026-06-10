p1 = Polyomino(Set([(1, 1), (1,2), (2,1)]))
p2 = concatenate(p1, p1; side =:bottom, pos1 = 1, pos2 = 1)

p_val = Polyomino(Set([(0,0),(1,0),(2,0), (3,0), (0, 1), (2,1)]))
@test p_val == p2
