module HAPIClientExt

using SPEDAS
using HAPIClient
using DimensionalData
import SPEDAS: xlabel

SPEDAS.get_data(x::HAPIVariable; kwargs...) = DimArray(x; kwargs...)
SPEDAS.meta(x::HAPIVariable) = x.meta

end