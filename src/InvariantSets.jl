__precompile__(true)

module InvariantSets

using Requires

using LazySets
import Distributions
import LazySets.Interval

# ==== SET TYPES ====
# Exported set types from LazySets.jl
export LazySet
# Balls
export Ball1, Ball2, BallInf, Ballp
# Polytopic Sets
export HPolygon, HPolytope, HPolyhedron, VPolygon, VPolytope
# others
export  Singleton,
        Interval,
        LineSegment,
        SingleEntryVector,
        Hyperplane,
        HalfSpace,
        Hyperrectangle,
        Ellipsoid,
        Zonotope,
        Universe

# ==== SET OPERATIONS ====
#  Exported lazy set operators from LazySets.jl
export +, ⊕, *, ∩
# Exported functionalities from LazySets.jl
export  dim,
        isbounded,
        tosimplehrep,
        constraint_list,
        ρ, support_function,
        σ, support_vector,
        is_interior_point,
        ∈, ≈, ⊆, ==,
        isequivalent,
        rand, an_element,
        chebyshev_center, intersection,
        sample # needs Distributions to be loaded
        # TODO: distance_point_to_set
# Convenience operator for set equality check (⫓), because == checks for type and field equality
⫓(X::LazySet, Y::LazySet) = X ⊆ Y && Y ⊆ X
# TODO: Check if ⫓(X::LazySet, Y::LazySet) = isequivalent(X,Y) works for all set types
export ⫓

# TODO: add docstring to +ᶜ and -ᶜ
export +ᶜ, ⊕ᶜ, -ᶜ, ⊖ᶜ, *ᶜ, ∩ᶜ, reflect, translate
include(raw"concrete_operator.jl")

export  ρ_exact, σ_exact, ρ_matrix,
        canonical_length, marginal_enlargment
include(raw"helper/lazy_sets.jl")
include(raw"helper/control_systems.jl")

abstract type AbstractAlgorithm end
export preset,
       state_constraints,
       maximum_invariant_set,
       maximum_control_invariant_set,
       maximal_RPI_set
# TODO: add maximal_RPI_set
include(raw"maximal_invariance/main.jl")
export minimal_RPI_set,
       implicit_rakovic
# TODO: add implicit_rakovic once paper is published
# TODO: add tests for F_lazy (with the straightforward definition)
# TODO: Document  Schulze Algorithm
# TODO: add minimal_RPI_set
include(raw"minimal_invariance/main.jl")

# Derived sets used in MPC and control systems
export terminal_set,
       feasible_set,
       tightened_state_constraint,
       tightened_input_constraint,
       tightened_constraints
# TODO: documentation
# TODO: add `tightened_constraints`once paper is published
include(raw"applied_sets/control_systems.jl")
export refine
include(raw"approximation.jl")

# ===================================================
# Load external packages on-demand (using 'Requires')
# ===================================================

#TODO: fix add_constraint! for x and X (array and vecotr) add write docu new!
include(raw"init.jl")

end # module
