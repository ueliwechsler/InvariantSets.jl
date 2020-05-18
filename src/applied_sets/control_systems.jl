# TODO: add documentation and example! (MPC)

# terminal set around origin => how to shift and still satisfy constraints?
# just shift \bbX ???? and apply algo?
# tube-based MPC => X,U are X_bar, U_bar!!!
function terminal_set(A, B, 𝕏::LazySet, 𝕌::LazySet, K; max_iter::Integer=100)
    return maximum_invariant_set(A, B, 𝕏, 𝕌, K, max_iter)
end

# How do we compute P?
function terminal_set(center, P, α, 𝕏::LazySet)
    # TODO: extend ELlipsoid to have biggest ELlipsoid in X
    E =  Ellipsoid(center, inv(P)/α)
    if E ⊆ 𝕏
        return E
    end
    error("E not contained in 𝕏")
end

function feasible_set(A, B, 𝕏::LazySet, 𝕌::LazySet, 𝕏f::LazySet, N::Integer;
                       preset=_preset_vrep)
    𝕏_feas = preset(A, B, 𝕌, 𝕏f) ∩ᶜ 𝕏
    for i=2:N
        𝕏_feas = preset(A, B, 𝕌, 𝕏_feas) ∩ᶜ 𝕏
    end
    return 𝕏_feas
end

# TODO: Add once the paper is published and write Tests!
"""
    tightened_constraints(A, B, W, X, U, K)

Source Code not yet published due to impending paper.
"""
function tightened_constraints() end
function tightened_input_constraint() end
function tightened_state_constraint() end
