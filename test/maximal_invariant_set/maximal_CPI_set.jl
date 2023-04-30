using Test
using InvariantSets
using LinearAlgebra: I
using Polyhedra # needed for prerset_vrep, preset_hrep
using CDDLib # needed for preset_hrep


@testset "Preset computation" begin
    n = 2
    m = 1
    A = rand(n, n)
    B = rand(n, m)
    X = BallInf(zeros(n), 10.0)
    U = BallInf(zeros(m), 0.1)
    K = [0.0890246 0.484408]
    F, g = tosimplehrep(X)

    P = preset(A, X)
    @test P ⊆ HPolytope(F * A, g) && HPolytope(F * A, g) ⊆ P
    # @test isequivalent(preset(A, X), HPolytope(F*A,g))

    D = state_constraints(X, U, K)
    # D2 = InvariantSets.state_constraints_ops(X, U, K)
    # @test D ⊆ D2 && D2 ⊆ D

    P_2 = InvariantSets._preset_vrep(A, B, U, D)
    P_3 = InvariantSets._preset_hrep(A, B, U, D)
    @test P_2 ⊆ P_3 && P_3 ⊆ P_2
end

@testset "Maximum invariant set" begin
    A2 = [1.0 1.0; 0.0 1.0]
    B2 = [1.0; 0.5]
    Q2 = I
    R2 = 90 * I
    # K2 = dlqr(A2,B2,Q2,R2)
    K2 = [0.0890246 0.484408]
    X2 = BallInf(zeros(2), 2.0)
    U2 = BallInf(zeros(1), 2.0)
    S2 = A2 - B2 * K2

    max_PI_1 = maximum_invariant_set(S2, X2)
    max_PI_2 = maximum_invariant_set(S2, X2, 5)
    max_PI_3 = maximum_invariant_set(S2, X2, 4)

    @test max_PI_1 ⊆ max_PI_2 && max_PI_2 ⊆ max_PI_1
    @test !(max_PI_1 ⊆ max_PI_3 && max_PI_3 ⊆ max_PI_1)

    max_PI_4 = maximum_invariant_set(A2, B2, X2, U2, K2)
    @test max_PI_1 ⊆ max_PI_4 && max_PI_4 ⊆ max_PI_1
end

@testset "Maximum control invariant set" begin
    A2 = [1.0 1.0; 0.0 1.0]
    B2 = [1.0; 0.5]
    X2 = BallInf(zeros(2), 5.0)
    U2 = BallInf(zeros(1), 1.0)
    max_CPI_1 = maximum_control_invariant_set(A2, B2, X2, U2; preset=InvariantSets._preset_vrep)
    max_CPI_2 = maximum_control_invariant_set(A2, B2, X2, U2; preset=InvariantSets._preset_hrep)
    max_CPI_3 = maximum_control_invariant_set(A2, B2, X2, U2, 5)
    @test max_CPI_1 ⊆ max_CPI_2 && max_CPI_2 ⊆ max_CPI_1
    @test !(max_CPI_1 ⊆ max_CPI_3 && max_CPI_3 ⊆ max_CPI_1)
end
