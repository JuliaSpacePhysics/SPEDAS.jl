# https://docs.sciml.ai/DataInterpolations/stable
# https://github.com/brendanjohnharris/TimeseriesTools.jl/blob/main/ext/DataInterpolationsExt.jl
# https://github.com/JuliaMath/Interpolations.jl
# https://github.com/rafaqz/DimensionalData.jl/pull/609
using DataInterpolations

"""
    tinterp(A, t; interp=LinearInterpolation)

Interpolate time series `A` at time point(s) `t`.
Returns interpolated value for single time point or DimArray for multiple time points.
"""
tinterp(A, t; interp=LinearInterpolation) = _tinterp(A, t; interp)

"""
    tinterp(A, B; interp=LinearInterpolation)

Interpolate `A` to times in `B`
"""
tinterp(A, B::AbstractDimArray; kwargs...) = _tinterp(A, dims(B, Ti); kwargs...)

function _tinterp(A::T, t; interp=LinearInterpolation) where {T<:AbstractDimVector}
    u = stack(A.data) # necessary as no method matching zero(::Type{Vector{}})
    out = interp(u, t2x.(dims(A, Ti)))(t2x.(t))
    t isa DateTime && return out
    data = eachcol(out)
    return DimArray(data, tdim(t); name=A.name, metadata=A.metadata)
end

function _tinterp(A::T, t; interp=LinearInterpolation) where {T<:AbstractDimMatrix}
    u = permutedims(A.data)
    out = interp(u, t2x.(dims(A, Ti)))(t2x.(t))
    t isa DateTime && return out
    data = permutedims(out)
    newdims = (tdim(t), otherdims(A, Ti)...)
    return DimArray(data, newdims; name=A.name, metadata=A.metadata)
end