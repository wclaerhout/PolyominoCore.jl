# Plotting lives in the `PolyominoesMakieExt` package extension (ext/), which loads
# automatically once a Makie backend (e.g. `using CairoMakie`) is loaded. The functions
# are declared here without methods so they are exported either way.

"""
    visualize_polyomino(p::Polyomino) -> Makie.Figure

Draw `p` as unit squares, oriented like the `poly"..."` drawing (rows grow upward).
Requires a Makie backend, e.g. `using CairoMakie`.
"""
function visualize_polyomino end

"""
    visualize_pathway(ps::AbstractVector{Polyomino}) -> Makie.Figure

Draw a sequence of polyominoes in a two-column grid on shared axis limits, one panel
per step, oriented like [`visualize_polyomino`](@ref).
Requires a Makie backend, e.g. `using CairoMakie`.
"""
function visualize_pathway end

function _plotting_hint(io, exc, argtypes, kwargs)
    if exc.f in (visualize_polyomino, visualize_pathway) &&
       isempty(methods(exc.f))
        print(io, "\n$(nameof(exc.f)) needs a Makie backend; run `using CairoMakie` ",
              "(or GLMakie/WGLMakie) first.")
    end
end

function __init__()
    Base.Experimental.register_error_hint(_plotting_hint, MethodError)
end
