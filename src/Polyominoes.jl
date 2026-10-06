module Polyominoes

include("types.jl")
include("symmetry.jl")
include("poly_parse.jl")
include("concatenation.jl")
include("concat_logic.jl")
include("visualisation.jl")

export Polyomino, coordinates, poly_height, poly_width, Cell, Shift, n_blocks
export parse_polyomino, @poly_str
export concatenate
export concatenation_possible, all_valid_concatenations
export is_connected, all_splits, unique_splits
export visualize_polyomino, visualize_pathway

# Symmetry helpers are public but not exported, so they can't clash with names in
# downstream packages. Use `Polyominoes.rotate90` or `using Polyominoes: rotate90`.
@static if VERSION >= v"1.11.0-DEV.469"
    eval(Meta.parse("public rotate90, reflect, orientations, canonical, is_equivalent"))
end

end # module Polyominoes
