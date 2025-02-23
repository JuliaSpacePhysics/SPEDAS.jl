xlabel_sources = (:xlabel, "xlabel")
ylabel_sources = (:ylabel, :long_name, "long_name", :label, "LABLAXIS")
unit_sources = (:unit, :units, "UNITS")
yunit_sources = (:yunit, :units)
scale_sources = (:scale, "scale", "SCALETYP")

meta(ta) = Dict()

format_unit(u::Unitful.Units) = string(u)
format_unit(ta) = ""
format_unit(ta::AbstractArray{Q}) where {Q<:Quantity} = string(unit(Q))
format_unit(ta::AbstractDimArray{Q}) where {Q<:Real} = prioritized_get(ta, unit_sources, "")

xlabel(ta) = ""
xlabel(da::AbstractDimArray) = prioritized_get(da.metadata, xlabel_sources, DD.label(dims(da, 1)))

ylabel(ta) = ""
function ylabel(da::AbstractDimArray)
    default_name = isspectrogram(da) ? DD.label(dims(da, 2)) : DD.label(da)
    name = prioritized_get(da, ylabel_sources, default_name)
    units = isspectrogram(da) ? prioritized_get(da, yunit_sources, "") : format_unit(da)
    units == "" ? name : "$name ($units)"
end

function clabel(ta::AbstractDimArray)
    name = get(ta.metadata, "LABLAXIS", DD.label(ta))
    units = format_unit(ta)
    units == "" ? name : "$name ($units)"
end

label(ta::AbstractDimArray) = prioritized_get(ta, ylabel_sources, DD.label(ta))
labels(ta::AbstractDimMatrix) = string.(dims(ta, 2).val)

title(ta) = get(meta(ta), "CATDESC", "")

"""Format datetime ticks with time on top and date on bottom."""
format_datetime(dt) = Dates.format(dt, "HH:MM:SS\nyyyy-mm-dd")

function colorrange(da::AbstractDimArray; scale=10)
    cmid = median(da)
    cmax = cmid * scale
    cmin = cmid / scale
    return (cmin, cmax)
end

label_func(labels) = latexify.(labels)

axis_attributes(ta; add_title=false, kwargs...) = (; kwargs...)
"""Axis attributes for a time array"""
function axis_attributes(ta::AbstractDimArray{Q}; add_title=false, kwargs...) where {Q}
    attrs = Attributes(; kwargs...)
    Q <: Quantity && !isspectrogram(ta) && (attrs[:dim2_conversion] = Makie.UnitfulConversion(unit(Q); units_in_label=false))
    s = scale(ta)
    xl = xlabel(ta)
    yl = ylabel(ta)
    if !isspectrogram(ta)
        isnothing(s) || (attrs[:yscale] = s)
    end
    isempty(yl) || (attrs[:ylabel] = yl)
    isempty(xl) || (attrs[:xlabel] = xl)
    add_title && (attrs[:title] = title(ta))
    attrs
end

Unitful.unit(ta::AbstractDimArray{Q}) where {Q} = unit(Q)

"""Set an attribute if all values are equal"""
function set_if_equal!(attrs, key, values; default=first(values))
    val = allequal(values) ? default : nothing
    isnothing(val) || (attrs[key] = val)
end

function axis_attributes(tas::AbstractVector; add_title=false, kwargs...)
    attrs = Attributes(; kwargs...)

    # Handle units
    uts = unit.(tas)
    if allequal(uts)
        attrs[:dim2_conversion] = Makie.UnitfulConversion(uts[1]; units_in_label=false)
        # Use unit as ylabel if no common ylabel exists
        yls = ylabel.(tas)
        attrs[:ylabel] = allequal(yls) ? yls[1] : format_unit(uts[1])
    end

    # Set common attributes
    set_if_equal!(attrs, :xlabel, xlabel.(tas))
    set_if_equal!(attrs, :yscale, scale.(tas))
    add_title && set_if_equal!(attrs, :title, title.(tas))

    attrs
end

function heatmap_attributes(ta; kwargs...)
    attrs = Attributes(; kwargs...)
    s = scale(ta)
    isnothing(s) || (attrs[:colorscale] = s)
    attrs
end

"""Plot attributes for a time array (axis + labels)"""
function plot_attributes(ta::AbstractDimArray; add_title=false, axis=(;))
    attrs = Attributes()
    attrs[:axis] = axis_attributes(ta; add_title, axis...)

    # handle spectrogram
    if !isspectrogram(ta)
        if ndims(ta) == 2
            attrs[:labels] = labels(ta)
        else
            attrs[:label] = label(ta)
        end
    else
        merge!(attrs, heatmap_attributes(ta))
    end
    attrs
end

plot_attributes(ta; add_title=false) = Attributes(; axis=axis_attributes(ta; add_title))
plot_attributes(f::Function, args...; kwargs...) = plot_attributes(f(args...); kwargs...)

"""
Only add legend when the axis contains multiple labels
"""
function add_legend!(gp, ax; min=2, position=Right(), kwargs...)
    plots, labels = Makie.get_labeled_plots(ax; merge=false, unique=false)
    length(plots) < min && return
    Legend(gp[1, 1, position], ax; kwargs...)
end

function scale(x::String)
    if x == "linear"
        identity
    elseif x == "log10" || x == "log"
        log10
    end
end

scale(f::Function) = f
scale(::Nothing) = nothing

function scale(x)
    m = meta(x)
    isnothing(m) ? nothing : scale(prioritized_get(m, scale_sources, nothing))
end

axes(ta) = ta.metadata["axes"]

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
        c = b.parent[b.span.rows, b.span.cols]
        # p = x.layoutobservables.computedbbox[].origin .* [1, -1]
        return c
    end
    add_labels!(layouts; kwargs...)
end