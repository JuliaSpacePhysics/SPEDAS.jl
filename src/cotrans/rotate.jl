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

rotate(ts::AbstractMatrix, mat::Eigen) = rotate(ts, mat.vectors)

function rotate(da::AbstractDimArray, mats::AbstractVector)
    da = da[DimSelectors(mats)]
    da_rot = @d mats .* eachslice(da, dims=Ti) # hcat on `OffsetArray` doesn't work
    da_rot = mats .* eachrow(da.data)
    data = hcat(da_rot...)'
    DimArray(data, dims(da); name=da.name, metadata=da.metadata)
end

function select_rotate(da::AbstractDimArray, mats::AbstractVector; selectors=Near())
    all_mats = mats[DimSelectors(da; selectors)]
    da_rot = map(eachrow(parent(da)), all_mats) do row, mat
        mat * row
    end
    data = stack(da_rot; dims=1)
    DimArray(data, dims(da); name=da.name, metadata=da.metadata)
end

select_rotate(da, mats, coord; kwargs...) =
    select_rotate(da, mats; kwargs...) |> set_coord(coord)