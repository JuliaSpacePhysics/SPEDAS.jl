using Documenter
using SpaceTools
using DemoCards

demopage, postprocess_cb, gallery_assets = makedemos("gallery")

makedocs(
    sitename="SpaceTools",
    pages=[
        "Home" => "index.md",
        "Tutorials" => [
            "tutorials/getting-started.md",
            demopage
        ],
        "Explanation" => [
            "explanations/tplot.md",
            "explanations/coords.md",
        ],
        "API" => "api.md",
    ],
    format=Documenter.HTML(size_threshold=nothing),
    modules=[SpaceTools],
    doctest=true
)

postprocess_cb() # redirect url for DemoCards generated files

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
deploydocs(
    repo="github.com/Beforerr/SpaceTools.jl",
)
