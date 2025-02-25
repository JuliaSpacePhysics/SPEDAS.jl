module HAPIClientExt

using SpaceTools
using HAPIClient
using DimensionalData
import SpaceTools: xlabel

SpaceTools.get_data(x::HAPIVariable; kwargs...) = DimArray(x; kwargs...)
SpaceTools.meta(x::HAPIVariable) = x.meta

end