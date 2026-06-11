p1 = Polyomino(Set([(1,1), (2,1), (3,1)]))

@test poly_height(p1) == 3
@test poly_width(p1) == 1
@test_throws MethodError poly_width("Throw Mehoderror please")