import LazySets.require

function __init__()
    @require JuMP = "4076af6c-e467-56ae-b986-b466b2749572" include(raw"initialization/jump.jl")
    @require MathematicalSystems = "d14a8603-c872-5ed3-9ece-53e0e82e39da" include(raw"initialization/mathematical_systems.jl")
    # This packages are already required in LazySets (i think)
    # @require Polyhedra = "67491407-f73d-577b-9b50-8179a7c68029" ""
    # @require CDDLib = "3391f64e-dcde-5f30-b752-e11513730f60"
    # @require Optim = "429524aa-4258-5aef-a3af-852621145aeb"
end
