"""
Core functionality for time series plotting.
This file contains the main `tplot` function and its variants.
"""

default_palette(x) = ((i, 1) for i in 1:length(x))

"""
    tplot(f, tas; legend=(; position=Right()), link_xaxes=true, link_yaxes=false, rowgap=5, transform=transform_pipeline, kwargs...)

Lay out multiple time series across different panels (rows) on one Figure / GridPosition `f`

If `legend` is `nothing`, no legend will be added to the plot. Otherwise, `legend` can be a `NamedTuple` containing options for legend placement and styling.
By default, the time series are transformed via `transform_pipeline`, which is extensible via `transform`.

See also: [`tplot_panel`](@ref), [`transform_pipeline`](@ref), [`transform`](@ref)
"""
function tplot(f::Drawable, tas, args...; legend=(; position=Right()), link_xaxes=true, link_yaxes=false, rowgap=5, transform=transform_pipeline, axis=(;), palette=default_palette(tas), kwargs...)
    tas = transform(tas)
    gaps = map(palette, tas) do pos, ta
        gp = f[pos...]
        pap = tplot_panel(gp, ta, args...; axis, kwargs...)
        # Hide redundant x labels
        link_xaxes && pos[1] != length(tas) && hidexdecorations!.(pap.axis, grid=false)
        pap
    end

    axs = reduce(vcat, getproperty.(gaps, :axis))
    link_xaxes && linkxaxes!(axs...)
    link_yaxes && linkyaxes!(axs...)

    !isnothing(legend) && add_legend!.(gaps; legend...)

    !isnothing(rowgap) && rowgap!(f.layout, rowgap)
    FigureAxes(f, axs)
end

tplot(f::Drawable, ta::SupportTypes, args...; kwargs...) = tplot(f, (ta,), args...; kwargs...)
function tplot(ta, args...; figure=(;), kwargs...)
    tas = ta isa SupportTypes ? (ta,) : ta
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
