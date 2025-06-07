"""
Panel plotting functionality for time series.
This module contains the `tplot_panel` function and its variants.
"""

pfdoc = """
Determine the plotting function for a given data type.
Extend this for custom data types to integrate with the plotting system.
"""

@doc pfdoc function plotfunc end
@doc pfdoc function plotfunc! end

# default fallback
plottype(::Any) = PanelPlot
plottype(x::AbstractVector{<:Number}) = PanelPlot

plottype(::AbstractVector) = MultiPlot
plottype(::NamedTuple) = MultiPlot
plottype(::DualAxisData) = DualPlot
plottype(::NTuple{2,Any}) = DualPlot
plottype(::Function) = FunctionPlot
plottype(args...) = plottype(args[1])

plotfunc(args...) = Makie.MakieCore.plotfunc(plottype(args...))
plotfunc!(args...) = Makie.MakieCore.plotfunc!(plottype(args...))

"""
    tplot_panel(gp, args...; kwargs...)

Generic entry point for plotting different types of data on a grid position `gp`.

Transforms the arguments to appropriate types and calls the plotting function.
Dispatches to appropriate implementation based on the plotting trait of the transformed arguments.
"""
function tplot_panel(gp, data, args...; transform=transform_pipeline, kwargs...)
    transformed = transform(data, args...)
    pf = plotfunc(transformed)
    pf(gp, transformed, args...; kwargs...)
end

"""
    tplot_panel!(ax, args...; kwargs...)

Generic entry point for adding plots to an existing axis `ax`.

Transforms the arguments to appropriate types and calls the plotting function.
Dispatches to appropriate implementation based on the plotting trait of the transformed arguments.
"""
function tplot_panel!(ax::Axis, data, args...; kwargs...)
    transformed = transform_pipeline(data)
    pf! = plotfunc!(transformed)
    pf!(ax, transformed, args...; kwargs...)
end

tplot_panel!(args...; kwargs...) = tplot_panel!(current_axis(), args...; kwargs...)
