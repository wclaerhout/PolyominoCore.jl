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

f = visualize_polyominoes([p, poly"##"])
axs = axes_of(f)
@test length(axs) == 2
@test all(!a.yreversed[] for a in axs)
@test drawn_rects(axs[1]) == expected_rects

# `ncols` sets the grid shape; titles are the indices.
f = visualize_polyominoes([p, poly"##", poly"#"]; ncols = 3)
axs = axes_of(f)
@test length(axs) == 3
@test [a.title[] for a in axs] == ["1", "2", "3"]
@test size(f.layout) == (1, 3)
@test size(visualize_polyominoes([p, p, p]).layout) == (2, 2)
@test_throws ArgumentError visualize_polyominoes(Polyomino[])
@test_throws ArgumentError visualize_polyominoes([p]; ncols = 0)

# `annotation`: :none draws only the shape, :grid adds the cell lattice of the bounding
# box, :full also labels the axes with row and column numbers at the cell centres.
lattices(ax) = [plt for plt in ax.scene.plots if plt isa Makie.LineSegments]

ax = only(axes_of(visualize_polyomino(p)))
@test isempty(lattices(ax))
@test !ax.xticklabelsvisible[]

ax = only(axes_of(visualize_polyomino(p; annotation = :grid)))
@test length(only(lattices(ax))[1][]) == 2 * (3 + 3)   # 3 vertical + 3 horizontal lines
@test !ax.xticklabelsvisible[]
@test drawn_rects(ax) == expected_rects

ax = only(axes_of(visualize_polyomino(p; annotation = :full)))
@test length(lattices(ax)) == 1
@test ax.xticklabelsvisible[] && ax.yticklabelsvisible[]
@test ax.xticks[] == (0.5:1:2, ["1", "2"])
@test ax.yticks[] == (0.5:1:2, ["1", "2"])

axs = axes_of(visualize_polyominoes([p, poly"###"]; annotation = :grid))
@test all(a -> length(only(lattices(a))[1][]) == 2 * (4 + 3), axs)   # shared 2 × 3 box
@test [a.title[] for a in axs] == ["1", "2"]

@test_throws ArgumentError visualize_polyomino(p; annotation = :axes)
@test_throws ArgumentError visualize_polyominoes([p]; annotation = :axes)
