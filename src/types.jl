"""
    is_connected(cells) -> Bool

True if `cells` (a collection of `(r, c)` tuples) forms one edge-connected
(4-neighbour) blob. The empty collection is not connected. Flood fill: starting from
one cell, keep adding unseen neighbours until none are left; the cells are connected
if every cell was reached.
"""
function is_connected(cells)
    cellset = cells isa AbstractSet ? cells : Set(cells)
    isempty(cellset) && return false
    start = first(cellset)
    seen  = Set([start])
    stack = [start]
    while !isempty(stack)
        (r, c) = pop!(stack)
        for nb in ((r + 1, c), (r - 1, c), (r, c + 1), (r, c - 1))
            if nb in cellset && !(nb in seen)
                push!(seen, nb)
                push!(stack, nb)
            end
        end
    end
    length(seen) == length(cellset)
end

"""
    Polyomino(cells)

A polyomino: a finite, non-empty, edge-connected set of unit cells `(r, c)` on the
square grid. Rows grow **upward** and columns grow to the right, so `(1, 1)` is the
bottom-left cell of the bounding box.

`cells` may be any collection of `(r, c)` tuples (a `Set`, a `Vector`, a generator);
duplicates are ignored. The shape is normalized for translation (smallest row and
column become 1), so `==` and `hash` compare shapes up to translation only. Use the
`symmetry` keyword of [`Polyominoes.canonical`](@ref) to also identify rotations or
reflections. Throws if `cells` is empty or not connected.
"""
struct Polyomino
    # Sorted, translation-normalized cells. Treat as read-only: `coordinates` returns it
    # without copying.
    coordinates::Vector{Tuple{Int,Int}}
    hash::UInt

    # Trusted path: `cells` is non-empty, duplicate-free and connected.
    global function _polyomino_unchecked(cells::Vector{Tuple{Int,Int}})
        min_r = minimum(first, cells)
        min_c = minimum(last, cells)
        if min_r != 1 || min_c != 1
            cells .= ((r - min_r + 1, c - min_c + 1) for (r, c) in cells)
        end
        sort!(cells)
        new(cells, hash(cells, 0x5f6c2b3a9d1e4f87 % UInt))
    end
end

function Polyomino(cells)
    v = unique!(sort!(Tuple{Int,Int}[convert(Tuple{Int,Int}, x) for x in cells]))
    isempty(v) && error("Polyomino: needs at least one cell")
    is_connected(v) ||
        error("Polyomino: cells are not connected — not a valid polyomino ($v)")
    _polyomino_unchecked(v)
end

Base.:(==)(p::Polyomino, q::Polyomino) = p.hash == q.hash && p.coordinates == q.coordinates
Base.hash(p::Polyomino, h::UInt) = hash(p.hash, h)

"""
    coordinates(p) -> Vector{Tuple{Int,Int}}

The cells of `p`, normalized so the smallest row and column are 1, sorted
lexicographically. Returns the stored vector without copying: do not mutate it.
"""
coordinates(p::Polyomino) = p.coordinates

"""
    is_connected(p::Polyomino) -> Bool

Always `true` for a constructed `Polyomino` (the constructor enforces it); provided for
explicit validity checks on cell collections via the generic method.
"""
is_connected(p::Polyomino) = true

# --- collection interface: a polyomino is a set of cells -------------------------

"""
    length(p::Polyomino) -> Int

Number of cells.
"""
Base.length(p::Polyomino) = length(p.coordinates)

"""
    size(p::Polyomino) -> (height, width)

Size of the bounding box: number of rows and number of columns.
"""
Base.size(p::Polyomino) = (last(p.coordinates)[1], maximum(last, p.coordinates))
Base.size(p::Polyomino, d::Integer) = size(p)[d]

"""
    cell in p

True if the cell `(r, c)` belongs to `p`, in `p`'s normalized coordinates.
"""
function Base.in(cell::Tuple{Integer,Integer}, p::Polyomino)
    cs = p.coordinates
    i = searchsortedfirst(cs, cell)
    i <= length(cs) && cs[i] == cell
end

Base.iterate(p::Polyomino, state...) = iterate(p.coordinates, state...)
Base.eltype(::Type{Polyomino}) = Tuple{Int,Int}
Base.IteratorSize(::Type{Polyomino}) = Base.HasLength()

# --- display -----------------------------------------------------------------------

# Rows of the `#`/`.` drawing, top row first (the format `parse_polyomino` reads).
function drawing_rows(p::Polyomino)
    h, w = size(p)
    grid = fill('.', h, w)
    for (r, c) in p.coordinates
        grid[h - r + 1, c] = '#'
    end
    [String(grid[i, :]) for i in 1:h]
end

# One line, valid Julia: `Polyomino([(1, 1), (1, 2)])`.
function Base.show(io::IO, p::Polyomino)
    print(io, "Polyomino(")
    show(IOContext(io, :typeinfo => Vector{Tuple{Int,Int}}), p.coordinates)
    print(io, ")")
end

# The drawing, indented; the lines can be pasted back into `poly"""..."""`.
function Base.show(io::IO, ::MIME"text/plain", p::Polyomino)
    h, w = size(p)
    n = length(p)
    print(io, n, "-cell Polyomino (", h, "×", w, "):")
    for row in drawing_rows(p)
        print(io, "\n ", row)
    end
end

# --- Cell / Shift (kept for polyomino_crn; to be removed in v0.2) -------------------

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
