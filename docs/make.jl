using SPEDAS
using SPEDAS.SpaceDataModel
using SpacePhysicsMakie
using Documenter
using DocumenterCitations

bib = CitationBibliography(joinpath(@__DIR__, "src", "refs.bib"))

md_filter(x) = filter(endswith(".md"), x)
list_pages(dir) = ["$dir/$f" for f in readdir(joinpath(@__DIR__, "src", dir))]

makedocs(
    sitename = "SPEDAS.jl",
    pages = [
        "Home" => "index.md",
        "Tutorials" => list_pages("tutorials"),
        "Explanation" => [
            "explanations/data.md",
            "explanations/data_model.md",
            "explanations/coords.md",
            "explanations/multispacecraft.md",
            "explanations/timeseries.md",
        ],
        "Observatories" => "observatory/index.md",
        "Validation" => list_pages("validation"),
        "API" => "api.md",
    ],
    format = Documenter.HTML(size_threshold = nothing),
    modules = [SPEDAS, SPEDAS.SpaceDataModel, SpacePhysicsMakie, SPEDAS.MinimumVarianceAnalysis],
    warnonly = Documenter.except(:doctest),
    plugins = [bib],
    doctest = true
)

deploydocs(
    repo = "github.com/JuliaSpacePhysics/SPEDAS.jl",
    push_preview = true
)
