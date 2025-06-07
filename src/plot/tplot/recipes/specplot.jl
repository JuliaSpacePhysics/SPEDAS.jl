@recipe SpecPlot begin end


"""
    specplot(gp, ta)

Plot a spectrogram on a panel
"""
function specplot(gp, ta; axis = (;), add_colorbar = DEFAULTS.add_colorbar, add_title = DEFAULTS.add_title, kwargs...)
    ax = Axis(gp; axis_attributes(ta; add_title)..., axis...)
    plots = specplot!(ax, ta; kwargs...)
    add_colorbar && isspectrogram(ta) && Colorbar(gp[1, 1, Right()], plots; label = clabel(ta))
    return PanelAxesPlots(gp, AxisPlots(ax, plots))
end

"""
Plot heatmap of a time series on the same axis
"""
function specplot!(ax::Axis, ta; labels = labels(ta), verbose = true, kwargs...)
    ta = resample(ta; verbose)
    return heatmap!(ax, makie_x(ta), spectrogram_y_values(ta), ta.data; heatmap_attributes(ta; kwargs...)...)
end

function plot2spec(::Type{<:SpecPlot}, da; kwargs...)
    x = makie_x(da)
    y = spectrogram_y_values(da)
    attributes = heatmap_attributes(da; kwargs...)
    return S.Heatmap(x, y, parent(da); attributes...)
end
