
@recipe FunctionPlot begin
    plotfunc = tplot_panel!
end


"""
    functionplot(gp, f, tmin, tmax; kwargs...)

Interactively plot a function over a time range on a grid position
"""
function functionplot(gp, f, tmin, tmax; axis=(;), add_title=DEFAULTS.add_title, add_colorbar=DEFAULTS.add_colorbar, xtickformat=format_datetime, kwargs...)
    # get a sample data to determine the attributes and plot types
    ta = f(tmin, tmax)
    attrs = axis_attributes(ta; add_title, xtickformat=values -> xtickformat.(x2t.(values)))
    ax = Axis(gp; attrs..., axis...)
    plot = functionplot!(ax, f, tmin, tmax; kwargs...)
    isspectrogram(ta) && add_colorbar && Colorbar(gp[1, 1, Right()], plot; label=clabel(ta))
    PanelAxesPlots(gp, AxisPlots(ax, plot))
end

"""
    functionplot!(ax, f, tmin, tmax; kwargs...)

Interactive plot of a function `f` on `ax` for a time range from `tmin` to `tmax`
"""
function functionplot!(ax, f, tmin, tmax; kwargs...)
    # get a sample data to determine the attributes and plot types
    ta = f(tmin, tmax)
    attrs = plottype_attributes(ta)

    # Manually converting from time to float is needed for interactive plotting since ax.finallimits[] is represented as float
    # https://github.com/MakieOrg/Makie.jl/issues/4769
    xmin, xmax = t2x.((tmin, tmax))
    data = RangeFunction1D(time2value_transform(f), xmin, xmax)
    plot_func = if isspectrogram(ta)
        y = spectrogram_y_values(ta)
        (x, mat) -> heatmap!(ax, x, y, mat; attrs..., kwargs...)
    else
        if ndims(ta) == 2
            (xs, vs) -> series!(ax, xs, @lift(permutedims($vs)); attrs..., kwargs...)
        else
            (xs, vs) -> lines!(ax, xs, vs; attrs..., kwargs...)
        end
    end
    iviz(plot_func, data)
end