using Pseudopotentials
using Documenter

makedocs(;
    modules=[Pseudopotentials],
    authors="Qi Zhang <singularitti@outlook.com>",
    repo="https://github.com/MineralsCloud/Pseudopotentials.jl/blob/{commit}{path}#L{line}",
    sitename="Pseudopotentials.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://MineralsCloud.github.io/Pseudopotentials.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/MineralsCloud/Pseudopotentials.jl",
)
