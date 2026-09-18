using Polyomino
using Test

@testset "Basic type functions testing" include("type_test.jl")
@testset "Polyomino parsing" include("poly_parse_test.jl")
@testset "Concatenation testing" include("concatenation_test.jl")
@testset "Concatenation logic" include("concat_logic_test.jl")
