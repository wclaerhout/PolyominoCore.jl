using Documenter
using Polyominoes
using CairoMakie   # loads the plotting extension for the tutorial

DocMeta.setdocmeta!(Polyominoes, :DocTestSetup, :(using Polyominoes); recursive = true)

makedocs(;
    sitename = "Polyominoes.jl",
    modules = [Polyominoes, Base.get_extension(Polyominoes, :PolyominoesMakieExt)],
    authors = "Ward Claerhout",
    format = Documenter.HTML(;
        prettyurls = get(ENV, "CI", "false") == "true",
        canonical = "https://wclaerhout.github.io/Polyominoes.jl",
        assets = String[],
    ),
    pages = [
        "Home" => "index.md",
        "Tutorial" => "tutorial.md",
        "API" => "api.md",
    ],
    checkdocs = :public,
)

deploydocs(;
    repo = "github.com/wclaerhout/Polyominoes.jl",
    devbranch = "main",
    push_preview = false,
)
