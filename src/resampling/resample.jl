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
    tresample(da, n; dim = nothing, query=nothing)

Resample a dimensioned array along its time dimension (or `dim`/`query`) to `n` points.
"""
function tresample(da, n; dim = nothing, query=nothing)
    dim = @something dim dimnum(da, query)
    resample(da, n; dim)
end