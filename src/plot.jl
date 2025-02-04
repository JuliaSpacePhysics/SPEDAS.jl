function colorrange(da::AbstractDimArray; scale=10)
    cmid = median(da)
    cmax = cmid * scale
    cmin = cmid / scale
    return (cmin, cmax)
end

"""
    tsheat(data; kwargs...)

Heatmap with better default attributes for time series.

References:
- https://docs.makie.org/stable/reference/plots/heatmap
"""
function tsheat(da::AbstractDimArray; colorscale=log10, colorrange=colorrange(da), kwargs...)

    fig, ax, hm = heatmap(da; colorscale, colorrange, kwargs...)
    Colorbar(fig[:, end+1], hm)

    # rasterize the heatmap to reduce file size
    if *(size(da)...) > 32^2
        hm.rasterize = true
    end

    fig, ax, hm
end