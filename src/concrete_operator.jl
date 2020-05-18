import LinearAlgebra: UniformScaling

# ==========================
# Concrete Addition Operator
# ==========================
+ᶜ(X::LazySet, Y::LazySet) = minkowski_sum(X,Y)
+ᶜ(v::AbstractVector, X::LazySet) = translate(X,v)
+ᶜ(X::LazySet, v::AbstractVector) = translate(X,v)
⊕ᶜ = +ᶜ
+ᶜ(Z1::AbstractZonotope{N}, Z2::AbstractZonotope{N}) where {N<:Real} =
    minkowski_sum(Z1, Z2) #; remove_zero_generators=false)

# =============================
# Concrete Subtraction Operator
# =============================
-ᶜ(X::LazySet, Y::LazySet) = minkowski_difference(X,Y)
-ᶜ(v::AbstractVector, X::LazySet) = translate(reflect(X),v)
-ᶜ(X::LazySet, v::AbstractVector) = translate(X,-v)
⊖ᶜ = -ᶜ

# ================================
# Concrete Multiplication Operator
# ================================
*ᶜ(α::Real, P::LazySet) = LazySets.scale(α, P)
*ᶜ(P::LazySet, α::Real) = LazySets.scale(α, P)
*ᶜ(U::UniformScaling, P::LazySet) = linear_map(U, P)

"""
    *ᶜ(M::AbstractMatrix{N}, P::AbstractPolyhedron{N}) where {N<:Real}

Concrete linear map of a matrix `M` and polyhedral set `P`.

### Input
- `M` -- matrix
- `P` -- polyhedral set

### Output
Linear map of `P` with `M`.

### Note
If performance is of outmost importance. The computation can be sped up by using the method [`linear_map`](@ref) directly and adjusting the optinal parameter.
"""
*ᶜ(M::AbstractMatrix{N}, P::AbstractPolyhedron{N}) where {N<:Real} =
    linear_map(M, P)
*ᶜ(M::AbstractMatrix{N}, S::AbstractSingleton{N}) where {N<:Real} =
    linear_map(M, S)
*ᶜ(M::AbstractMatrix{N}, Z::AbstractZonotope{N}) where {N<:Real} =
    linear_map(M, Z)
*ᶜ(M::Array{T,2} where T, pz::PolynomialZonotope)  =
    linear_map(M, pz)

*ᶜ(α::Real, Z::Zonotope) = LazySets.scale(α, Z)
*ᶜ(Z::Zonotope, α::Real) = LazySets.scale(α, Z)
*ᶜ(α::Number, Z::PolynomialZonotope) = LazySets.scale(α, pz)
*ᶜ(Z::PolynomialZonotope, α::Number) = LazySets.scale(α, pz)

# ==============================
# Concrete intersection Operator
# ==============================
∩ᶜ(X::LazySet, Y::LazySet) = intersection(X,Y)
