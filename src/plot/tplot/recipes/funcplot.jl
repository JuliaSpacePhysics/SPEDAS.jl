
@recipe FunctionPlot begin
    plotfunc = tplot_panel!
end


"""
    functionplot(gp, f, tmin, tmax; kwargs...)

Interactively plot a function over a time range on a grid position
"""
function functionplot(gp, f, tmin, tmax; axis=(;), add_title=DEFAULTS.add_title, add_colorbar=DEFAULTS.add_colorbar, xtickformat=format_datetime, kwargs...)
    # get a sample data to determine the attributes and plot types
    data = f(tmin, tmax)
    attrs = axis_attributes(data; add_title, xtickformat=values -> xtickformat.(x2t.(values)))
    ax = Axis(gp; attrs..., axis...)
    plot = functionplot!(ax, f, tmin, tmax; data, kwargs...)
    isspectrogram(data) && add_colorbar && Colorbar(gp[1, 1, Right()], plot; label=clabel(data))
    PanelAxesPlots(gp, AxisPlots(ax, plot))
end

"""
    functionplot!(ax, f, tmin, tmax; kwargs...)

Interactive plot of a function `f` on `ax` for a time range from `tmin` to `tmax`
"""
function functionplot!(ax, f, tmin, tmax; data=nothing, kwargs...)
    # get a sample data to determine the attributes and plot types
    data = @something data f(tmin, tmax)
    attrs = plottype_attributes(data)

    # Manually converting from time to float is needed for interactive plotting since ax.finallimits[] is represented as float
    # https://github.com/MakieOrg/Makie.jl/issues/4769
    xmin, xmax = t2x.((tmin, tmax))
    rf = RangeFunction1D(time2value_transform(f), xmin, xmax)
    plot_func = if isspectrogram(data)
        y = spectrogram_y_values(data)
        (x, mat) -> heatmap!(ax, x, y, mat; attrs..., kwargs...)
    else
        if ndims(data) == 2
            (xs, vs) -> series!(ax, xs, @lift(permutedims($vs)); attrs..., kwargs...)
        else
            (xs, vs) -> lines!(ax, xs, vs; attrs..., kwargs...)
        end
    end
    iviz(plot_func, rf)
end