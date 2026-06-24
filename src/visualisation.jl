using CairoMakie

function visualize_polyomino(p::Polyomino)
    nrows = maximum(r for (r, _) in coordinates(p))
    ncols = maximum(c for (_, c) in coordinates(p))
    
    f = Figure()
    ax = Axis(f[1, 1], limits = (0, ncols+1, 0, nrows+1),
              xgridvisible = false, ygridvisible = false,
              aspect = DataAspect())
    hidedecorations!(ax)
    hidespines!(ax)
    
    for (r, c) in coordinates(p)
        poly!(ax, Rect(c-1, r-1, 1, 1), color = :slategray1,
              strokewidth = 2, strokecolor = :black)
    end
    return f
end