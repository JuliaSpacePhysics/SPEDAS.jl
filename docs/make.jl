using Documenter
using SpaceTools
using DemoCards

gallery, postprocess_cb, gallery_assets = makedemos("gallery")

makedocs(
    sitename="SpaceTools",
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
