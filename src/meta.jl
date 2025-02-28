const xlabel_sources = (:xlabel, "xlabel")
const ylabel_sources = (:ylabel, :long_name, "long_name", :label, "LABLAXIS")
const labels_sources = (:labels, "labels")
const scale_sources = (:scale, "scale", "SCALETYP")
const unit_sources = (:unit, :units, "UNITS")
const yunit_sources = (:yunit, :units)

xlabel(ta) = ""
xlabel(da::AbstractDimArray) = prioritized_get(da.metadata, xlabel_sources, DD.label(dims(da, 1)))
ylabel(ta) = ""
ylabel(x::AbstractVector) = format_unit(x)
function ylabel(da::AbstractDimArray; multiline=true)
    default_name = isspectrogram(da) ? DD.label(dims(da, 2)) : DD.label(da)
    name = prioritized_get(da, ylabel_sources, default_name)
    units = isspectrogram(da) ? prioritized_get(da, yunit_sources, "") : format_unit(da)
    units == "" ? name : (multiline ? "$name\n($units)" : "$name ($units)")
end

function clabel(ta::AbstractDimArray)
    name = get(ta.metadata, "LABLAXIS", DD.label(ta))
    units = format_unit(ta)
    units == "" ? name : "$name ($units)"
end

label(ta::AbstractDimArray) = prioritized_get(ta, ylabel_sources, DD.label(ta))
labels(ta::AbstractDimMatrix) = prioritized_get(ta, labels_sources, string.(dims(ta, 2).val))

set_colorrange(x, range) = modify_meta(x; colorrange=range)
set_colorrange(x; kwargs...) = set_colorrange(x, colorrange(x; kwargs...))

isspectrogram(ta::AbstractDimArray) = prioritized_get(ta, ("DISPLAY_TYPE", :DISPLAY_TYPE), nothing) == "spectrogram"
isspectrogram(ta) = false

function scale(x::String)
    if x == "linear"
        identity
    elseif x == "log10" || x == "log"
        log10
    end
end

scale(::Any) = nothing
scale(f::Function) = f
function scale(x::AbstractDimArray; sources=scale_sources)
    m = meta(x)
    isnothing(m) ? nothing : scale(prioritized_get(m, sources, nothing))
end

function yscale(x)
    !isspectrogram(x) ? scale(x) : scale(x; sources=(:yscale,))
end