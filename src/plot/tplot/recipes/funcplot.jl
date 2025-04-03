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
    m = meta(f)
    attrs = merge(
        axis_attributes(data; add_title),
        axis_attributes(m),
    )
    ax = Axis(gp; attrs..., axis...)
    plot = functionplot!(ax, f, tmin, tmax; data, plot=plottype_attributes(m), kwargs...)
    isspectrogram(data) && add_colorbar && Colorbar(gp[1, 1, Right()], plot; label=clabel(data))
    PanelAxesPlots(gp, AxisPlots(ax, plot))
end

"""
    functionplot!(ax, f, tmin, tmax; kwargs...)

Interactive plot of a function `f` on `ax` for a time range from `tmin` to `tmax`
"""
function functionplot!(ax, f, tmin, tmax; data=nothing, plotfunc=tplot_spec, plot=(;), kwargs...)
    to_plotspec = trange -> plotfunc(f(trange...); plot...)
    iviz_api!(ax, to_plotspec, (tmin, tmax); kwargs...)
end

"""
    multiplot!(ax, fs, t0, t1; plotfunc=tplot_spec, kwargs...)

Specialized multiplot function for `functionplot`.
Merge specs before plotting so as to cycle through them.
"""
function multiplot!(ax::Axis, fs, tmin, tmax; plotfunc=tplot_spec, kwargs...)
    to_plotspec = trange -> mapreduce(vcat, fs) do f
        plot = plottype_attributes(meta(f))
        plotfunc(f(trange...); plot..., kwargs...)
    end
    iviz_api!(ax, to_plotspec, (tmin, tmax); kwargs...)
end



# """
# Transform a function that handles time range to a function that handles x range (time values) and return x and y values.
# """
# function time2value_transform(xrange, f)
#     trange = x2t.(xrange)
#     da = f(trange...)
#     return t2x(da), vs(da)
# end

# time2value_transform(f) = (xrange) -> time2value_transform(xrange, f)

# function functionplot!(ax, f, tmin, tmax; data=nothing, xtickformat=format_datetime, kwargs...)
#     # get a sample data to determine the attributes and plot types
#     data = @something data f(tmin, tmax)
#     attrs = plottype_attributes(data)

#     # Manually converting from time to float is needed for interactive plotting since ax.finallimits[] is represented as float
#     # https://github.com/MakieOrg/Makie.jl/issues/4769
#     xmin, xmax = t2x.((tmin, tmax))
#     ax.xtickformat = values -> xtickformat.(x2t.(values))
#     rf = RangeFunction1D(time2value_transform(f), xmin, xmax)
#     plot_func = if isspectrogram(data)
#         y = spectrogram_y_values(data)
#         (x, mat) -> heatmap!(ax, x, y, mat; attrs..., kwargs...)
#     else
#         lbls = labels(data)
#         (xs, vs) -> linesplot!(ax, xs, vs; labels=lbls, kwargs...)
#     end
#     iviz(plot_func, rf)
# end