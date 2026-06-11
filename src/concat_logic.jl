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
    sides = ["bottom", "up", "left", "right"]
    pos1_width = poly_width(p1)
    pos1_height = poly_height(p2)
    pos2_width = poly_width(p1)
    pos2_height = poly_height(p2)

    matrix_tab = Dict("bottom" => 1, "up" => 2, "left" => 3, "right" => 4)

    validation_matrix = [trues(pos1_width, pos2_width), trues(pos1_width, pos2_width),
                        trues(pos1_height, pos2_height), trues(pos1_height, pos2_height)]

    for side in sides
        tab = matrix_tab[side]
        if side == "bottom" || side == "up"
            positions1 = pos1_width
            positions2 = pos2_width
        else
            positions1 = pos1_height
            positions2 = pos2_width
        end
        for pos1 in positions1
            for pos2 in positions2
                validation_matrix[tab, pos1, pos2] = concatenation_possible(p1, p2; side = Symbol(side), pos1 = pos1, pos2 = pos2)
            end
        end
    end
        

    return validation_matrix
end
