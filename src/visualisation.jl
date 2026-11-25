# Plotting lives in the `PolyominoesMakieExt` package extension (ext/), which loads
# automatically once a Makie backend (e.g. `using CairoMakie`) is loaded. The functions
# are declared here without methods so they are exported either way.

"""
    visualize_polyomino(p::Polyomino; annotation = :none) -> Makie.Figure

Draw `p` as unit squares, oriented like the `poly"..."` drawing (rows grow upward).

`annotation` chooses what is drawn around the shape:

| `annotation` | draws                                                             |
|:-------------|:------------------------------------------------------------------|
| `:none`      | only the shape (the default)                                      |
| `:grid`      | the shape on the cell grid of its bounding box                    |
| `:full`      | the grid plus axes labelled with the row `r` and column `c` of each cell, as in [`coordinates`](@ref) |

Requires a Makie backend, e.g. `using CairoMakie`.
"""
function visualize_polyomino end

"""
    visualize_polyominoes(ps::AbstractVector{Polyomino}; ncols = 2, annotation = :none) -> Makie.Figure

Draw several polyominoes in a grid with `ncols` columns, one panel per shape (titled by
its index), all on shared axis limits so sizes are comparable. Shapes are oriented like
[`visualize_polyomino`](@ref), and `annotation` works the same way; the grid covers the
largest bounding box among `ps`.
Requires a Makie backend, e.g. `using CairoMakie`.
"""
function visualize_polyominoes end

function _plotting_hint(io, exc, argtypes, kwargs)
    if exc.f in (visualize_polyomino, visualize_polyominoes) &&
       isempty(methods(exc.f))
        print(io, "\n$(nameof(exc.f)) needs a Makie backend; run `using CairoMakie` ",
              "(or GLMakie/WGLMakie) first.")
    end
end

function __init__()
    Base.Experimental.register_error_hint(_plotting_hint, MethodError)
end
