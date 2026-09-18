module Polyomino

include("types.jl")
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

end # module Polyomino
