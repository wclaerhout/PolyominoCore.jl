using Documenter
using Literate
using PolyominoTools
using CairoMakie   # loads the plotting extension for the tutorials

# Every Literate script in docs/tutorials/ becomes a page under "Tutorials", in
# filename order (prefix files with 01_, 02_, ... to order them). Each page also links
# to the script as a Jupyter notebook and as a plain Julia file. The generated files
# go to docs/src/tutorials/, which is gitignored.
const TUTORIALS_IN = joinpath(@__DIR__, "tutorials")
const TUTORIALS_OUT = joinpath(@__DIR__, "src", "tutorials")
rm(TUTORIALS_OUT; recursive = true, force = true)

function add_download_links(content, name)
    links = "# *Download this tutorial as a [Jupyter notebook]($name.ipynb) " *
            "or a [Julia script]($name.jl).*\n#\n"
    # place the links right after the title line
    title, rest = split(content, '\n'; limit = 2)
    return title * "\n#\n" * links * rest
end

tutorial_pages = String[]
for file in sort(filter(endswith(".jl"), readdir(TUTORIALS_IN)))
    path = joinpath(TUTORIALS_IN, file)
    name = splitext(file)[1]
    Literate.markdown(path, TUTORIALS_OUT;
        preprocess = s -> add_download_links(s, name))
    Literate.notebook(path, TUTORIALS_OUT; execute = false)
    Literate.script(path, TUTORIALS_OUT)
    push!(tutorial_pages, joinpath("tutorials", name * ".md"))
end

# Documenter picks up docs/src/assets/logo.svg (and logo-dark.svg for dark themes) as
# the sidebar logo. The repo keeps one copy in assets/, so copy it in at build time.
mkpath(joinpath(@__DIR__, "src", "assets"))
for name in ("logo.svg", "logo-dark.svg")
    cp(joinpath(@__DIR__, "..", "assets", name), joinpath(@__DIR__, "src", "assets", name);
        force = true)
end

DocMeta.setdocmeta!(PolyominoTools, :DocTestSetup, :(using PolyominoTools); recursive = true)

makedocs(;
    sitename = "PolyominoTools.jl",
    modules = [PolyominoTools, Base.get_extension(PolyominoTools, :PolyominoToolsMakieExt)],
    authors = "Ward Claerhout",
    format = Documenter.HTML(;
        prettyurls = get(ENV, "CI", "false") == "true",
        canonical = "https://wclaerhout.github.io/PolyominoTools.jl",
        assets = String[],
        sidebar_sitename = false,   # the logo already shows the package name
    ),
    pages = [
        "Home" => "index.md",
        "Tutorials" => tutorial_pages,
        "API" => "api.md",
    ],
    checkdocs = :public,
)

deploydocs(;
    repo = "github.com/wclaerhout/PolyominoTools.jl",
    devbranch = "main",
    push_preview = false,
)
