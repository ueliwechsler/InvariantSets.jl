using LinearAlgebra: norm, I, UniformScaling
using LazySets
using LazySets.Arrays

"""
    scale(a::T, P::LazySet) where {T<:Real}

 Scale the set `P` by the scalar `a`. The scaling corresponds to applying a `linear_map` to `a` multiplied with an appropriately sized unit matrix and the set `P`.

 ### Input
 - `a` -- scalar
 - `P` -- lazy set

 ### Output
 A lazy set which correspoinds to the set `P` scaled by `a`.

 ### Note
 Enables to apply concrete multiplication operator `*ᶜ` to a scalar and a set (in addition to matrix and set).
"""
LazySets.scale(α::T, P::LazySet) where {T<:Real} =
    linear_map(α * Matrix{T}(I, dim(P), dim(P)), P)

"""
    linear_map(U::UniformScaling, P::LazySet)

 Concrete linear map of the set `P` and the uniform scaling `U`.

 ### Input
 - `U` -- uniform scaling
 - `P` -- lazy set

 ### Output
 A lazy set which corresponds to the linear map of `P` with `U`.
"""
LazySets.linear_map(U::UniformScaling, P::LazySet) =
    scale(U.λ, P)


"""
    ρ_exact(d::AbstractVector, P::LazySet)

 Compute support value for the lazy set `P` in the direction `d`. Avoid numerical errors for directions `d` with small norm by normalizing `d`. See  [`ρ`](@ref) for more detail.

 ### Input
 - `d` -- vector
 - `P` -- lazy set

 ### Output
 Support value for lazy set `P` in the direction `d`.
"""
ρ_exact(d::AbstractVector, P::LazySet) = ρ(normalize(d), P) * norm(d)

"""
    σ_exact(d::AbstractVector, P::LazySet)

 Compute support vector for the lazy set `P` in the direction `d`. Avoid numerical errors for directions `d` with small norm by normalizing `d`. See  [`ρ`](@ref) for more detail.

 ### Input
 - `d` -- vector
 - `P` -- lazy set

 ### Output
 Support vector for lazy set `P` in the direction `d`.
"""
σ_exact(d::AbstractVector, P::LazySet) = σ(normalize(d), P)

"""
    ρ_matrix(M::AbstractArray, P::LazySet)

Compute support value for the lazy set `P` in the direction of eachrow of matrix `M`.

### Input
- `M` -- matrix with rows as normal direction of constraints
- `P` -- lazy set

### Output
Vector of support values for lazy set `P` in the direction of each row of `M`.
"""
function ρ_matrix(M::AbstractArray, P::LazySet)
    num_constr = size(M, 1)
    res = zeros(num_constr)
    for i = 1:num_constr
        res[i] = ρ_exact(view(M, i, :), P)
    end
    return res
end

"""
    canonical_length(X::LazySet)

Returns the support function of the given set along the positive and negative canonical directions.

### Inputs

- `X` - convex set

### Outputs

A matrix with `n = dims(X)` rows and two columns. Each row stands for
one dimension of `X` whereas the first column is the minimum and the second
column is the maximum value of the corresponding dimension.
"""
function canonical_length(X::LazySet{N}) where {N<:Real}
    dims = LazySets.dim(X)
    x = Matrix{N}(undef, dims, 2)
    for j = 1:dims
        ej = SingleEntryVector(j, dims, one(N))
        x[j, :] = [-ρ_exact(-ej, X), ρ_exact(ej, X)]
    end
    return x
end

"""
    marginal_enlargment(P::LazySet, ε=LazySets._TOL_F64.rtol)

 Increase the size of a lazy set `P` with available H-representation marginally. Hopefully by a Ball with a radius of `ε`.

 ### Input
 - `P` -- lazy set
 - `ε` -- (optional, default=LazySets.,_TOL_F64.rtol) marginal incrase

 ### Ouput
 Lazy set with marginally larger size than `P`.

 ### Note
 This function is useful, if we want to compute the minimal RPI set according to e.g. [`minimal_RPI_set_lazy_rakovic`](@ref) for an error set where the origin lies on the boundary and not in the interior. After marginally enlarging the error set, the algorithms for computing the minimal RPI set can be applied since the origin is now contained in the interior.
"""
function marginal_enlargment(P::LazySet, ε=LazySets._TOL_F64.rtol)
    F, g = tosimplehrep(P)
    g .+= ε / norm(g)
    return HPolytope(F, g)
end
