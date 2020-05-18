using Revise
using MathematicalSystems
using InvariantSets
using Test

A = [0.9 0.5; 0 0.9]
B = [1., 0]
D = I(2)
X = BallInf(zeros(2), 10.)
U = BallInf(zeros(1), 10.)
W = BallInf(zeros(2), 0.5)

K = [0.01 0.01]

autSys = @system x⁺ = A*x  x∈X
ctrlSys = @system x⁺ = A*x + B*u x∈X u∈U
noisyCtrlSys = @system x⁺ = A*x + B*u + D*w x∈X u∈U w∈W


Xfeas = state_constraints(ctrlSys, K)

using Polyhedra
using CDDLib
preSet = preset(autSys, X)
preSet = preset(ctrlSys, X)
feasible_set(ctrlSys, X, 1)

@test_throws ArgumentError maximum_invariant_set(ctrlSys)
maximum_invariant_set(autSys)
maximum_invariant_set(ctrlSys, K)
maximum_control_invariant_set(ctrlSys)
# tightened_constraints(ctrlSys, BallInf(zeros(2), 0.5), K)
terminal_set(ctrlSys, K)


# minimal_RPI_set(noisyCtrlSys, K; algorithm=InvariantSets.Rakovic())
# maximal_RPI_set(noisyCtrlSys, K; algorithm=InvariantSets.MaxRPIAnalytic(),
#                                  verbose=false,
#                                  k_converged=10)
