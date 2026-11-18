module PolyominoesMakieExt

using Makie
using Polyominoes: Polyomino, coordinates
import Polyominoes: visualize_polyomino, visualize_polyominoes

# Cell (r, c) is drawn as the unit square [c-1, c] × [r-1, r], with y growing upward,
# so the plot matches the `poly"..."` drawing (top text line = top of the shape).
function draw_polyomino!(ax, p::Polyomino)
    for (r, c) in coordinates(p)
        poly!(ax, Rect(c - 1, r - 1, 1, 1), color = :slategray1,
              strokewidth = 2, strokecolor = :black)
    end
    return ax
end

function visualize_polyomino(p::Polyomino)
    nrows = maximum(r for (r, _) in coordinates(p))
    ncols = maximum(c for (_, c) in coordinates(p))

    f = Figure()
    ax = Axis(f[1, 1], limits = (0, ncols + 1, 0, nrows + 1),
              xgridvisible = false, ygridvisible = false,
              aspect = DataAspect())
    hidedecorations!(ax)
    hidespines!(ax)
    draw_polyomino!(ax, p)
    return f
end

function visualize_polyominoes(ps::AbstractVector{Polyomino}; ncols::Integer = 2)
    ncols > 0 || throw(ArgumentError("ncols must be positive, got $ncols"))
    isempty(ps) && throw(ArgumentError("need at least one polyomino to draw"))
    ncols = min(ncols, length(ps))
    nrows = cld(length(ps), ncols)

    maxr = maximum(r for p in ps for (r, _) in coordinates(p))
    maxc = maximum(c for p in ps for (_, c) in coordinates(p))

    f = Figure(backgroundcolor = RGBf(0.98, 0.98, 0.98),
               size = (500 * ncols, 350 * nrows))

    for (k, p) in enumerate(ps)
        i, j = fldmod1(k, ncols)
        gl = f[i, j] = GridLayout()
        ax = Axis(gl[1, 1], aspect = DataAspect(), title = string(k))
        hidespines!(ax)
        limits!(ax, 0, maxc, 0, maxr)
        draw_polyomino!(ax, p)
    end
    return f
end

end # module PolyominoesMakieExt
