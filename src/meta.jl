labels_sources = (:labels, "labels")

labels(ta::AbstractDimMatrix) = prioritized_get(ta, labels_sources, string.(dims(ta, 2).val))

function yscale(x::AbstractDimArray)
    !isspectrogram(x) ? scale(x) : scale(x; sources=(:yscale,))
end

set_colorrange(x, range) = modify_meta(x; colorrange=range)
set_colorrange(x; kwargs...) = set_colorrange(x, colorrange(x; kwargs...))

isspectrogram(ta::AbstractDimArray) = prioritized_get(ta, ("DISPLAY_TYPE", :DISPLAY_TYPE), nothing) == "spectrogram"
isspectrogram(ta) = false