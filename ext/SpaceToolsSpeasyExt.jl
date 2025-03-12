module SpaceToolsSpeasyExt

using SpaceTools
using SpaceTools: AbstractDataSet, SpeasyProduct
using Speasy
using Speasy: TimeRangeType
using DimensionalData
import SpaceTools: transform, get_data, axis_attributes

SpaceTools.transform(p::SpeasyVariable; kwargs...) = DimArray(p; kwargs...)
SpaceTools.transform(p::AbstractArray{SpeasyVariable}; kwargs...) = DimArray.(p; kwargs...)

function SpaceTools.get_data(p::SpeasyProduct, args...; kwargs...)
    DimArray(Speasy.get_data(p.id, args...; kwargs...))
end

function Speasy.get_data(p, tr::TimeRange; kwargs...)
    Speasy.get_data(p, tr.first, tr.last; kwargs...)
end

function Speasy.get_data(ds::AbstractDataSet, tr::TimeRangeType; provider="cda", kwargs...)
    products = Speasy.products(ds; provider)
    Speasy.get_data(products, tr; kwargs...)
end

function SpaceTools.axis_attributes(sps::AbstractVector{SpeasyProduct}, tmin, tmax; kwargs...)
    tas = SpaceTools.get_data.(sps, tmin, tmax)
    SpaceTools.axis_attributes(tas; kwargs...)
end

end