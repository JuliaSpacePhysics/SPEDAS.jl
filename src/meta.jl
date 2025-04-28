const xlabel_sources = (:xlabel, "xlabel")
const ylabel_sources = (:ylabel, :long_name, "long_name", :label, "LABLAXIS")
const labels_sources = (:labels, "labels", "LABL_PTR_1", "LABLAXIS")
const scale_sources = (:scale, "scale", "SCALETYP")
const unit_sources = (:unit, :units, "UNITS")
const yunit_sources = (:yunit, :units)
const colorrange_sources = (:colorrange, :z_range, "z_range")
const title_sources = (:title, "CATDESC")

function ulabel(l, u; multiline=false)
    multiline ? "$(l)\n($(u))" : "$(l) ($(u))"
end
ulabel(l, u::String) = ulabel(l, uparse(u))

format_unit(ta) = prioritized_get(meta(ta), unit_sources, "")
format_unit(ta::AbstractArray{Q}) where {Q<:Quantity} = string(unit(Q))

title(ta, default="") = prioritized_get(meta(ta), title_sources, default)
title(ds::AbstractDataSet) = title(ds, ds.name)

xvalues(ta) = times(ta)
xlabel(ta) = ""
xlabel(da::AbstractDimArray) = prioritized_get(meta(da), xlabel_sources, DD.label(dims(da, 1)))
ylabel(ta) = ""
ylabel(x::AbstractVector) = format_unit(x)
function ylabel(da::AbstractDimArray; multiline=true)
    default_name = isspectrogram(da) ? DD.label(dims(da, 2)) : DD.label(da)
    name = prioritized_get(meta(da), ylabel_sources, default_name)
    units = isspectrogram(da) ? prioritized_get(meta(da), yunit_sources, "") : format_unit(da)
    units == "" ? name : ulabel(name, units; multiline)
end

function clabel(ta::AbstractDimArray; multiline=true)
    name = get(ta.metadata, "LABLAXIS", DD.label(ta))
    units = format_unit(ta)
    units == "" ? name : (multiline ? "$name\n($units)" : "$name ($units)")
end

function colorrange(da; scale=10)
    cmid = nanmedian(da)
    cmax = cmid * scale
    cmin = cmid / scale
    return (cmin, cmax)
end

label(ta) = prioritized_get(meta(ta), ylabel_sources, DD.label(ta))
function labels(ta)
    lbls = prioritized_get(meta(ta), labels_sources, string.(dims(ta, 2).val))
    vectorize(lbls)
end

set_colorrange(x, range) = modify_meta(x; colorrange=range)
set_colorrange(x; kwargs...) = set_colorrange(x, colorrange(x; kwargs...))

function isspectrogram(ta::AbstractDimArray; threshold=5)
    m = prioritized_get(meta(ta), ("DISPLAY_TYPE", :DISPLAY_TYPE), nothing)
    if isnothing(m)
        size(ta, 2) >= threshold
    else
        m == "spectrogram"
    end
end
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
function scale(x::AbstractArray; sources=scale_sources)
    m = meta(x)
    isnothing(m) ? nothing : scale(prioritized_get(m, sources, nothing))
end

function yscale(x)
    !isspectrogram(x) ? scale(x) : scale(x; sources=(:yscale,))
end