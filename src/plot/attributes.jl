import ..SPEDAS: xlabel, ylabel, title, format_unit, isspectrogram
import ..SPEDAS: scale, yscale, colorrange
import SpaceDataModel: NoMetadata

uunit(x) = unit(x)
uunit(::String) = nothing
uunit(x::AbstractArray{Q}) where {Q <: Number} = unit(Q)

"""Format datetime ticks with time on top and date on bottom."""
format_datetime(dt) = Dates.format(dt, "HH:MM:SS\nyyyy-mm-dd")

label_func(labels) = latexify.(labels)

filterkeys(f, d::Dict) = filter(f ∘ first, d)
filterkeys(f, nt) = NamedTuple{filter(f, keys(nt))}(nt)
filter_by_fieldnames(T::Type, d::Dict) = filterkeys(∈(fieldnames(T)), d)

filterkeys(f, ::NoMetadata) = Dict()
filter_by_fieldnames(T::Type, ::NoMetadata) = Dict()


function set_axis_attributes!(attrs, x; add_title = false)
    set_if_valid!(attrs,
        :xlabel => xlabel(x),
        :yscale => yscale(x), :ylabel => ylabel(x)
    )
    add_title && (attrs[:title] = title(x))
    return attrs
end

function _axis_attributes(::Type{LinesPlot}, ta; add_title = false, kwargs...)
    attrs = Dict()
    attrs[:yunit] = uunit(ta)
    set_axis_attributes!(attrs, ta; add_title)
    return merge!(attrs, kwargs)
end

function _axis_attributes(::Type{SpecPlot}, ta; add_title = false, kwargs...)
    attrs = Dict()
    y_values = spectrogram_y_values(ta)
    attrs[:yunit] = uunit(y_values)
    set_axis_attributes!(attrs, ta; add_title)
    return merge!(attrs, kwargs)
end


function _axis_attributes(::Type{FunctionPlot}, f, args...; data = nothing, kw...)
    data = @something data apply(f, args...)
    return merge!(
        _axis_attributes(plottype(data), data; kw...),
        filter_by_fieldnames(Axis, meta(f)),
    )
end

function _axis_attributes(::Type{MultiPlot}, fs, args...; kw...)
    attr_dicts = _axis_attributes.(plottype.(fs), fs, args...; kw...)
    return merge!(
        intersect_dicts(attr_dicts),
        filter_by_fieldnames(Axis, meta(fs)),
    )
end

# Process axis attributes before makie
function process_axis_attributes!(attrs)
    yunit = get(attrs, :yunit, nothing)
    if !isnothing(yunit) && yunit != Unitful.NoUnits
        attrs[:dim2_conversion] = Makie.UnitfulConversion(yunit; units_in_label = false)
        # Use unit as ylabel if no ylabel exists
        haskey(attrs, :ylabel) || (attrs[:ylabel] = format_unit(yunit))
    end
    delete!(attrs, :yunit)
    return attrs
end


function axis_attributes(fs, args...; kw...)
    return process_axis_attributes!(
        _axis_attributes(plottype(fs), fs, args...; kw...)
    )
end

function heatmap_attributes(ta; kwargs...)
    attrs = Attributes(; kwargs...)
    set_if_valid!(
        attrs,
        :colorscale => scale(ta), :colorrange => colorrange(ta)
    )
    return attrs
end

function plottype_attributes(meta; allowed = (:labels, :label))
    return filterkeys(∈(allowed), meta)
end

plot_attributes(ta; add_title = false) = Attributes(; axis = axis_attributes(ta; add_title))
plot_attributes(f::Function, args...; kwargs...) = plot_attributes(f(args...); kwargs...)

axes(ta) = meta(ta)["axes"]
