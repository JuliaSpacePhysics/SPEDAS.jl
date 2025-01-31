# Minimum variance analysis
# https://github.com/henry2004y/VisAnaJulia/blob/master/src/MVA.jl
# https://pyspedas.readthedocs.io/en/latest/coords.html#pyspedas.minvar

"""
    mva_mat(Bx, By, Bz; verbose=false)

Generates a LMN coordinate transformation matrix from 3 orthogonal vectors `Bx`, `By`, `Bz`.

Perform minimum variance analysis to vector components defined in orthogonal
coordinates `Bx`, `By` and `Bz`.
If λ₁ ≥ λ₂ ≥ λ₃ are 3 eigenvalues of the constructed matrix M, then a good
indicator of nice fitting LMN coordinate system should have λ₂/λ₃ > 5. Set 
`verbose=true` to turn on the check.
"""
function mva_mat(Bx, By, Bz; verbose=false)

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
    verbose && check_mva(F)
    F
end

mva_mat(B::AbstractMatrix; kwargs...) = mva_mat(eachcol(B)...; kwargs...)

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

function mva(V::AbstractDimArray, B::AbstractDimArray; new_dim=LMN([:B_l, :B_m, :B_n]), kwargs...)
    V_mva = invoke(mva, Tuple{AbstractMatrix,AbstractMatrix}, V, B)
    old_dim = otherdims(V_mva, (Ti, 𝑡))[1]
    set(V_mva, old_dim => new_dim)
end

function check_mva(F)
    println(F.vectors)
    r = F.values[2] / F.values[3]
    println("Ratio of intermediate variance to minimum variance = ", r)
    if r ≥ 5
        @info "Seems to be a proper MVA attempt!"
    else
        @warn "Take the MVA result with a grain of salt!"
    end
end