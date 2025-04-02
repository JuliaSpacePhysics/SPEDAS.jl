"""Set an attribute if all values are equal and non-empty"""
function set_if_equal!(attrs, key, values; default=nothing)
    val = allequal(values) ? first(values) : default
    isnothing(val) || val == "" || (attrs[key] = val)
end

meta(ta) = Dict()
meta(ds::AbstractDataSet) = ds.metadata
meta(p::Product) = p.metadata

uunit(x) = unit(x)
uunit(::String) = nothing
uunit(x::AbstractArray{Q}) where {Q<:Number} = unit(Q)
format_unit(u::Unitful.Units) = string(u)
format_unit(ta) = ""
format_unit(ta::AbstractArray{Q}) where {Q<:Quantity} = string(unit(Q))
format_unit(ta::AbstractDimArray{Q}) where {Q<:Real} = prioritized_get(ta, unit_sources, "")

title(ta) = prioritized_get(ta, title_sources, "")
title(ds::AbstractDataSet) = ds.name

"""Format datetime ticks with time on top and date on bottom."""
format_datetime(dt) = Dates.format(dt, "HH:MM:SS\nyyyy-mm-dd")

function colorrange(da::AbstractDimArray; scale=10)
    cmid = NaNMath.median(da)
    cmax = cmid * scale
    cmin = cmid / scale
    return (cmin, cmax)
end

label_func(labels) = latexify.(labels)

axis_attributes(ta, args...; add_title=false, kwargs...) = (; kwargs...)

filterkeys(f, d::Dict) = filter(f ∘ first, d)
filterkeys(f, nt) = NamedTuple{filter(f, keys(nt))}(nt)

function axis_attributes(meta; allowed=fieldnames(Axis))::Dict
    filterkeys(∈(allowed), meta)
end

"""Axis attributes for a time array"""
function axis_attributes(ta::AbstractArray{Q}; add_title=false, kwargs...) where {Q<:Number}
    attrs = Dict()
    # Note: `u != Unitful.NoUnits` would handle cases where `ta` is a array of mixed units
    u = uunit(ta)

    if !isspectrogram(ta)
        Q <: Quantity && u != Unitful.NoUnits &&
            (attrs[:dim2_conversion] = Makie.UnitfulConversion(u; units_in_label=false))
    else
        y_values = spectrogram_y_values(ta)
        yunit = uunit(y_values)
        if yunit != Unitful.NoUnits
            attrs[:dim2_conversion] = Makie.UnitfulConversion(yunit; units_in_label=false)
        end
    end

    s = yscale(ta)
    xl = xlabel(ta)
    yl = ylabel(ta)
    isnothing(s) || (attrs[:yscale] = s)
    isempty(yl) || (attrs[:ylabel] = yl)
    isempty(xl) || (attrs[:xlabel] = xl)
    add_title && (attrs[:title] = title(ta))
    merge(attrs, kwargs)
end

function axis_attributes(tas::Union{AbstractArray,Tuple}; add_title=false, kwargs...)
    attrs = Attributes(; kwargs...)

    # Handle units
    uts = uunit.(tas)
    if allequal(uts) && uts[1] != Unitful.NoUnits && !isnothing(uts[1])
        attrs[:dim2_conversion] = Makie.UnitfulConversion(uts[1]; units_in_label=false)
        # Use unit as ylabel if no common ylabel exists
        set_if_equal!(attrs, :ylabel, ylabel.(tas); default=format_unit(uts[1]))
    end

    # Set common attributes
    set_if_equal!(attrs, :xlabel, xlabel.(tas))
    set_if_equal!(attrs, :yscale, scale.(tas))
    add_title && set_if_equal!(attrs, :title, title.(tas))

    attrs
end

function axis_attributes(ds::DataSet; add_title=false, kwargs...)
    attrs = Attributes(; kwargs...)
    add_title && (attrs[:title] = title(ds))
    attrs
end

apply(f, args...) = f(args...)

function axis_attributes(fs, tmin, tmax; kwargs...)
    data = apply.(fs, tmin, tmax)
    axis_attributes(data; kwargs...)
end

function heatmap_attributes(ta; kwargs...)
    attrs = Attributes(; kwargs...)
    s = scale(ta)
    m = meta(ta)
    cr = prioritized_get(m, colorrange_sources)
    isnothing(s) || (attrs[:colorscale] = s)
    isnothing(cr) || (attrs[:colorrange] = cr)
    attrs
end

function plottype_attributes(meta; allowed=(:labels,))
    filterkeys(∈(allowed), meta)
end

"""Plot attributes for a time array (labels)"""
function plottype_attributes(ta::AbstractDimArray)
    attrs = Attributes()
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

"""Plot attributes for a time array (axis + labels)"""
function plot_attributes(ta::AbstractDimArray; add_title=false, axis=(;))
    attrs = plottype_attributes(ta)
    attrs[:axis] = axis_attributes(ta; add_title, axis...)
    attrs
end

plot_attributes(ta; add_title=false) = Attributes(; axis=axis_attributes(ta; add_title))
plot_attributes(f::Function, args...; kwargs...) = plot_attributes(f(args...); kwargs...)

axes(ta) = ta.metadata["axes"]

# TODO: implement tspan!
function tspan! end
# tspan!(ax, tmin, tmax; alpha=0.618, linestyle=:dash, kwargs...) = vspan!(ax, ([tmin]), ([tmax]); alpha, linestyle, kwargs...)