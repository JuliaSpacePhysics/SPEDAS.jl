"""
    transform_data(x)

Transform data for plotting with the following pipeline:
1. Custom transformations (`_transform(x)`)
2. String -> `SpeasyProduct`
3. 2-column matrix -> `DualAxisData`

Define methods for `_transform(x::MyType)` to add custom transformations.
"""
transform_data(x) = x |> _transform |> _transform_speasy |> _transform_matrix

_transform(x) = x
_transform_speasy(x::Union{String,AbstractArray{String}}) = SpeasyProduct.(x)
_transform_speasy(x) = x
_transform_matrix(x::AbstractMatrix) = size(x, 2) == 2 ? DualAxisData(view(x, :, 1), view(x, :, 2)) : x
_transform_matrix(x) = x

"Create and configure a secondary y-axis"
function make_secondary_axis!(gp; color=Makie.wong_colors()[6], kwargs...)
    ax2 = Axis(gp;
        yaxisposition=:right,
        yticklabelcolor=color,
        ylabelcolor=color,
        rightspinecolor=color,
        ytickcolor=color,
        kwargs...
    )
    hidespines!(ax2)
    hidexdecorations!(ax2)
    return ax2
end

function tlims!(ax, tmin, tmax)
    if ax.dim1_conversion[] isa Makie.DateTimeConversion
        xlims!(ax, tmin, tmax)
    else
        xlims!(ax, t2x(tmin), t2x(tmax))
    end
end
tlims!(tmin, tmax) = tlims!(current_axis(), tmin, tmax)

"""Add vertical lines to a plot"""
tlines!(ax, time; kwargs...) = vlines!(ax, t2x.(time); kwargs...)
tlines!(time; kwargs...) = tlines!(current_axis(), time; kwargs...)

"""
Only add legend when the axis contains multiple labels
"""
function add_legend!(gp, ax; min=2, position=Right(), kwargs...)
    plots, labels = Makie.get_labeled_plots(ax; merge=false, unique=false)
    length(plots) < min && return
    Legend(gp[1, 1, position], ax; kwargs...)
end


# TODO: support legend merge for secondary axes
function add_legend!(p::PanelAxesPlots; kwargs...)
    ax = p.axisPlots[1].axis
    add_legend!(p.pos, ax; kwargs...)
end

"""
Add labels to a grid of layouts

# Notes
- See `tag_facet` in `egg` for reference
"""
function add_labels!(layouts; labels='a':'z', open="(", close=")", position=TopLeft(), font=:bold, halign=:left, valign=:bottom, padding=(-5, 0, 5, 0), kwargs...)
    for (label, layout) in zip(labels, layouts)
        tag = open * label * close
        Label(
            layout[1, 1, position], tag;
            font, halign, valign, padding,
            kwargs...
        )
    end
end

"""
Add labels to a figure, automatically searching for blocks to label.

# Notes
- https://github.com/brendanjohnharris/Foresight.jl/blob/main/src/Layouts.jl#L2
"""
function add_labels!(; f=current_figure(), allowedblocks=Union{Axis,Axis3,PolarAxis}, kwargs...)
    axs = filter(x -> x isa allowedblocks, f.content)
    layouts = map(axs) do x
        b = x.layoutobservables.gridcontent[]
        b.parent[b.span.rows, b.span.cols]
    end
    add_labels!(unique(layouts); kwargs...)
end