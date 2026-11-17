using Makie

# An L-tromino whose drawing is not symmetric top-to-bottom:
#   #.     row 2
#   ##     row 1
p = poly"""
#.
##
"""
expected_rects = Set(Rect2f(c - 1, r - 1, 1, 1) for (r, c) in coordinates(p))

axes_of(f) = [b for b in f.content if b isa Makie.Axis]
drawn_rects(ax) = Set(Rect2f(plt[1][]) for plt in ax.scene.plots if plt isa Makie.Poly)

# Cell (r, c) must be drawn as the square [c-1, c] × [r-1, r] on an axis with y growing
# upward, so the picture matches the `poly"..."` drawing.
f = visualize_polyomino(p)
@test f isa Makie.Figure
ax = only(axes_of(f))
@test !ax.yreversed[]
@test drawn_rects(ax) == expected_rects

f = visualize_pathway([p, poly"##"])
axs = axes_of(f)
@test length(axs) == 2
@test all(!a.yreversed[] for a in axs)
@test drawn_rects(axs[1]) == expected_rects
