"""
    is_connected(cells) -> Bool

True if `cells` (a `Set` of `(r, c)`) forms one edge-connected (4-neighbour) blob.
The empty set is not connected. Based on a flood-fill algorithm.
You just keep adding neighbouring cells to the stack until none are left, the length of the seen cells
should equal the number of cells of your polyomino
"""
function is_connected(cells)
    cellset = cells isa AbstractSet ? cells : Set(cells) # accept the sorted Vector from `coordinates` too
    isempty(cellset) && return false
    start = first(cellset)
    seen  = Set([start])
    stack = [start]
    while !isempty(stack)
        (r, c) = pop!(stack)
        for nb in ((r+1, c), (r-1, c), (r, c+1), (r, c-1)) # check if the new block is the neighbour of a block that is already in the set
            if nb in cellset && !(nb in seen)
                push!(seen, nb)
                push!(stack, nb) # new cells that are neighbouring are added to the stack
            end
        end
    end
    length(seen) == length(cellset)
end

struct Polyomino
    coordinates::Set{Tuple{Int,Int}}

    function Polyomino(coords::Set{Tuple{Int, Int}})
        isempty(coords) && error("Polyomino: needs at least one cell")
        is_connected(coords) ||
            error("Polyomino: cells are not connected — not a valid polyomino ($coords)")
        min_r = minimum(r for (r, _) in coords)
        min_c = minimum(c for (_, c) in coords)
        normalized = Set((r - min_r + 1, c - min_c + 1) for (r, c) in coords)
        new(normalized)
    end
end

Base.:(==)(p1::Polyomino, p2::Polyomino) = p1.coordinates == p2.coordinates
# hash must agree with == so Polyomino works as a Set element / Dict key
Base.hash(p::Polyomino, h::UInt) = hash(p.coordinates, h)

# accept any collection of (r, c) cells (e.g. the sorted Vector from `coordinates`)
Polyomino(coords) = Polyomino(Set{Tuple{Int,Int}}(coords))

# Indexing a polyomino Set{Tuple{Int, Int}} to get a coordinate

# Creating accessor functions (decoupling internals from public interface)
coordinates(p::Polyomino) = sort!(collect(p.coordinates))

"""
    is_connected(p::Polyomino) -> Bool

Always `true` for a constructed `Polyomino` (the constructor enforces it); provided for
explicit validity checks on cell sets via the `Set` method.
"""
is_connected(p::Polyomino) = is_connected(coordinates(p))

poly_height(p::Polyomino) = maximum([r for (r, _) in coordinates(p)])
poly_width(p::Polyomino) = maximum([c for (_, c) in coordinates(p)])

n_blocks(p::Polyomino) = length(unique(coordinates(p))) # gives the number of blocks

#----------------------------------------------------------------------------------

struct Cell
    x::Int
    y::Int
end

struct Shift
    dx::Int
    dy::Int
end

Base.:-(a::Cell, b::Cell)  = Shift(a.x - b.x, a.y - b.y)   # point - point = vector
Base.:+(c::Cell, s::Shift) = Cell(c.x + s.dx, c.y + s.dy)  # point + vector = point
Base.:-(c::Cell, s::Shift) = Cell(c.x - s.dx, c.y - s.dy)
Base.:+(a::Shift, b::Shift) = Shift(a.dx + b.dx, a.dy + b.dy)
Base.:-(s::Shift) = Shift(-s.dx, -s.dy)