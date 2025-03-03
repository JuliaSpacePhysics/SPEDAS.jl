
@recipe MultiPlot begin
    plotfunc = plot!
end

function Makie.plot!(p::MultiPlot)
    plotfunc = p.plotfunc[]
    map(p[1][]) do x
        plotfunc(p, x)
    end
end

multiplot!(ax::Axis, data, args...; plotfunc=tplot_panel!, kwargs...) =
    map(data) do x
        plotfunc(ax, x; kwargs...)
    end

"""
    multiplot(gp, tas::MultiPlottable, args...; axis=(;), kwargs...)

Setup the panel on a position and plot multiple time series on it
"""
function multiplot(gp, tas, args...; axis=(;), add_title=DEFAULTS.add_title, kwargs...)
    ax = Axis(gp; axis_attributes(tas; add_title)..., axis...)
    plots = multiplot!(ax, tas, args...; kwargs...)
    PanelAxesPlots(gp, AxisPlots(ax, plots))
end