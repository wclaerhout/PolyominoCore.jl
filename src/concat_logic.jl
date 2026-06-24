using PolyominoCRN

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

function all_valid_concatenations(p1, p2)
    """
    output: vector of size 4 (bottom, top, left, right)
            - every side (bottom, top,...) contains a matrix of size(poly1, poly2) with 0/false or 1/true
            - so if bottom[1,2] = 1 this means that you can attach the second block of polyomino 2 to the first block of polyomino 1 --> valid concatenation
            - rows = pos1, cols = pos2
    """
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
