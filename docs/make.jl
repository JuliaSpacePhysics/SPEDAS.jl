using Documenter
using SpaceTools

makedocs(
    sitename="SpaceTools",
    format=Documenter.HTML(),
    modules=[SpaceTools],
    doctest=true
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
deploydocs(
    repo="github.com/Beforerr/SpaceTools.jl",
)
