# Minimum variance analysis
# References:
# - https://github.com/henry2004y/VisAnaJulia/blob/master/src/MVA.jl
# - https://pyspedas.readthedocs.io/en/latest/coords.html#pyspedas.minvar

"""
    mva_mat(Bx, By, Bz; verbose=false)

Generates a LMN coordinate transformation matrix from 3 orthogonal vectors `Bx`, `By`, `Bz`.

Perform minimum variance analysis to vector components defined in orthogonal coordinates `Bx`, `By` and `Bz`.
Set `check=true` to check the reliability of the result.

The `k`th eigenvector can be obtained from the slice `F.vectors[:, k]`.
"""
function mva_mat(Bx, By, Bz; check=false)

    B̄1 = mean(Bx)
    B̄2 = mean(By)
    B̄3 = mean(Bz)
    B̄11 = mean(Bx .* Bx) - B̄1 * B̄1
    B̄22 = mean(By .* By) - B̄2 * B̄2
    B̄33 = mean(Bz .* Bz) - B̄3 * B̄3
    B̄12 = mean(Bx .* By) - B̄1 * B̄2
    B̄23 = mean(By .* Bz) - B̄2 * B̄3
    B̄31 = mean(Bz .* Bx) - B̄3 * B̄1
    # Construct the matrix
    M = [B̄11 B̄12 B̄31; B̄12 B̄22 B̄23; B̄31 B̄23 B̄33]

    # Compute the eigen values and ratios (descending order)
    F = eigen(M, sortby=x -> -abs(x))

    check && check_mva(F)
    F
end

mva_mat(B::AbstractMatrix; kwargs...) = mva_mat(eachcol(B)...; kwargs...)
mva_mat(B::AbstractMatrix{Q}; kwargs...) where {Q<:Quantity} = mva_mat(ustrip(B); kwargs...)

"""
    mva(V::AbstractMatrix, B::AbstractMatrix; kwargs...)

Rotate a timeseries `V` into the LMN coordinates based on the reference field `B`.

# Arguments
- `V::AbstractMatrix`: The timeseries data to be transformed, where each column represents a component
- `B::AbstractMatrix`: The reference field used to determine the minimum variance directions, where each column represents a component

See also: [`mva(Bx, By, Bz)`](@ref), [`rotate`](@ref)
"""
function mva(V::AbstractMatrix, B::AbstractMatrix; kwargs...)
    F = mva_mat(B; kwargs...)
    rotate(V, F.vectors)
end

function mva(V::AbstractDimArray, B::AbstractDimArray; new_dim=B_LMN, kwargs...)
    V_mva = mva(V, B.data)
    old_dim = otherdims(V_mva, (Ti, 𝑡))[1]
    set(V_mva, old_dim => new_dim)
end

"""
    check_mva_mat(F; r=5, verbose=false)

Check the quality of the MVA result. 

If λ₁ ≥ λ₂ ≥ λ₃ are 3 eigenvalues of the constructed matrix M, then a good
indicator of nice fitting LMN coordinate system should have λ₂ / λ₃ > r.
"""
function check_mva_mat(F; r=5, verbose=false)
    verbose && println(F.vectors)
    verbose && println("Ratio of intermediate variance to minimum variance = ", r)
    if F.values[2] / F.values[3] ≥ r
        @info "Seems to be a proper MVA attempt!"
    else
        @warn "Take the MVA result with a grain of salt!"
    end
end

function is_right_handed(v1, v2, v3)
    dot(cross(v1, v2), v3) > 0
end

function is_right_handed(F::Eigen)
    vs = F.vectors
    v1 = vs[:, 1]
    v2 = vs[:, 2]
    v3 = vs[:, 3]
    is_right_handed(v1, v2, v3)
end