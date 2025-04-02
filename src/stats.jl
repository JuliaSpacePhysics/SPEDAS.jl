# work around that NaNMath.median only supports `AbstractArray{<:AbstractFloat}` type
_median(data) = NaNMath.median(data)

function _median(data::AbstractArray{Q}) where {Q<:Quantity}
    return _median(ustrip(data)) * unit(Q)
end