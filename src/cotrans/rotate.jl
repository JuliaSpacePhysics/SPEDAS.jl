# References
# - https://github.com/JuliaGeometry/CoordinateTransformations.jl

"""
    rotate(ts::AbstractMatrix, mat::AbstractMatrix)

Coordinate-aware transformation of vector/matrix by rotation matrix(s) `mat(s)`.
Assume `ts` is a matrix of shape (n, 3).
"""
function rotate(ts::AbstractMatrix, mat::AbstractMatrix)
    ts * mat
end

function rotate(da::AbstractDimArray, mats::AbstractVector)
    da = da[DimSelectors(mats)]
    da_rot = @d mats .* eachslice(da, dims=Ti) # hcat on `OffsetArray` doesn't work
    da_rot = mats .* eachrow(da.data)
    data = hcat(da_rot...)'
    DimArray(data, dims(da); name=da.name, metadata=da.metadata)
end