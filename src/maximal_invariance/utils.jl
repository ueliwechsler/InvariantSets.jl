
function _projection(projection_idx, E::AbstractMatrix{N}, e::AbstractVector{N},
                             backend=nothing,
                             algorithm=nothing,
                             prune=true) where {N<:Real}
    require(:Polyhedra; fun_name="_projection")
    require(:CDDLib; fun_name="_projection")
    if backend == nothing
        backend = LazySets.default_cddlib_backend(N)
    end

    if algorithm == nothing
        algorithm = Polyhedra.FourierMotzkin()
    elseif !(algorithm <: EliminationAlgorithm)
        error("the algorithm $algorithm is not a valid elimination algorithm;
              choose among any of $(subtypes(Polyhedra.EliminationAlgorithm))")
    end
    eliminiation_idx = setdiff(1:size(E,2), projection_idx)
    PQ = HPolyhedron(E, e)
    PQ_cdd = polyhedron(PQ, backend=backend)
    W = HPolyhedron(Polyhedra.eliminate(PQ_cdd, eliminiation_idx, algorithm))
    if prune
        success = LazySets.remove_redundant_constraints!(W)
        if !success
            error("the constraints corresponding to the minkowski sum of the given " *
                  "sets are infeasible")
        end
    end
    return W
end
