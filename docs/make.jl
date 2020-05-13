using Documenter, InvariantSets

makedocs(;
    modules=[InvariantSets],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
    ],
    repo="https://github.com/ueliwechsler/InvariantSets.jl/blob/{commit}{path}#L{line}",
    sitename="InvariantSets.jl",
    authors="Ueli Wechsler",
    assets=String[],
)

deploydocs(;
    repo="github.com/ueliwechsler/InvariantSets.jl",
)
