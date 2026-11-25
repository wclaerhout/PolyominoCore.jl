using Documenter
using Literate
using Polyominoes
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
        "Tutorials" => tutorial_pages,
        "API" => "api.md",
    ],
    checkdocs = :public,
)

deploydocs(;
    repo = "github.com/wclaerhout/Polyominoes.jl",
    devbranch = "main",
    push_preview = false,
)
