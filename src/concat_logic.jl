"""
Write some logic functions for concatenations.
- concatenation_possible(p1, p2; side = , pos1, pos2) --> returns if a concatenation is check_valid_concat
- all_valid_concatenations(p1, p2) --> returns all the possible valid combinations for adding p2 to p1
- unique_concatenations(p1, p2) --> filters out duplicate concatenations (some concatenations give identical results --> redundant)
"""

function concatenation_possible(p1, p2; side = "bottom", pos1 = 1, pos2 = 1)
    try 
        concatenate(p1, p2; side = Symbol(side), pos1 = pos1, pos2 = pos2)
        return true
    catch
        return false
    end
end

"""
	all_splits(p) -> Vector{Tuple{Polyomino,Polyomino}}

Reverse reaction (splitting `C -> A + B`): enumerate every way to partition `p`
into two non-empty connected polyominoes `(A, B)` with `A ∪ B == p`, `A ∩ B == ∅`.
Each unordered split is returned once.

Adjacency of `A` and `B` is automatic: `p` is connected, so two connected pieces
that partition it must touch. Splitting is unrestricted (the general inverse of
assembly); assembly is the restricted direction (no insertion into an enclosed
cavity — see `docs/research_framing.md`).
"""
function all_splits(p::Polyomino)
	cells = collect(coordinates(p))
	n = length(cells)
	n < 2 && return Tuple{Polyomino,Polyomino}[]

	anchor = cells[1]              # pin into A so each unordered split is counted once
	rest   = cells[2:end]
	out    = Tuple{Polyomino,Polyomino}[]

	for mask in 0:(2^(n-1) - 1)
		A = Set{Tuple{Int,Int}}((anchor,))
		for i in 1:(n-1)
			(mask >> (i-1)) & 1 == 1 && push!(A, rest[i])
		end
		length(A) == n && continue          # B would be empty
		B = setdiff(coordinates(p), A)
		(is_connected(A) && is_connected(B)) || continue
		push!(out, (Polyomino(A), Polyomino(B)))
	end
	out
end

"""
	unique_splits(p) -> Vector{Tuple{Polyomino,Polyomino,Int}}

Collapse `all_splits(p)` to **unique unordered product shape-pairs**, each tagged with its
**multiplicity** — the number of distinct cuts of `p` that yield that same pair of shapes
(compared up to translation only, §2 of the research framing).

The shape-pair is the reaction edge `C -> A + B` for the reachability hypergraph (scope A);
the multiplicity is the **reaction degeneracy** (count of equivalent breakable bonds), a
rate prefactor for the dynamical CRN (scope B). `sum(m for (_,_,m) in unique_splits(p))`
equals `length(all_splits(p))`.

With `symmetry = :rotation` (or `:full`) product shapes are additionally compared up to
rotation (and reflection), so pairs that are rotated copies of each other merge and their
multiplicities add. The returned representatives are the shapes as actually cut from `p`.
The default `:translation` gives the original behaviour.
"""
function unique_splits(p::Polyomino; symmetry::Symbol = :translation)
	check_symmetry(symmetry)
	KeyT   = Set{Vector{Tuple{Int,Int}}}   # `coordinates` returns a sorted (canonical) Vector
	counts = Dict{KeyT,Int}()
	reps   = Dict{KeyT,Tuple{Polyomino,Polyomino}}()
	for (a, b) in all_splits(p)
		# unordered, translation-normalized (and rotation-normalized if requested)
		key = Set([coordinates(canonical(a; symmetry)), coordinates(canonical(b; symmetry))])
		if haskey(counts, key)
			counts[key] += 1
		else
			counts[key] = 1
			reps[key]   = (a, b)
		end
	end
	[(reps[k][1], reps[k][2], counts[k]) for k in keys(counts)]
end

"""
	all_valid_concatenations(p1, p2; symmetry = :translation)

output: vector of size 4 (bottom, top, left, right)
        - every side (bottom, top,...) contains a matrix of size(poly1, poly2) with 0/false or 1/true
        - so if bottom[1,2] = 1 this means that you can attach the second block of polyomino 2 to the first block of polyomino 1 --> valid concatenation
        - rows = pos1, cols = pos2

With `symmetry = :rotation` (or `:full`) `p2` may also be rotated (and reflected) before
attaching. The output is then a `Vector` of `orientation => matrices` pairs, one per
distinct orientation of `p2` (see `Polyominoes.orientations`), where `matrices` is the
4-vector above for that orientation. Pass the orientation as `p2` to `concatenate`.
"""
function all_valid_concatenations(p1, p2; symmetry::Symbol = :translation)
    check_symmetry(symmetry)
    symmetry == :translation ||
        return [q => all_valid_concatenations(p1, q) for q in orientations(p2; symmetry)]

    sides = ["bottom", "top", "left", "right"]
    pos1_width  = poly_width(p1)
    pos1_height = poly_height(p1)
    pos2_width  = poly_width(p2)
    pos2_height = poly_height(p2)

    matrix_tab = Dict("bottom" => 1, "top" => 2, "left" => 3, "right" => 4)

    validation_matrix = [trues(pos1_width, pos2_width), trues(pos1_width, pos2_width),
                         trues(pos1_height, pos2_height), trues(pos1_height, pos2_height)]

    for side in sides
        tab = matrix_tab[side]
        if side == "bottom" || side == "top"
            positions1 = pos1_width
            positions2 = pos2_width
        else
            positions1 = pos1_height
            positions2 = pos2_height
        end
        for pos1 in 1:positions1
            for pos2 in 1:positions2
                validation_matrix[tab][pos1, pos2] = concatenation_possible(p1, p2; side = Symbol(side), pos1 = pos1, pos2 = pos2)
            end
        end
    end

    return validation_matrix
end
