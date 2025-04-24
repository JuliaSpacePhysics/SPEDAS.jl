# https://github.com/hapi-server/data-specification/issues/71
# https://github.com/hapi-server/data-specification/issues/83
# bins Object

abstract type AbstractBin end

@kwdef struct CenteredBin{T} <: AbstractBin
    data::T
    name::String
    metadata::Dict
end

@kwdef struct RangedBin <: AbstractBin
    data::T
    name::String
    metadata::Dict
end


function ybins end