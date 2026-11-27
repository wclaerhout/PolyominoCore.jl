using PolyominoTools
using CairoMakie
CairoMakie.activate!(type = "png")   #hide

poly4 = polyominoes(4; symmetry = :full)
length(poly4)

visualize_polyominoes(poly4; ncols = 2)

using PolyominoTools: is_equivalent

function has_fair_split(p::Polyomino; symmetry = :full)
    splits = all_splits(p)
    for (a, b) in splits
        if is_equivalent(a, b; symmetry = symmetry)
            return true
        end
    end
    return false
end

count(has_fair_split, poly4) / length(poly4)

function fair_fraction(n; symmetry = :full)
    shapes = polyominoes(n; symmetry)
    count(p -> has_fair_split(p; symmetry), shapes) / length(shapes)
end

sizes = 2:2:12
fractions = [fair_fraction(n) for n in sizes]

scatterlines(sizes, fractions;
    axis = (xlabel = "cells", ylabel = "fraction with a fair split", xticks = sizes))

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl
