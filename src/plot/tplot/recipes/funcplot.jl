@recipe FunctionPlot begin
    plotfunc = tplot_panel!
end


"""
    functionplot(gp, f, tmin, tmax; kwargs...)

Interactively plot a function over a time range on a grid position
"""
function functionplot(gp, f, tmin, tmax; axis=(;), add_title=DEFAULTS.add_title, add_colorbar=DEFAULTS.add_colorbar, plot=(;), kwargs...)
    # get a sample data to determine the attributes and plot types
    data = f(tmin, tmax)
    m = @something meta(f) Dict()
    attrs = merge(
        axis_attributes(data; add_title),
        convert(Dict, filter_by_fieldnames(Axis, m)),
    )
    ax = Axis(gp; attrs..., axis...)
    plot = _merge(plottype_attributes(m), plot)
    p = functionplot!(ax, f, tmin, tmax; data, plot, kwargs...)
    isspectrogram(data) && add_colorbar && Colorbar(gp[1, 1, Right()], p; label=clabel(data))
    PanelAxesPlots(gp, AxisPlots(ax, p))
end

"""
    functionplot!(ax, f, tmin, tmax; kwargs...)

Interactive plot of a function `f` on `ax` for a time range from `tmin` to `tmax`
"""
function functionplot!(ax, f, tmin, tmax; data=nothing, plotfunc=plot2spec, plot=(;), kwargs...)
    to_plotspec = trange -> plotfunc(f(trange...); plot...)
    iviz_api!(ax, to_plotspec, (tmin, tmax); kwargs...)
end

"""
    multiplot!(ax, fs, t0, t1; plotfunc=plot2spec, kwargs...)

Specialized multiplot function for `functionplot`.
Merge specs before plotting so as to cycle through them.
"""
function multiplot!(ax::Axis, fs, tmin, tmax; plotfunc=plot2spec, plot=(;), kwargs...)
    to_plotspec = trange -> mapreduce(vcat, fs) do f
        attrs = plottype_attributes(meta(f))
        plotfunc(f(trange...); attrs..., plot...)
    end
    iviz_api!(ax, to_plotspec, (tmin, tmax); kwargs...)
end
