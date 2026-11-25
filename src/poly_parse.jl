"""
    parse_polyomino(s) -> Polyomino

Build a `Polyomino` from an ASCII drawing. Exactly two grid characters:

- `#` — a filled cell (block)
- `.` — an empty cell (gap / cavity)

All whitespace is ignored, so source indentation and trailing spaces don't matter; use `.`
(not spaces) for gaps. Columns are 1-based; the **top** text line is the top of the shape.
Blank lines are dropped anywhere. Throws on an unknown character, an empty drawing, or a
drawing whose filled cells are not connected (not a valid polyomino).

```julia
parse_polyomino(\"\"\"
.#
##
\"\"\")            # an L-corner of 3 cells
```
"""
function parse_polyomino(s::AbstractString)
    rows = String[]
    for line in split(s, '\n')
        stripped = filter(!isspace, line)        # whitespace is never significant
        isempty(stripped) || push!(rows, stripped)
    end
    isempty(rows) && throw(ArgumentError("parse_polyomino: empty drawing"))

    n = length(rows)
    coords = Set{Tuple{Int,Int}}()
    for (i, row) in enumerate(rows)
        r = n - i + 1                            # top line => largest row, draws on top
        for (c, ch) in enumerate(row)
            if ch == '#'
                push!(coords, (r, c))
            elseif ch != '.'
                throw(ArgumentError("parse_polyomino: unexpected character '$ch' (use '#' filled, '.' empty)"))
            end
        end
    end
    isempty(coords) && throw(ArgumentError("parse_polyomino: drawing has no filled cells"))
    Polyomino(coords)   # constructor rejects disconnected cells
end

"""
    poly"..." -> Polyomino

String-macro sugar for [`parse_polyomino`](@ref). Use triple quotes for multi-row shapes:

```julia
t = poly\"\"\"
###
.#.
\"\"\"
```
"""
macro poly_str(s)
    :(parse_polyomino($s))
end
