struct Polyomino
    coordinates::Set{Tuple{Int,Int}}
    
    function Polyomino(coords::Set{Tuple{Int, Int}})
        min_r = minimum(r for (r, _) in coords)
        min_c = minimum(c for (_, c) in coords)
        normalized = Set((r - min_r + 1, c - min_c + 1) for (r, c) in coords)
        new(normalized)
    end
end

Base.:(==)(p1::Polyomino, p2::Polyomino) = p1.coordinates == p2.coordinates

# Creating accessor functions (decoupling internals from public interface)
coordinates(p::Polyomino) = p.coordinates 

poly_height(p::Polyomino) = maximum([r for (r, _) in coordinates(p)])
poly_width(p::Polyomino) = maximum([c] for (_, c) in coordinates(p))
