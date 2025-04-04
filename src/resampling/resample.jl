"""
    resample(arr, n=DEFAULTS.resample; dim=1, verbose=false)

Resample an array along the dimension `dim` to `n` points.
If the original length is less than or equal to `n`, the original array is returned unchanged.
"""
function resample(arr; n=DEFAULTS.resample, dim=1, verbose=false)
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

resample(arr, n; kwargs...) = resample(arr; n, kwargs...)

"""
    tresample(da::DimArray, n=DEFAULTS.resample; dimtype=Ti)

Resample a DimArray specifically along its dimension of type `dimtype` to `n` points.
Throws an error if no dimension of type `dimtype` is found in the array.
"""
function tresample(da::DimArray, n=DEFAULTS.resample; dimtype=Ti)
    time_dim = findfirst(d -> d isa dimtype, dims(da))
    isnothing(time_dim) && throw(ArgumentError("No dimension of type $dimtype found in the input DimArray"))
    resample(da; n, dim=time_dim)
end