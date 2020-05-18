import LazySets.Approximations.overapproximate

"""
    overapproximate(X::LazySet{N}, dirs::Vector{Vector{N}}) where {N}

 Compute the overapproximation of the lazy set `X` by evaluating the support values in the direction of `dirs` and adding the resulting constraints.

 ### Inputs
 - `X` -- lazy set
 - `dir` -- vector of direction vectors

 ### Output
 Over-approximation of the lazy set `X` in the directions of `dir`
"""
function LazySets.Approximations.overapproximate(X::LazySet{N}, dirs::Vector{Vector{N}}) where {N}
    halfspaces = Vector{LinearConstraint{N}}()
    sizehint!(halfspaces, length(dirs))
    H = HPolytope(halfspaces)
    for d in dirs
        addconstraint!(H, LinearConstraint(d, ρ(d, X)))
    end
    return H
end

"""
     refine(P::LazySet; eps=1e-5, ndirs=200, nsamples=2000)

 Compute an concrete overapproximation of the lazy set `P`.
 The accuracy depends on the hyperparameter:
 2D-set: eps       => ϵ-close approximation
 3D-set: n_dirs    => #directions for evaluation the support value
 nD-set: n_samples => #directions for evaluation the support value

 ### Inputs
 - `P` -- lazy set
 - `eps`-- (optional, default=1e-5) define error tolarance of ϵ-close overapproximation of 2D set
 - `n_dirs`-- (optional, default=200) number of direction vectors evaluated for 3D set
 - `n_samples`-- (optional, default=2000) number of direction vectors evaluated for nD set with n>3

 ### Output
 Overapproximation of lazy set `P`.
"""
function refine(P::LazySet; eps=1e-5, n_dirs=200, n_samples=2000)
    n = LazySets.dim(P)
    if n == 2
        return refine_2D(P, eps)
    elseif n == 3
        return refine_3D(P, n_dirs)
    else
        P = refine_nD(P, n_samples)
        # NOTE: Not sure about remove_redundant_constraints! functionalities!
        remove_redundant_constraints!(P)
        return P
    end
end

function refine_nD(X, nsamples)
    n = LazySets.dim(X)
    dirs = Vector{Vector{Float64}}(undef, nsamples)
    LazySets._sample_unit_nsphere_muller!(dirs, n, nsamples)
    return overapproximate(X, dirs)
end

function refine_3D(X, n_dirs)
    dirs = Approximations.SphericalDirections(n_dirs, n_dirs)
    return overapproximate(X, dirs)
end

function refine_2D(X, err_approx)
    return overapproximate(X, err_approx)
end
