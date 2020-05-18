using LinearAlgebra: Diagonal, I

# Note: for some operation, there may arise the need to install Optim (intersection)
# Polyhedra and CDDLib.

# """
#     THEORY:
#   Invariance: Region in which an autonomous system
#   satisifies the constraints for all time.
#
#   Control Invariance: Region in which there exists a controller
#   so that the system satisfies the constraints for all time.
#
#   A set 𝒪 is positive invariant if and only if 𝒪 ⊆ pre(𝒪)!
#   """

# TODO: Iteration number for maximum_invariant_set and maximum_control_invariant_set
#are of by one; I am not sure why!

"""
   state_constraints(𝕏::LazySet, 𝕌::LazySet, K)

Compute new state constraint set `𝒟` after intersection of the state constraint
set `𝕏` with the projection of the input constraints `𝕌` on the state space
according to the control law `u=-Kx ∈ 𝕌`.

### Input
- `𝕏` -- state constraint set
- `𝕌` -- input constraint set
- `K` -- linear control gain

### Output
State constraint set including the projection of input constraints on the state
space with a linear control gain.
"""
function state_constraints(𝕏::LazySet, 𝕌::LazySet, K)
    Hx, bx = tosimplehrep(𝕏)
    Hu, bu = tosimplehrep(𝕌)
    Hd = [Hx; Hu*(-K)]
    bd = [bx; bu]
    return HPolyhedron(Hd, bd)
end

function state_constraints2(𝕏::LazySet, 𝕌::LazySet, K)
    G, g = tosimplehrep(𝕌)
    return 𝕏 ∩ᶜ HPolyhedron(G*(-K), g)
end

"""
    preset(A, P::LazySet)

Compute preset of the autonomous linear system `x⁺=Ax` with state matrix `A`
starting from the state set `P = {x∈ℝⁿ | Fx≤f}`.

### Input
- `A` -- state matrix
- `P` -- starting state set

### Output
Preset of a autonomous linear system starting from the state set `P`.
"""
# WARNING: @code_warntype, this method is not typestable
function preset(A, P::LazySet)
    F, f = tosimplehrep(P)
    polyhedron = HPolyhedron(F*A, f)
    if isbounded(polyhedron)
        return HPolytope(F*A, f)
    end
    return polyhedron
end

"""
    preset(A, B, 𝕌::LazySet, P::LazySet)

Compute preset of the controlled linear system `x⁺=Ax + Bu` with state matrix `A`,
input matrix `B` and polyhedral input constraints set `u ∈ 𝕌 = {u∈ℝᵐ | Gx≤g}`
starting from the the state set `P = {x∈ℝⁿ | Fx≤f}`.

### Input
- `A` -- state matrix
- `B` -- input matrix
- `𝕌` -- input constraint set
- `P` -- starting state set

### Output
Preset of a controlled linear system as `VPolyhedron` starting from `P`.

### Note
- the method `preset_vrep` returns a `VPolyhedron`
- the method `preset_hrep` returns a `HPolyhedron`
"""
preset(A, B, 𝕌, P) = _preset_vrep(A, B, 𝕌, P)
# WARNING: What if X und U are not bounded?
function _preset_vrep(A, B, 𝕌, P)
    n = dim(P)
    m = dim(𝕌)
    F, f = tosimplehrep(P)
    G, g = tosimplehrep(𝕌)
    Z = zeros(size(G,1), size(F*A,2))
    sum = HPolytope([F*A F*B; Z G], [f;g])
    sumV = convert(VPolytope, sum)
    proj_mat = [Diagonal(ones(n)) zeros(n, m)]
    return proj_mat *ᶜ sumV
end

function _preset_hrep(A, B, 𝕌, P; kwargs...)
    n = dim(P)
    F, f = tosimplehrep(P)
    G, g = tosimplehrep(𝕌)
    Z = zeros(size(G,1), size(F*A,2))
    A = [F*A F*B; Z G]
    b = [f;g]
    return _projection(1:n, A, b;  kwargs...)
end

"""
    maximum_invariant_set(A, 𝕏::LazySet, max_iter::Integer=100)

Compute the maximum invariant set of the autonomous linear system `x⁺=Ax, x ∈ 𝕏`
with state matrix `A` and polyhedral state constraint set `𝕏 = {x∈ℝⁿ | Fx≤f}`.

The algorithm terminates if convergence is achieved before `max_iter` iterations.

### Input
- `A` -- state matrix
- `𝕏` -- state constraint set
- `max_iter` -- (optional, default=100) maximal number of iteration

### Output
Maximum invariant set for a autonomous linear system.

### Example
```julia
>julia D = state_constraints(X, U, K)

>julia Ω = maximum_invariant_set(A, D, s)
```
"""
function maximum_invariant_set(A, 𝕏::LazySet, max_iter::Integer=100)
    Ω = 𝕏
    for i=1:max_iter
        pre_set_Ω = preset(A, Ω)
        Ω⁺ = pre_set_Ω ∩ᶜ Ω
        if Ω ⊆ Ω⁺ && Ω⁺ ⊆ Ω
            println("Convergence at iteration : $i")
            return Ω⁺
        end
        Ω = Ω⁺
    end
    return Ω
end

"""
    maximum_invariant_set(A, B, 𝕏, 𝕌, K, max_iter::Integer=100)

Compute the maximum invariant set of the controlled linear system `x⁺ = Ax + Bu,
x ∈ 𝕏, u ∈ 𝕌` with state matrix `A`, polyhedral state  and input constraint set
`𝕏 = {x∈ℝⁿ | Fx≤f}` and `𝕌 = {u∈ℝᵐ | Gu≤g}`, and  linear control gain `u = -Kx`.

The algorithm terminates if convergence is achieved before `max_iter` iterations.

### Input
- `A` -- state matrix
- `B` -- input matrix
- `𝕏` -- state constraint set
- `𝕌` -- input constraint set
- `max_iter` -- (optional, default=100) maximal number of iteration

### Output
Maximum invariant set for a controlled linear system with linear controller.
"""
function maximum_invariant_set(A, B, 𝕏, 𝕌, K, max_iter::Integer=100)
    𝒟 = state_constraints(𝕏, 𝕌, K)
    S = A - B*K
    return maximum_invariant_set(S, 𝒟, max_iter)
end


"""
    maximum_control_invariant_set(A, B, 𝕏, 𝕌,
                                  [max_iter]=100;
                                  [preset]=preset_vrep,
                                  kwargs...)

Compute the maximum control invariant set of the controlled linear system `x⁺ = Ax + Bu,
x ∈ 𝕏, u ∈ 𝕌` with state matrix `A`, polyhedral state  and input constraint set
`𝕏 = {x∈ℝⁿ | Fx≤f}` and `𝕌 = {u∈ℝᵐ | Gu≤g}`.

The algorithm terminates if convergence is achieved before `max_iter` iterations.

### Input
- `A` -- state matrix
- `B` -- input matrix
- `𝕏` -- state constraint set
- `𝕌` -- input constraint set
- `max_iter` -- (optional, default=100) maximal number of iteration
- `preset` -- (optional, default=`preset_vrep`) algorithms used for calculation
 of preset

### Output
Maximum control invariant set for a controlled linear.
"""
function maximum_control_invariant_set(A, B, 𝕏, 𝕌, max_iter::Integer=100;
                                       preset=_preset_vrep, kwargs...)
    Ω = 𝕏
    for i=1:max_iter
        pre_set_Ω = preset(A, B, 𝕌, Ω; kwargs...)
        Ω⁺ = pre_set_Ω ∩ᶜ Ω
        if Ω ⊆ Ω⁺ && Ω⁺ ⊆ Ω
            println("Convergence at iteration : $i")
            return Ω⁺
        end
        Ω = Ω⁺
    end
    return Ω
end
