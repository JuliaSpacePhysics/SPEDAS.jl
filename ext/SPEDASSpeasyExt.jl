module SPEDASSpeasyExt

using SPEDAS
using SPEDAS: AbstractDataSet
using Speasy
using Speasy: TimeRangeType
using DimensionalData
import SPEDAS: transform, get_data, axis_attributes, SpeasyProduct

SPEDAS.SpeasyProduct(id::String, metadata=Dict()) = Product(;
    name=id,
    transformation=DimArray ∘ Speasy.get_data,
    data=id,
    metadata
)

SPEDAS.transform(p::SpeasyVariable; kwargs...) = DimArray(p; kwargs...)
SPEDAS.transform(p::AbstractArray{<:SpeasyVariable}; kwargs...) = DimArray.(p; kwargs...)


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

end