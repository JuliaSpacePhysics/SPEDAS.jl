"""
    resample(arr, n=10000; dim=1)

Resample an array along the dimension `dim` to `n` points.
If the original length is less than or equal to `n`, the original array is returned unchanged.
"""
function resample(arr, n=10000; dim=1)
    sz = size(arr, dim)
    if sz > n
        indices = round.(Int, range(1, sz, length=n))
        selectdim(arr, dim, indices)
    else
        arr
    end
end

"""
    tresample(da::DimArray, n=10000; dimtype=Ti)

Resample a DimArray specifically along its dimension of type `dimtype` to `n` points.
Throws an error if no dimension of type `dimtype` is found in the array.
"""
function tresample(da::DimArray, n=10000; dimtype=Ti)
    time_dim = findfirst(d -> d isa dimtype, dims(da))
    isnothing(time_dim) && throw(ArgumentError("No dimension of type $dimtype found in the input DimArray"))
    resample(da, n; dim=time_dim)
end