module SpeasyExt

using SpaceTools
using Speasy
using DimensionalData
import SpaceTools: xlabel, ylabel

SpaceTools.get_data(p::SpeasyVariable; kwargs...) = DimArray(p; kwargs...)

function SpaceTools.get_data(p::AbstractString, args...; kwargs...)
    DimArray(get_data(p, args...; kwargs...))
end


SpaceTools.meta(ta::SpeasyVariable) = ta.meta
SpaceTools.ylabel(ta::SpeasyVariable) = ta.meta["LABLAXIS"]

end