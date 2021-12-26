using Pseudopotentials
using Documenter

DocMeta.setdocmeta!(Pseudopotentials, :DocTestSetup, :(using Pseudopotentials); recursive=true)

makedocs(;
    modules=[Pseudopotentials],
    authors="Qi Zhang <singularitti@outlook.com>",
    repo="https://github.com/MineralsCloud/Pseudopotentials.jl/blob/{commit}{path}#{line}",
    sitename="Pseudopotentials.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://MineralsCloud.github.io/Pseudopotentials.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "Manual" => ["Installation" => "install.md", "Development" => "develop.md"],
        "API by modules" => [
            "`Pseudopotentials` module" => "api/Pseudopotentials.md",
        ],
    ],
)

deploydocs(;
    repo="github.com/MineralsCloud/Pseudopotentials.jl",
)
