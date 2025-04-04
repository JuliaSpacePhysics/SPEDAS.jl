module SPEDASSpeasyExt

using SPEDAS
using SPEDAS: AbstractDataSet
using Speasy
using Speasy: TimeRangeType
using DimensionalData
import SPEDAS: transform, get_data, axis_attributes, SpeasyProduct, transform_speasy

contain_provider(s::String) = length(split(s, "/")) == 3

function SPEDAS.SpeasyProduct(id, metadata=Dict(); provider="cda", kwargs...)
    id = contain_provider(id) ? id : "$provider/$id"
    Product(;
        name=id,
        transformation=DimArray ∘ Speasy.get_data,
        data=id,
        metadata,
        kwargs...
    )
end

SPEDAS.transform_speasy(x::String) = SpeasyProduct(x)
SPEDAS.transform_speasy(x::AbstractArray{String}) = map(SpeasyProduct, x)
SPEDAS.transform_speasy(x::NTuple{N,String}) where {N} = map(SpeasyProduct, x)
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