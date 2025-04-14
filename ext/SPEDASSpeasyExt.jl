module SPEDASSpeasyExt

using SPEDAS: TimeRange
using Speasy: SpeasyProduct, SpeasyVariable
using DimensionalData: DimArray
import SPEDAS: transform, transform_speasy
import Speasy

transform_speasy(x::String) = SpeasyProduct(x)
transform_speasy(x::AbstractArray{String}) = map(SpeasyProduct, x)
transform_speasy(x::NTuple{N,String}) where {N} = map(SpeasyProduct, x)
transform(p::SpeasyVariable; kwargs...) = DimArray(p; kwargs...)
transform(p::AbstractArray{<:SpeasyVariable}; kwargs...) = DimArray.(p; kwargs...)
Speasy._compat(tr::TimeRange) = [tr.first, tr.last]
end