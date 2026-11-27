module PolyominoToolsMakieExt

using Makie
using PolyominoTools: Polyomino, coordinates
import PolyominoTools: visualize_polyomino, visualize_polyominoes

function check_annotation(annotation::Symbol)
    annotation in (:none, :grid, :full) || throw(ArgumentError(
        "annotation must be :none, :grid or :full, got $(repr(annotation))"))
    return annotation
end

# Show an nrows × ncols box of cells on `ax`. With `:grid` or `:full`, the cell lattice
# of the box is drawn; with `:full`, the axes are also labelled with the row and column
# numbers of `coordinates`, centred on the cells.
function setup_axis!(ax, nrows, ncols, annotation)
    pad = 0.25
    limits!(ax, -pad, ncols + pad, -pad, nrows + pad)
    hidespines!(ax)
    ax.xgridvisible = false
    ax.ygridvisible = false
    if annotation === :full
        ax.xticks = (0.5:1:ncols, string.(1:ncols))
        ax.yticks = (0.5:1:nrows, string.(1:nrows))
        ax.xticksvisible = false
        ax.yticksvisible = false
        ax.xlabel = "c"
        ax.ylabel = "r"
    else
        hidedecorations!(ax)
    end
    if annotation !== :none
        segments = vcat([(Point2f(x, 0), Point2f(x, nrows)) for x in 0:ncols],
                        [(Point2f(0, y), Point2f(ncols, y)) for y in 0:nrows])
        linesegments!(ax, segments; color = (:gray, 0.6), linewidth = 1)
    end
    return ax
end

# Cell (r, c) is drawn as the unit square [c-1, c] × [r-1, r], with y growing upward,
# so the plot matches the `poly"..."` drawing (top text line = top of the shape).
function draw_polyomino!(ax, p::Polyomino)
    for (r, c) in coordinates(p)
        poly!(ax, Rect(c - 1, r - 1, 1, 1), color = :slategray1,
              strokewidth = 2, strokecolor = :black)
    end
    return ax
end

function visualize_polyomino(p::Polyomino; annotation::Symbol = :none)
    check_annotation(annotation)
    nrows, ncols = size(p)

    f = Figure()
    ax = Axis(f[1, 1], aspect = DataAspect())
    setup_axis!(ax, nrows, ncols, annotation)
    draw_polyomino!(ax, p)
    return f
end

function visualize_polyominoes(ps::AbstractVector{Polyomino}; ncols::Integer = 2,
                               annotation::Symbol = :none)
    ncols > 0 || throw(ArgumentError("ncols must be positive, got $ncols"))
    isempty(ps) && throw(ArgumentError("need at least one polyomino to draw"))
    check_annotation(annotation)
    ncols = min(ncols, length(ps))
    nrows = cld(length(ps), ncols)

    # every panel shows the same box, so sizes are comparable
    maxr = maximum(size(p, 1) for p in ps)
    maxc = maximum(size(p, 2) for p in ps)

    f = Figure(backgroundcolor = RGBf(0.98, 0.98, 0.98),
               size = (500 * ncols, 350 * nrows))

    for (k, p) in enumerate(ps)
        i, j = fldmod1(k, ncols)
        gl = f[i, j] = GridLayout()
        ax = Axis(gl[1, 1], aspect = DataAspect(), title = string(k))
        setup_axis!(ax, maxr, maxc, annotation)
        draw_polyomino!(ax, p)
    end
    return f
end

end # module PolyominoToolsMakieExt
