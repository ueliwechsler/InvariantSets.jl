using Test

using InvariantSets
using LazySets
using JuMP

@testset "add_constraint! as Vector to x[1:n]" begin
    n = 3
    x0 = 1:n
    mod = Model()
    @variable(mod, x[1:n])
    InvariantSets.add_constraint!(mod, x, x0)
    con1 = all_constraints(mod, AffExpr, MOI.EqualTo{Float64})
    m2 = Model()
    @variable(m2, x[1:n])
    @constraint(m2, x[:, 1] .== x0)
    con2 = all_constraints(m2, AffExpr, MOI.EqualTo{Float64})
    @test getfield.(con1, :index) == getfield.(con2, :index)
end

@testset "add_constraint! as Vector to x[1:n,1:m]" begin
    n = 3
    m = 2
    x0 = 1:n
    mod = Model()
    @variable(mod, x[1:n, 1:m])
    InvariantSets.add_constraint!(mod, x, x0)
    con1 = all_constraints(mod, AffExpr, MOI.EqualTo{Float64})
    m2 = Model()
    @variable(m2, x[1:n, 1:m])
    @constraint(m2, x[:, 1] .== x0)
    @constraint(m2, x[:, 2] .== x0)
    con2 = all_constraints(m2, AffExpr, MOI.EqualTo{Float64})
    @test getfield.(con1, :index) == getfield.(con2, :index)
end

@testset "add_constraint! as Polytope to  x[1:n]" begin
    F = [1 0 0; 0.0 1 0; 0 0 1]
    g = [1, 1, 1.0]
    A = HPolytope(F, g)
    m = Model()
    @variable(m, x[1:3])
    InvariantSets.add_constraint!(m, x, A)
    con1 = all_constraints(m, AffExpr, MOI.LessThan{Float64})
    m2 = Model()
    @variable(m2, x[1:3])
    @constraint(m2, F * x .<= g)
    con2 = all_constraints(m2, AffExpr, MOI.LessThan{Float64})
    @test getfield.(con1, :index) == getfield.(con2, :index)
end

@testset "add_constraint! as Vector to x[1:n,1:m]" begin
    n = 3
    m = 2
    F = [1 0 0; 0 1 0; 0 0 1.0]
    g = [1, 1, 1.0]
    A = HPolytope(F, g)
    mod = Model()
    @variable(mod, x[1:n, 1:m])
    InvariantSets.add_constraint!(mod, x, A)
    con1 = all_constraints(mod, AffExpr, MOI.LessThan{Float64})
    m2 = Model()
    @variable(m2, x[1:n, 1:m])
    @constraint(m2, F * x[:, 1] .<= g)
    @constraint(m2, F * x[:, 2] .<= g)
    con2 = all_constraints(m2, AffExpr, MOI.LessThan{Float64})
    @test getfield.(con1, :index) == getfield.(con2, :index)
end


@testset "add_constraint! as LazySet with constraints_list available" begin
    A = BallInf(zeros(3), 2.0)
    m = Model()
    @variable(m, x[1:3])
    InvariantSets.add_constraint!(m, x, A)
    con1 = all_constraints(m, AffExpr, MOI.LessThan{Float64})
    m2 = Model()
    @variable(m2, x[1:3])
    F, g = tosimplehrep(A)
    @constraint(m2, F * x .<= g)
    con2 = all_constraints(m2, AffExpr, MOI.LessThan{Float64})
    @test getfield.(con1, :index) == getfield.(con2, :index)
end

@testset "add_constraint! as LazySet with constraints_list not available" begin
    A = Ball2(zeros(3), 2.0)
    m = Model()
    @variable(m, x[1:3])
    @test_throws AssertionError InvariantSets.add_constraint!(m, x, A)
end
