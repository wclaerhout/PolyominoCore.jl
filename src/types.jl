struct Polyomino
    coordinates::Set{Tuple{Int,Int}}
    
    function Polyomino(coords)
        min_r = minimum(r for (r, _) in coords)
        min_c = minimum(c for (_, c) in coords)
        normalized = Set((r - min_r, c - min_c) for (r, c) in coords)
        new(normalized)
    end
end

### Make function coordinates that returns coordinates of a Polyomino

Base.:(==)(p1::Polyomino, p2::Polyomino) = p1.coordinates == p2.coordinates