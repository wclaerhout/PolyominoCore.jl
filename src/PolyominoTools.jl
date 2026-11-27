module PolyominoTools

include("types.jl")
include("symmetry.jl")
include("poly_parse.jl")
include("splits.jl")
include("enumeration.jl")
include("attach.jl")
include("properties.jl")
include("visualisation.jl")

export Polyomino, coordinates
export parse_polyomino, @poly_str
export is_connected, all_splits, unique_splits
export polyominoes
export attach, attachments
export perimeter, nholes
export visualize_polyomino, visualize_polyominoes

# Symmetry helpers are public but not exported, so they can't clash with names in
# downstream packages. Use `PolyominoTools.rotate90` or `using PolyominoTools: rotate90`.
@static if VERSION >= v"1.11.0-DEV.469"
    eval(Meta.parse("public rotate90, reflect, orientations, canonical, is_equivalent, symmetry_group"))
end

end # module PolyominoTools
