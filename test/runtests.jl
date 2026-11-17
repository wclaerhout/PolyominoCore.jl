using Polyominoes
using Test
using Aqua

@testset "Basic type functions testing" include("type_test.jl")
@testset "Polyomino parsing" include("poly_parse_test.jl")
@testset "Concatenation testing" include("concatenation_test.jl")
@testset "Concatenation logic" include("concat_logic_test.jl")
@testset "Symmetry" include("symmetry_test.jl")
@testset "Enumeration" include("enumeration_test.jl")
@testset "Attaching" include("attach_test.jl")
@testset "Properties" include("properties_test.jl")

@testset "Plotting without Makie" begin
    # the extension must not be loaded before Makie is
    @test Base.get_extension(Polyominoes, :PolyominoesMakieExt) === nothing
    @test_throws MethodError visualize_polyomino(poly"#")
end

@testset "Plotting (Makie extension)" include("visualisation_test.jl")

@testset "Aqua" Aqua.test_all(Polyominoes)
