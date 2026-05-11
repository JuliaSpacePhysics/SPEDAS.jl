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

"""
    rotate(da, mats)

Rotate a dimensioned array using a vector of rotation matrices aligned to its time axis.
Requires DimensionalData to be loaded.
"""
function rotate end

"""
    select_rotate(da, mats; selectors=Near())
    select_rotate(da, mats, coord; kwargs...)

Rotate a dimensioned array using nearest-neighbor matched rotation matrices.
Requires DimensionalData to be loaded.
"""
function select_rotate end

select_rotate(da, mats, coord; kwargs...) =
    select_rotate(da, mats; kwargs...) |> set_coord(coord)
