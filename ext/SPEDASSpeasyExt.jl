module SPEDASSpeasyExt

using SPEDAS
using SPEDAS: AbstractDataSet, SpeasyProduct
using Speasy
using Speasy: TimeRangeType
using DimensionalData
import SPEDAS: transform, get_data, axis_attributes

SPEDAS.transform(p::SpeasyVariable; kwargs...) = DimArray(p; kwargs...)
SPEDAS.transform(p::AbstractArray{SpeasyVariable}; kwargs...) = DimArray.(p; kwargs...)

function SPEDAS.get_data(p::SpeasyProduct, args...; kwargs...)
    DimArray(Speasy.get_data(p.id, args...; kwargs...))
end

function Speasy.get_data(p, tr::TimeRange; kwargs...)
    Speasy.get_data(p, tr.first, tr.last; kwargs...)
end

function Speasy.get_data(ds::AbstractDataSet, tr::TimeRangeType; provider="cda", kwargs...)
    products = Speasy.products(ds; provider)
    Speasy.get_data(products, tr; kwargs...)
end

function Speasy.get_data(::Type{NamedTuple}, ds::AbstractDataSet, tr::TimeRangeType; provider="cda", kwargs...)
    products = Speasy.products(ds; provider)
    keys = ds.parameters isa Union{Dict,NamedTuple} ? Base.keys(ds.parameters) : nothing
    Speasy.get_data(NamedTuple, products, tr; keys, kwargs...)
end

function SPEDAS.axis_attributes(sps::AbstractVector{SpeasyProduct}, tmin, tmax; kwargs...)
    tas = SPEDAS.get_data.(sps, tmin, tmax)
    SPEDAS.axis_attributes(tas; kwargs...)
end

end