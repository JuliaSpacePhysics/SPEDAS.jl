@recipe SpecPlot begin end


"""
    specplot(gp, ta)

Plot a spectrogram on a panel
"""
function specplot(gp, ta; axis=(;), add_colorbar=DEFAULTS.add_colorbar, add_title=DEFAULTS.add_title, kwargs...)
    ax = Axis(gp; axis_attributes(ta; add_title)..., axis...)
    plots = specplot!(ax, ta; kwargs...)
    add_colorbar && isspectrogram(ta) && Colorbar(gp[1, 1, Right()], plots; label=clabel(ta))
    PanelAxesPlots(gp, AxisPlots(ax, plots))
end

"""
Plot heatmap of a time series on the same axis
"""
function specplot!(ax::Axis, ta; labels=labels(ta), verbose=true, kwargs...)
    ta = resample(ta; verbose)
    heatmap!(ax, xs(ta), spectrogram_y_values(ta), ta.data; heatmap_attributes(ta; kwargs...)...)
end