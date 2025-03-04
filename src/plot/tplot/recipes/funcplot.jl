@recipe FunctionPlot begin
    plotfunc = tplot_panel!
end


"""
    functionplot(gp, f, tmin, tmax; kwargs...)

Interactively plot a function over a time range on a grid position
"""
function functionplot(gp, f, tmin, tmax; axis=(;), add_title=DEFAULTS.add_title, add_colorbar=DEFAULTS.add_colorbar, kwargs...)
    # get a sample data to determine the attributes and plot types
    data = f(tmin, tmax)
    attrs = axis_attributes(data; add_title)
    ax = Axis(gp; attrs..., axis...)
    plot = functionplot!(ax, f, tmin, tmax; data, kwargs...)
    isspectrogram(data) && add_colorbar && Colorbar(gp[1, 1, Right()], plot; label=clabel(data))
    PanelAxesPlots(gp, AxisPlots(ax, plot))
end

"""
    functionplot!(ax, f, tmin, tmax; kwargs...)

Interactive plot of a function `f` on `ax` for a time range from `tmin` to `tmax`
"""
function functionplot!(ax, f, tmin, tmax; data=nothing, xtickformat=format_datetime, kwargs...)
    # get a sample data to determine the attributes and plot types
    data = @something data f(tmin, tmax)
    attrs = plottype_attributes(data)

    # Manually converting from time to float is needed for interactive plotting since ax.finallimits[] is represented as float
    # https://github.com/MakieOrg/Makie.jl/issues/4769
    xmin, xmax = t2x.((tmin, tmax))
    ax.xtickformat = values -> xtickformat.(x2t.(values))
    rf = RangeFunction1D(time2value_transform(f), xmin, xmax)
    plot_func = if isspectrogram(data)
        y = spectrogram_y_values(data)
        (x, mat) -> heatmap!(ax, x, y, mat; attrs..., kwargs...)
    else
        lbls = labels(data)
        (xs, vs) -> linesplot!(ax, xs, vs; labels=lbls, kwargs...)
    end
    iviz(plot_func, rf)
end


# Not working yet, depends on https://github.com/MakieOrg/Makie.jl/issues/4774
function _functionplot!(ax, f, tmin, tmax; data=nothing, kwargs...)
    # get a sample data to determine the attributes and plot types
    data = @something data f(tmin, tmax)
    attrs = plottype_attributes(data)
    rf = RangeFunctionData1D((xrange) -> f(x2t.(xrange)...), tmin, tmax)
    plot_func = if isspectrogram(data)
        y = spectrogram_y_values(data)
        (x, mat) -> heatmap!(ax, x, y, mat; attrs..., kwargs...)
    else
        data -> linesplot!(ax, data; attrs..., kwargs...)
    end
    iviz(plot_func, rf)
end