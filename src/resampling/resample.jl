"""
    resample(arr, n; dim=1, verbose=false)

Resample an array along the dimension `dim` to `n` points.
If the original length is less than or equal to `n`, the original array is returned unchanged.
"""
function resample(arr, n; dim=1, verbose=false)
    sz = size(arr, dim)
    if sz > n
        # verbose && @info "Resampling array of size $(size(arr)) along dimension $dim from $sz to $n points"
        verbose && @info "Resampling $(summary(arr)) along dimension $dim from $sz to $n points"
        indices = round.(Int, range(1, sz, length=n))
        selectdim(arr, dim, indices)
    else
        arr
    end
end

"""
    tresample(da::DimArray, n; dim = nothing, query=nothing)

Resample a DimArray specifically along its dimension `dim` or `query` to `n` points.
Throws an error if no dimension of type `dimtype` is found in the array.
"""
function tresample(da::DimArray, n; dim = nothing, query=nothing)
    dim = @something dim dimnum(da, something(query, TimeDim))
    resample(da, n; dim)
end