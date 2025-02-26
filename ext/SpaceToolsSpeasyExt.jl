module SpaceToolsSpeasyExt

using SpaceTools
using SpaceTools: SpeasyProduct, DEFAULTS
using Speasy
using DimensionalData
import SpaceTools: xlabel, ylabel

SpaceTools.get_data(p::SpeasyVariable; kwargs...) = DimArray(p; kwargs...)

function SpaceTools.get_data(p::SpeasyProduct, args...; kwargs...)
    DimArray(get_data(p.id, args...; kwargs...))
end

SpaceTools.get_data(p::AbstractString, args...; kwargs...) = DimArray(get_data(p, args...; kwargs...))

SpaceTools.meta(ta::SpeasyVariable) = ta.meta
SpaceTools.ylabel(ta::SpeasyVariable) = ta.meta["LABLAXIS"]

function SpaceTools.axis_attributes(sps::AbstractVector{SpeasyProduct}, tmin, tmax; add_title=DEFAULTS.add_title, kwargs...)
    tas = SpaceTools.get_data.(sps, tmin, tmax; kwargs...)
    SpaceTools.axis_attributes(tas; add_title, kwargs...)
end

end