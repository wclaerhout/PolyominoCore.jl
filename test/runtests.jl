using PolyominoTools
using Test
using Aqua
using JET

@testset "Basic type functions testing" include("type_test.jl")
@testset "Polyomino parsing" include("poly_parse_test.jl")
@testset "Splitting" include("splits_test.jl")
@testset "Symmetry" include("symmetry_test.jl")
@testset "Enumeration" include("enumeration_test.jl")
@testset "Attaching" include("attach_test.jl")
@testset "Properties" include("properties_test.jl")

@testset "Plotting without Makie" begin
    # the extension must not be loaded before Makie is
    @test Base.get_extension(PolyominoTools, :PolyominoToolsMakieExt) === nothing
    @test_throws MethodError visualize_polyomino(poly"#")
end

@testset "Plotting (Makie extension)" include("visualisation_test.jl")

@testset "Aqua" Aqua.test_all(PolyominoTools)

# JET's results depend on the compiler, so each JET release supports only certain Julia
# versions. Run it on current Julia only; older versions just install an older JET.
if VERSION >= v"1.12"
    @testset "JET" JET.test_package(PolyominoTools; target_modules = (PolyominoTools,))
end
