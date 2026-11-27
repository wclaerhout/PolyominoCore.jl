using PolyominoTools: canonical, orientations

# OEIS A001168 (fixed), A000988 (one-sided), A000105 (free), n = 1…10
const OEIS = Dict(
    :translation => [1, 2, 6, 19, 63, 216, 760, 2725, 9910, 36446],
    :rotation    => [1, 1, 2, 7, 18, 60, 196, 704, 2500, 9189],
    :full        => [1, 1, 2, 5, 12, 35, 108, 369, 1285, 4655],
)

@testset "OEIS counts, symmetry = :$sym" for sym in keys(OEIS)
    @test [length(polyominoes(n; symmetry = sym)) for n in 1:10] == OEIS[sym]
end

@testset "structure of the output" begin
    for n in 1:6, sym in (:translation, :rotation, :full)
        ps = polyominoes(n; symmetry = sym)
        @test all(length(p) == n for p in ps)
        @test all(canonical(p; symmetry = sym) == p for p in ps)        # canonical representatives
        @test allunique(ps)
        @test issorted(ps; by = coordinates)                            # deterministic order
    end
    @test polyominoes(1) == [poly"#"]
    @test Set(polyominoes(2)) == Set([poly"##", poly"""
        #
        #
        """])
end

# Orbit counting: the classes of a coarser symmetry partition the finer ones, so summing
# each class's number of distinct orientations gives back the finer count.
@testset "orbit sums" begin
    for n in 1:8
        fixed = length(polyominoes(n))
        @test sum(length(orientations(p; symmetry = :rotation))
                  for p in polyominoes(n; symmetry = :rotation)) == fixed
        @test sum(length(orientations(p; symmetry = :full))
                  for p in polyominoes(n; symmetry = :full)) == fixed
    end
end

@testset "argument checks" begin
    @test_throws ArgumentError polyominoes(0)
    @test_throws ArgumentError polyominoes(-3)
    @test_throws ArgumentError polyominoes(3; symmetry = :bogus)       # check_symmetry
end
