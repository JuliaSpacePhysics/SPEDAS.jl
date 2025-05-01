"""
Core functionality for time series plotting.
This file contains the main `tplot` function and its variants.
"""

default_palette(x) = ((i, 1) for i in eachindex(x))

mappable(x) = values(x)
mappable(x::SupportTypes) = (x,)
mappable(x::Product) = (x,)

"""
    tplot(f, tas; legend=(; position=Right()), link_xaxes=true, link_yaxes=false, rowgap=5, transform=transform_pipeline, kwargs...)

Lay out multiple time series across different panels (rows) on one Figure / GridPosition `f`

If `legend` is `nothing`, no legend will be added to the plot. Otherwise, `legend` can be a `NamedTuple` containing options for legend placement and styling.
By default, the time series are transformed via `transform_pipeline`, which is extensible via `transform`.

See also: [`tplot_panel`](@ref), [`transform_pipeline`](@ref), [`transform`](@ref)
"""
function tplot(f::Drawable, tas, args...; legend=(; position=Right()), link_xaxes=true, link_yaxes=false, rowgap=5, transform=transform_pipeline, axis=(;), palette=default_palette(tas), kwargs...)
    gaps = map(palette, mappable(tas)) do pos, ta
        gp = f[pos...]
        pap = tplot_panel(gp, ta, args...; transform, axis, kwargs...)
        # Hide redundant x labels
        link_xaxes && pos != last(palette) && hidexdecorations!.(pap.axis, grid=false)
        pap
    end

    axs = reduce(vcat, getproperty.(gaps, :axis))
    link_xaxes && linkxaxes!(axs...)
    link_yaxes && linkyaxes!(axs...)

    !isnothing(legend) && add_legend!.(gaps; legend...)

    !isnothing(rowgap) && rowgap!(f.layout, rowgap)
    FigureAxes(f, axs)
end

function tplot(ta, args...; figure=(;), kwargs...)
    tas = mappable(ta)
    f = Figure(; size=auto_figure_size(tas), figure...)
    tplot(f, tas, args...; kwargs...)
end

"""
    auto_figure_size(tas)

Calculate an appropriate figure size based on the number of plots in the list.
Returns a tuple of (width, height) in pixels.
"""
function auto_figure_size(tas; base_height=200, min_height=600, width=800)
    n_plots = length(tas)
    height = max(min_height, n_plots * base_height)
    return (width, height)
end

function tplot! end
