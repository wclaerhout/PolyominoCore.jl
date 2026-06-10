struct Polyomino
    coordinates::Set{Tuple{Int,Int}}
    
    function Polyomino(coords)
        min_r = minimum(r for (r, _) in coords)
        min_c = minimum(c for (_, c) in coords)
        normalized = Set((r - min_r, c - min_c) for (r, c) in coords)
        new(normalized)
    end
end