import ..SPEDAS: xlabel, ylabel, title, format_unit, isspectrogram
import ..SPEDAS: scale, yscale, colorrange
import SpaceDataModel: NoMetadata

uunit(x) = unit(x)
uunit(::String) = nothing
uunit(x::AbstractArray{Q}) where {Q<:Number} = unit(Q)

"""Format datetime ticks with time on top and date on bottom."""
format_datetime(dt) = Dates.format(dt, "HH:MM:SS\nyyyy-mm-dd")

label_func(labels) = latexify.(labels)

axis_attributes(ta, args...; add_title=false, kwargs...) = (; kwargs...)

filterkeys(f, d::Dict) = filter(f ∘ first, d)
filterkeys(f, nt) = NamedTuple{filter(f, keys(nt))}(nt)
filter_by_fieldnames(T::Type, d::Dict) = filterkeys(∈(fieldnames(T)), d)

filterkeys(f, ::NoMetadata) = Dict()
filter_by_fieldnames(T::Type, ::NoMetadata) = Dict()

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
    set_if_valid!(attrs,
        :xlabel => xlabel(ta),
        :yscale => yscale(ta), :ylabel => ylabel(ta)
    )

    add_title && (attrs[:title] = title(ta))
    merge(attrs, kwargs)
end

function axis_attributes(tas::Union{AbstractArray,Tuple}; add_title=false, kwargs...)
    attrs = Dict()

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

    merge(attrs, kwargs)
end

apply(f, args...) = f(args...)

function axis_attributes(fs, tmin, tmax; kwargs...)
    data = apply.(fs, tmin, tmax)
    merge(
        axis_attributes(data; kwargs...),
        convert(Dict, filter_by_fieldnames(Axis, meta(fs))),
    )
end

function heatmap_attributes(ta; kwargs...)
    attrs = Attributes(; kwargs...)
    set_if_valid!(attrs,
        :colorscale => scale(ta), :colorrange => colorrange(ta)
    )
    attrs
end

function plottype_attributes(meta; allowed=(:labels, :label))
    filterkeys(∈(allowed), meta)
end

plot_attributes(ta; add_title=false) = Attributes(; axis=axis_attributes(ta; add_title))
plot_attributes(f::Function, args...; kwargs...) = plot_attributes(f(args...); kwargs...)

axes(ta) = meta(ta)["axes"]