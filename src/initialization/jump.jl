using .JuMP: @constraint, Model
import .JuMP


"""
    add_constraint!(model::JuMP.Model, X, Set)

Add constraint `xᵢ ∈ Set` where `xᵢ` is a column of `X` (or if `X` is a vector `xᵢ=X`).

### Input
- `model` -- `JuMP.Model` type
- `X` -- variable vector `X[1:n]` or variable matrix `X`[1:n, 1:N]` where `n` is the number of states and
`N` is the number of time steps
- `Set` -- lazy set or vector type

### Output
Nothing.

### Note
Only works if `X` is a `Array{VariableRef,1}` or `VariableRef` variable types,
`DenseAxisArrays` are not yet supported yet.

The following types for the constraint `Set` are supported:
- polyhedral sets →  Inequality constraint `Fxᵢ ≤ g` where `F, g = constraints_list(P)`.
- Vector          → Equality constraint `xᵢ==Set`
- Singleton       → Equality constraint `xᵢ==element(Set)`
- Universe        → No constraint
"""
function add_constraint!(model::JuMP.Model, X, Set) end

function add_constraint!(model::JuMP.Model, X, A::AbstractVector{<:Real})
    _throw_dim_mismatch(X, A)

    for j=1:size(X,2)
        JuMP.@constraint(model, X[:, j] .== A)
    end
    nothing
end

function add_constraint!(model::JuMP.Model, X, S::Singleton)
    _throw_dim_mismatch(X, S)

    for j=1:size(X,2)
        JuMP.@constraint(model, X .== element(S))
    end
    nothing
end

function add_constraint!(model::JuMP.Model, X, U::Universe)
    _throw_dim_mismatch(X, U)
    # do nothing
    nothing
end

function add_constraint!(model::JuMP.Model, X, P::LazySet)
    @assert applicable(constraints_list, P) "the number of constraint of P needs "*
                 "to be finite; try overapproximating P with an `HPolytope` first"
    _throw_dim_mismatch(X, P)

    F, g = tosimplehrep(P)
    isempty(P) && return nothing
    for j=1:size(X,2)
        JuMP.@constraint(model, F*X[:, j] .<= g)
    end
    nothing
end

_throw_dim_mismatch(X, P::LazySet) =  InvariantSets.dim(P) != size(X, 1) &&
    throw(ArgumentError("the dimension of the constraint Set $(InvariantSets.dim(P)) "*
                        "doesn't match with the rows of the variable array with size $(size(X))"))
_throw_dim_mismatch(X, A::AbstractArray) =  length(A) != size(X, 1) &&
    throw(ArgumentError("the dimension of the constraint Set $(length(A)) "*
                        "doesn't match with the rows of the variable array with size $(size(X))"))
