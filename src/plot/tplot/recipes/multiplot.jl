
@recipe MultiPlot begin
    plotfunc = plot!
end

function Makie.plot!(p::MultiPlot)
    plotfunc = p.plotfunc[]
    map(p[1][]) do x
        plotfunc(p, x)
    end
end

# For compatibility since `multiplot_spec!` need to concatenate specs before plotting
function multiplot!(ax::Axis, data, args...; plotfunc=tplot_panel!, kwargs...)
    plottypes = map(plottype, data)
    if all(plottypes .== PanelPlot)
        return multiplot_func!(ax, data, args...; plotfunc, kwargs...)
    else
        multiplot_spec!(ax, data, args...; kwargs...)
    end
end

multiplot_func!(ax::Axis, data, args...; plotfunc=tplot_panel!, kwargs...) =
    map(data) do x
        plotfunc(ax, x, args...; kwargs...)
    end

function multiplot_spec!(ax::Axis, data, args...; to_plotspec=tplot_spec, kwargs...)
    specs = mapreduce(vcat, data) do x
        to_plotspec(x, args...; kwargs...)
    end
    plotlist!(ax, specs)
end

"""
    multiplot(gp, tas::MultiPlottable, args...; axis=(;), kwargs...)

Setup the panel on a position and plot multiple time series on it
"""
function multiplot(gp, tas, args...; axis=(;), add_title=DEFAULTS.add_title, kwargs...)
    ax = Axis(gp; axis_attributes(tas, args...; add_title)..., axis...)
    plots = multiplot!(ax, tas, args...; kwargs...)
    PanelAxesPlots(gp, AxisPlots(ax, plots))
end