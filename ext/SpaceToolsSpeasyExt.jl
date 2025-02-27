module SpaceToolsSpeasyExt

using SpaceTools
using SpaceTools: SpeasyProduct
using Speasy
using DimensionalData
import SpaceTools: transform, get_data, axis_attributes

SpaceTools.transform(p::SpeasyVariable; kwargs...) = DimArray(p; kwargs...)
SpaceTools.transform(p::AbstractArray{SpeasyVariable}; kwargs...) = DimArray.(p; kwargs...)

function SpaceTools.get_data(p::SpeasyProduct, args...; kwargs...)
    SpaceTools.transform(Speasy.get_data(p.id, args...; kwargs...))
end

function SpaceTools.axis_attributes(sps::AbstractVector{SpeasyProduct}, tmin, tmax; kwargs...)
    tas = SpaceTools.get_data.(sps, tmin, tmax)
    SpaceTools.axis_attributes(tas; kwargs...)
end

end