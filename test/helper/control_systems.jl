@testset "is_schur" begin
    A = [0.5][:,:]
    @test InvariantSets.is_schur(A)
end
