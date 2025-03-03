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

"""
    tsheat(data; kwargs...)

Heatmap with better default attributes for time series.

References:
- https://docs.makie.org/stable/reference/plots/heatmap
"""
function tsheat(da::AbstractDimArray; colorscale=log10, colorrange=colorrange(da), kwargs...)

    fig, ax, hm = heatmap(da; colorscale, colorrange, kwargs...)
    Colorbar(fig[:, end+1], hm)

    # rasterize the heatmap to reduce file size
    if *(size(da)...) > 32^2
        hm.rasterize = true
    end

    fig, ax, hm
end