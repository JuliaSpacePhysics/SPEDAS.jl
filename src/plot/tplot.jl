module TPlot
using ..SPEDAS
using Makie
using MakieCore
using Dates
using Unitful, Latexify, UnitfulLatexify
using SpaceDataModel: meta, AbstractDataVariable
using DimensionalData: DimArray
using Accessors: @set
import ..SPEDAS: label, labels, clabel, DEFAULTS

import MakieCore: convert_arguments, plot!, conversion_trait

export tplot!, tplot, tplot_panel, tplot_panel!
export LinesPlot, linesplot, linesplot!
export tlims!, tlines!, add_labels!
export transform, transform_speasy
export plot_attributes

include("tplot/makie.jl")
include("attributes.jl")
include("types.jl")
include("tplot/transform.jl")
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
include("tplot/ext/DimensionalDataExt.jl")
include("tplot/ext/SpaceDataModelExt.jl")
end
