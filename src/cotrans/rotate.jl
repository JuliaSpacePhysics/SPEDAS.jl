function rotate(ts::AbstractMatrix, mat::AbstractMatrix)
    ts * mat
end

function rotate(da::AbstractDimArray, mats::AbstractVector)
    da = da[DimSelectors(mats)]
    da_rot = @d mats .* eachslice(da, dims=Ti) # hcat on `OffsetArray` doesn't work
    da_rot = mats .* eachrow(da.data)
    TS(dims(da, Ti), dims(da, 2), hcat(da_rot...)')
end