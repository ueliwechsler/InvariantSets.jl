using InvariantSets
using Test

@testset "InvariantSets.jl" begin
    @testset "minimal_invariant_set" begin
        include(raw"minimal_invariant_set/rakovic_algorithm.jl")
        include(raw"minimal_invariant_set/schulze_algorithm.jl")
    end
    @testset "maximal_invariant_set" begin
        include(raw"maximal_invariant_set/maximal_RPI_set.jl")
        include(raw"maximal_invariant_set/maximal_CPI_set.jl")
    end
    @testset "concrete_operations" begin
        include(raw"concrete_operator.jl")
    end
    @testset "Helper Functionalities" begin
        include(raw"helper/control_systems.jl")
        include(raw"helper/jump.jl")
    end
end
