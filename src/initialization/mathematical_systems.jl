using .MathematicalSystems

_throw_not_noisy(sys) = isnoisy(sys) ? sys :  throw(ArgumentError("system is not noisy"))
_throw_not_affine(sys) = isaffine(sys) ? sys :  throw(ArgumentError("system is not affine"))
_throw_not_constrained(sys) = isconstrained(sys) ? sys :  throw(ArgumentError("system is not constrained"))
_throw_not_autonomous(sys) = !iscontrolled(sys) ? sys :  throw(ArgumentError("system is not autonomous"))
_throw_not_controlled(sys) = iscontrolled(sys) ? sys :  throw(ArgumentError("system is not controlled"))

# =============
# robust invariance
# =============
# function minimal_RPI_set(sys::AbstractDiscreteSystem, K;
#                          algorithm=RakovicLazy(), kwargs...)
#     sys |> _throw_not_affine |>
#            _throw_not_noisy
#
#     W = noiseset(sys)
#     S = sys.A - sys.B*K
#     return minimal_RPI_set(S, W)
# end

# function maximal_RPI_set(sys::AbstractDiscreteSystem, K;
#                          algorithm=MaxRPIIterative(), kwargs...)
#     sys |> _throw_not_affine |>
#            _throw_not_noisy |>
#            _throw_not_constrained |>
#            _throw_not_controlled
#
#     X = stateset(sys)
#     W = noiseset(sys)
#     S = sys.A - sys.B*K
#     return maximal_RPI_set(algorithm, S, W, X; kwargs...)
# end

# ===========
# Invariant Sets
# ===========

function state_constraints(sys::AbstractDiscreteSystem, K)
    sys |> _throw_not_constrained |>
           _throw_not_controlled

    X = stateset(sys)
    U = inputset(sys)
    return state_constraints(X, U, K)
end

function preset(sys::AbstractDiscreteSystem, P::LazySet)
    sys |> _throw_not_affine

    A = sys.A
    if !iscontrolled(sys)
        return preset(A, P)
    else
        sys |> _throw_not_constrained
        U = inputset(sys)
        B = sys.B
        return preset(A, B, U, P)
    end
end

function maximum_invariant_set(sys::AbstractDiscreteSystem, max_iter::Integer=100)
    sys |> _throw_not_affine |>
           _throw_not_constrained |>
           _throw_not_autonomous

    A = sys.A
    X = stateset(sys)
    return maximum_invariant_set(A, X, max_iter)
end
function maximum_invariant_set(sys::AbstractDiscreteSystem, K, max_iter::Integer=100)
    sys |> _throw_not_affine |>
           _throw_not_constrained |>
           _throw_not_controlled

    X = stateset(sys)
    U = inputset(sys)
    A = state_matrix(sys)
    B = input_matrix(sys)
    return maximum_invariant_set(A, B, X, U, K, max_iter)
end

function maximum_control_invariant_set(sys::AbstractDiscreteSystem, max_iter=100;
                                       preset=_preset_vrep, kwargs...)
   sys |> _throw_not_affine |>
          _throw_not_constrained |>
          _throw_not_controlled

   X = stateset(sys)
   U = inputset(sys)
   A = state_matrix(sys)
   B = input_matrix(sys)
   return maximum_control_invariant_set(A, B, X, U, max_iter; preset=preset, kwargs...)
end

# =============
# Control Systems
# =============

# function tightened_constraints(sys::AbstractDiscreteSystem, Ω::LazySet, K;
#                                algorithm=RakovicLazy(), kwargs...)
#     sys |> _throw_not_affine |>
#            _throw_not_constrained
#
#     X = stateset(sys)
#     U = inputset(sys)
#     return tightened_constraints(X, U, Ω, K)
# end

function terminal_set(sys::AbstractDiscreteSystem, K; kwargs...)
    sys |> _throw_not_affine |>
          _throw_not_constrained |>
          _throw_not_controlled

    X = stateset(sys)
    U = inputset(sys)
    A = state_matrix(sys)
    B = input_matrix(sys)
    return terminal_set(A, B, X, U, K; kwargs...)
end

function feasible_set(sys::AbstractDiscreteSystem, 𝕏f::LazySet, N::Integer; kwargs...)
    sys |> _throw_not_affine |>
           _throw_not_constrained |>
           _throw_not_controlled

    X = stateset(sys)
    U = inputset(sys)
    A = state_matrix(sys)
    B = input_matrix(sys)
    return feasible_set(A, B, X, U, 𝕏f, N; kwargs...)
end
