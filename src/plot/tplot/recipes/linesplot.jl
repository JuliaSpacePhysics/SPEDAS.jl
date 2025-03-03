@recipe LinesPlot begin end

"""
    linesplot(gp, ta)

Plot a multivariate time series on a panel
"""
function linesplot(gp, ta; axis=(;), add_title=DEFAULTS.add_title, kwargs...)
    ax = Axis(gp; axis_attributes(ta; add_title)..., axis...)
    plots = linesplot!(ax, ta; kwargs...)
    PanelAxesPlots(gp, AxisPlots(ax, plots))
end

"""
Plot multiple columns of a time series on the same axis
"""
function linesplot!(ax::Axis, ta; labels=labels(ta), kwargs...)
    ta = resample(ta)
    x = dims(ta, Ti).val
    map(eachcol(ta.data), labels) do y, label
        lines!(ax, x, y; label, kwargs...)
    end
end