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
    pos1_width = missing
    pos1_height = missing
    pos2_width = missing
    pos2_height = missing
end