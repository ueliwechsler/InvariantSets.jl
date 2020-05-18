using LinearAlgebra

"""
    is_schur(A::AbstractMatrix)

Check if a square matrix is Schur, i.e. the eigenvalues lie within the unit circle.

### Input
- `A` -- square matrix

### Ouput
Boolean value indicating if the matrix `A` is Schur.
"""
is_schur(A::AbstractMatrix) = maximum(abs.(eigvals(A))) < 1.0
