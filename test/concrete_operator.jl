using Test

using InvariantSets
using LinearAlgebra: I
using Polyhedra
using CDDLib

@testset "Scaling with `*ᶜ` operator" begin
    P = Hyperrectangle(low=[-.6, -2.0],
                       high=[1.0, 2.0])
    P1 = 2.0*I *ᶜ P
    P2 = 2.0 *ᶜ P
    @test P1 ⊆ P2 && P2 ⊆ P1
    @test any(2*canonical_length(P) .== canonical_length(P2))
    P3 = convert(HPolytope, P)
    P4 = 2.0 *ᶜ P3
    @test any(2*canonical_length(P3) .== canonical_length(P4))
end

@testset "Concrete Addition operator +ᶜ" begin
    P = Hyperrectangle(low=[-.6, -2.0],
                       high=[1.0, 2.0])
    P1 = convert(HPolytope, P)
    vec =  [1.0,-10]
    P3 = P1 +ᶜ vec
    P4 = vec +ᶜ P1
    @test any(canonical_length(P3) .≈ vec .+ canonical_length(P1))
    @test any(canonical_length(P3) .== canonical_length(P4))
    P5 = P1 +ᶜ P1
    @test P5 ⊆ 2 *ᶜ P1 && 2 *ᶜ P1 ⊆ P5
end

@testset "Concrete Subtraction operator -ᶜ" begin
    P = Hyperrectangle(low=[-.6, -2.0],
                       high=[1.0, 2.0])
    P1 = convert(HPolytope, P)
    vec =  [1.0, -0.5]
    P3 = P1 -ᶜ vec
    @test any(canonical_length(P3) .≈ canonical_length(P1) .- vec )
    P4 = vec -ᶜ P1
    @test any(canonical_length(P4) .≈ vec .+ canonical_length(reflect(P1)))
    P5 = P1 -ᶜ P1
    @test P5 ⊆ BallInf(zeros(2), 0.0) &&  BallInf(zeros(2), 0.0) ⊆ P5
end
