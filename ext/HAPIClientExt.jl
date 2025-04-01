module HAPIClientExt

using SPEDAS
using HAPIClient
using DimensionalData
import SPEDAS: xlabel
import SPEDAS: transform

SPEDAS.transform(x::HAPIVariable; kwargs...) = DimArray(x; kwargs...)

end