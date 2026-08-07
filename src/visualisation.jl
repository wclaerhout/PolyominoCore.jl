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

"""
Input: pathway which is a chronological Set of Polyominoes
Output: All polyominoes plotted in a row
"""

function draw_inline_polyomino!(ax, p::Polyomino)
    for (r, c) in coordinates(p)
        poly!(ax, Rect(c - 1, r - 1, 1, 1), color = :slategray1,
              strokewidth = 2, strokecolor = :black)
    end
    return ax
end

function visualize_pathway(pathway::AbstractVector{Polyomino})
    cols = 2
    rows = cld(length(pathway), cols)

    maxr = maximum(r for p in pathway for (r, c) in coordinates(p))
    maxc = maximum(c for p in pathway for (r, c) in coordinates(p))

    f = Figure(backgroundcolor = RGBf(0.98, 0.98, 0.98),
               size = (1000, 350 * rows))

    for (k, p) in enumerate(pathway)
        i, j = fldmod1(k, cols)
        gl = f[i, j] = GridLayout()
        ax = Axis(gl[1, 1], aspect = DataAspect(),
                  title = "step $k", yreversed = true)
        #hidedecorations!(ax)
        hidespines!(ax)
        limits!(ax, 0, maxc, 0, maxr)
        draw_inline_polyomino!(ax, p)
    end
    return f
end

#-----------------------------
# pool0 = Vector{Polyomino}();

# p2 = poly"
#         ##
#         "
# p3 = poly"
#         #
#         #
#         "
# push!(pool0, MONOMINO);
# push!(pool0, p2)
# push!(pool0, p3)
# for i in 1:3
#     push!(pool0, p3)
# end
# length(pool0)

# visualize_pathway(pool0)