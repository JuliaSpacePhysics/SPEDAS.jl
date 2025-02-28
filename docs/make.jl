using SpaceTools
using Documenter
using DocumenterCitations
# using DemoCards

bib = CitationBibliography(joinpath(@__DIR__, "src", "refs.bib"))

# demopage, postprocess_cb, gallery_assets = makedemos("gallery")

makedocs(
    sitename="SpaceTools",
    pages=[
        "Home" => "index.md",
        "Tutorials" => [
            "tutorials/getting-started.md",
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
            "explanations/tplot.md",
            "explanations/coords.md",
            "explanations/multispacecraft.md",
            "explanations/resampling.md",
        ],
        "API" => "api.md",
    ],
    format=Documenter.HTML(size_threshold=nothing),
    modules=[SpaceTools],
    plugins=[bib],
    doctest=true
)

# postprocess_cb() # redirect url for DemoCards generated files

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
deploydocs(
    repo="github.com/Beforerr/SpaceTools.jl",
)
