# InvariantSets

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://ueliwechsler.github.io/InvariantSets.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://ueliwechsler.github.io/InvariantSets.jl/dev)
[![Build Status](https://travis-ci.com/ueliwechsler/InvariantSets.jl.svg?branch=master)](https://travis-ci.com/ueliwechsler/InvariantSets.jl)
[![Codecov](https://codecov.io/gh/ueliwechsler/InvariantSets.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/ueliwechsler/InvariantSets.jl)
[![Coveralls](https://coveralls.io/repos/github/ueliwechsler/InvariantSets.jl/badge.svg?branch=master)](https://coveralls.io/github/ueliwechsler/InvariantSets.jl?branch=master)

`InvariantSets.jl` brings some of the set computational functionalities provided by `MATLAB` plugin  [Multi-Parametric Toolbox 3 (MPT)](https://www.mpt3.org/) to the `Julia Programming Language` and extends it with lazy set computation features. This package enables the user to compute, approximate and display invariant sets using a similar notation as in MPT but without needing a costly `MATLAB` license.

`InvariantSets.jl` builds upon [`LazySets.jl`](https://github.com/JuliaReach/LazySets.jl) which provides "lazy" and concrete set computation (with `Polyhedra.jl` and `CDDLib.jl` as polyhedral computation backend).
As a result, if needed, the full computational power of `LazySets.jl` can be leveraged if needed.

## Installation


## Content

### Set Types
Set Type | Constructor | Description
---- | ----| -----
`HPolygon`/`HPolytope`/`HPolyhedron` | `HPolytope(A, b)` | `P = {x∈ℝⁿ: Ax≤b}`  
`VPolygon`/`VPolytope`/`VPolyhedron` | `VPolytope(V)` | `V∈ℝⁿˣᵐ`
`Ballp`/ `Ball1` / `Ball2`/ `BallInf` | `Ball1(center, radius)` |
`Ellipsoid` | `Ellipsoid(center, shape_matrix)` |
`Zonotope` | `Zonotope(center, generator)`
`Hyperrectangle` | `Hyperrectangle(center, radius)` | 
` `  | `Hyperrectangle(low=min, high=max)` |
`Hyperplane` / `HalfSpace` | `HalfSpace(a,b)` |
`Singleton` | `Singleton(element)` |
`SingleEntryVector` | `SingleEntryVector(dim, idx, value)` |
`Interval` | `Interval(start, end)` |


### Concrete Set Operations

In `LazySets.jl` the common operator `+`, `*` and `∩` correspond to lazy set operations.
This is the same in `InvariantSets.jl`, in addition, the **concrete** set operators
`+ᶜ`, `-ᶜ`, `*ᶜ` and `∩ᶜ`. In most IDEs, the superscript `ᶜ` can be written with `\^c → tab`.
```julia
using Polyhedra
using CDDLib

A = [1.0  0.0;
     0.0  1.0;
    -1.0  0.0;
     0.0 -1.0;
     1.0 1.0]
b = [1.0, 2.0, 3.0, 4.0, 1.0]
origin = [0.0, 0.0]
polygon = HPolygon(A,b)
ball = Ball1(origin, 1.3)
ball2 = Ball2(origin, 1.0)
A = [2.0 0.0; 0.0 0.5]
# Scaling
ball_scaled = 2.0 *ᶜ ball
# Linear Map
ball_lm = A *ᶜ ball
# Translation of ball
ball_trans = [2.0,2.0] +ᶜ ball
# Minkowski Sum
sum = polygon +ᶜ ball
# Pontryagin Difference
diff = polygon -ᶜ ball2
# polygon_after_diff = diff + ball2
# Intersection
intersection = polygon ∩ᶜ ball
# Reflection
polygon_reflected = reflect(polygon)
# Minkowski Difference
diff_minsk = ball_trans +ᶜ reflect(polygon)
# chebyshev center
c, r = InvariantSets.chebyshev_center(polygon,  get_radius=true)
chebyball = Ball2(c, r)
```

## Invariant Sets & Control Systems
Name  | Constructor | Description
 ----| ---- | ----
`preset` | `preset(A, X)` |
`state_constraints` | `state_constraints(X, U, K)` |
`maximum_invariant_set` | `maximum_invariant_set(A, X, N)` |
`maximum_control_invariant_set` | `maximum_control_invariant_set(A, B, X, U, N)` |
`terminal_set` | `terminal_set(A, B, X, U, K)` |
`feasible_set` | `feasible_set(A, B, X, U, Xf, N)` |
~~`maximal_RPI_set`~~ | ` ` |
~~`minimal_RPI_set`~~ | ` ` |
~~`tightened_constraints`~~ | ` ` |

### Integration with `MathematicalSystems.jl`
```julia
A = [0.9 0.5; 0 0.9]
B = [1., 0]
X = BallInf(zeros(2), 10.)
U = BallInf(zeros(1), 1.)

K = [0.1 0.1]

autSys = @system x⁺ = A*x  x∈X
ctrlSys = @system x⁺ = A*x + B*u x∈X u∈U

IS = maximum_invariant_set(autSys)
MIL = maximum_invariant_set(ctrlSys, K)
MCI = maximum_control_invariant_set(ctrlSys)
```

### Integration with `JuMP.jl`
```julia
using InvariantSets
using JuMP
m = Model()
@variable(m, X[1:2, 1:5])
@variable(m, U[1:1, 1:2]) # U[1,1:5] does not work
constru= BallInf(zeros(size(U,1)), 2.0)
constrx = HPolyhedron([1 -2.], [1.])
InvariantSets.add_constraint!(m, X, constrx)
InvariantSets.add_constraint!(m, U, constru)
# Feasibility
# Subject to
# X[1,1] - 2 X[2,1] <= 1.0
# X[1,2] - 2 X[2,2] <= 1.0
# X[1,3] - 2 X[2,3] <= 1.0
# X[1,4] - 2 X[2,4] <= 1.0
# X[1,5] - 2 X[2,5] <= 1.0
# U[1,1] <= 2.0
# -U[1,1] <= 2.0
# U[1,2] <= 2.0
# -U[1,2] <= 2.0
```

### Comparison to MATLAB and MPT

#### Geometric operations with polyhedra
Matlab and MPT
```python
P1 = Polyhedron( 'A', [1 -2.1 -0.5; 0.8 -3.1 0.9; -1.2 0.4 -0.8], 'b', [1; 4.9; -1.8])
P1.isEmptySet()
P1.isBounded()
P1.plot()

P2 = Polyhedron('lb', [-1; -2], 'ub', [3; 4])
P2.computeVRep
P2.V

P3 = Polyhedron([4, -1; 4, 5; 8, 3])
P3.computeHRep

V = [ -1.7 -0.4; -0.4  0.7; 1.2 -0.8; 0 0.8; 1.3 0.9; -0.3 0.6];
P4 = Polyhedron(V);
x0 = [0; 0];
P4.contains( x0 )
x1 = [3; 0];
P4.contains( x1 )

P5 = Polyhedron([ 1.8  -4.8; -7.2 -3.4; -4.2 1.2; 5.8  2.7]);
data = P5.chebyCenter()
```
Julia and InvariantSets
```julia
P1 = Polyhedron([1 -2.1 -0.5; 0.8 -3.1 0.9; -1.2 0.4 -0.8],  [1; 4.9; -1.8])
isempty(P1) # or P1 |> isempty
isbounded(P1)
plot(P1)

P2 = Hyperrectangle(low=[-1, -2], high=[3,4])
P2hrep = convert(HPolytope, P2)
P2vrep =  tovrep(P2hrep)
P2vrep.vertices

P3vrep = VPolytope([4 -1; 4 5; 8 3.]);
P3hrep = HPolytope(tosimplehrep(P3vrep)...)

V = [ -1.7 -0.4; -0.4  0.7; 1.2 -0.8; 0 0.8; 1.3 0.9; -0.3 0.6];
P4 = VPolytope(V');
[0., 0.] ∈ P4
[3., 0.] ∈ P4

P5 = VPolytope([ 1.8  -4.8; -7.2 -3.4; -4.2 1.2; 5.8  2.7]');
chebyshev_center(P5)
```


#### Maximum Control Invariant Sets
Matlab and MPT:
``` python
% computes a control invariant set for LTI system x^+ = A*x+B*u
system = LTISystem('A', [1 1; 0 0.9], 'B', [1; 0.5]);
system.x.min = [-5; -5];
system.x.max = [5; 5];
system.u.min = -1;
system.u.max = 1;
InvSet = system.invariantSet()
InvSet.plot()
```
![Picture](C:\Users\ueliwech\.julia\dev\InvariantSets\docs\imgs\matlab_invariant_set.png)
Julia:
```julia
using InvariantSets, Polyhedra, CDDLib
using MathematicalSystems
using Plots
A = [1 1; 0 0.9]
B = [1; 0.5]
X = Hyperrectangle(low=[-5, -5], high=[5, 5])
U = Hyperrectangle(low=[-1], high=[1])
system = @system x⁺ = A*x + B*u x∈X u∈U
InvSet = maximum_control_invariant_set(system)
plot(InvSet)
```
