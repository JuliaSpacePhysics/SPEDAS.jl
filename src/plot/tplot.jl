export tplot!, tplot, tplot_panel, tplot_panel!
export LinesPlot, linesplot, linesplot!
export tlims!, tlines!, add_labels!

include("types.jl")
include("tplot/core.jl")
include("tplot/panel.jl")
include("tplot/specapi.jl")
include("tplot/recipes/dualplot.jl")
include("tplot/recipes/funcplot.jl")
include("tplot/recipes/linesplot.jl")
include("tplot/recipes/multiplot.jl")
include("tplot/recipes/panelplot.jl")
include("tplot/recipes/specplot.jl")
include("tplot/interactive.jl")
include("methods.jl")
include("utils.jl")
