module SpaceToolsSpeasyExt

using SpaceTools
using SpaceTools: SpeasyProduct
using Speasy
using DimensionalData
import SpaceTools: transform

SpaceTools.transform(p::SpeasyVariable; kwargs...) = DimArray(p; kwargs...)

function SpaceTools.get_data(p::SpeasyProduct, args...; kwargs...)
    DimArray(get_data(p.id, args...; kwargs...))
end

function SpaceTools.axis_attributes(sps::AbstractVector{SpeasyProduct}, tmin, tmax; kwargs...)
    tas = SpaceTools.get_data.(sps, tmin, tmax)
    SpaceTools.axis_attributes(tas; kwargs...)
end

end