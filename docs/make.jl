using SPEDAS
using SPEDAS.SpaceDataModel
using Documenter
using DocumenterCitations
# using DemoCards

bib = CitationBibliography(joinpath(@__DIR__, "src", "refs.bib"))

# demopage, postprocess_cb, gallery_assets = makedemos("gallery")

makedocs(
    sitename="SPEDAS.jl",
    pages=[
        "Home" => "index.md",
        "Tutorials" => [
            "tutorials/getting-started.md",
            "tutorials/outliers.md",
            # demopage
        ],
        "Examples" => [
            "examples/index.md",
            "examples/speasy.md",
            "examples/tplot.md",
            "examples/interactive.md",
            "examples/interactive_speasy.md",
        ],
        "Explanation" => [
            "explanations/data.md",
            "explanations/data_model.md",
            "explanations/tplot.md",
            "explanations/coords.md",
            "explanations/multispacecraft.md",
            "explanations/resampling.md",
            "explanations/waves.md",
            "explanations/analysis.md",
        ],
        "Observatories" => [
            "observatory/$f" for f in filter(endswith(".md"), readdir("src/observatory"))
        ],
        "Validation" => [
            "validation/pyspedas.md",
        ],
        "API" => "api.md",
    ],
    format=Documenter.HTML(size_threshold=nothing),
    modules=[SPEDAS, SPEDAS.SpaceDataModel],
    warnonly=Documenter.except(:missing_docs),
    plugins=[bib],
    doctest=true
)

# postprocess_cb() # redirect url for DemoCards generated files

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
deploydocs(
    repo="github.com/Beforerr/SPEDAS.jl",
)
