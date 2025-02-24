"""
    lingradest(B1, B2, B3, B4, R1, R2, R3, R4)

Compute spatial derivatives such as grad, div, curl and curvature using reciprocal vector technique (linear interpolation).

# Arguments
- `B1, B2, B3, B4`: 3-element vectors giving magnetic field measurements at each probe
- `R1, R2, R3, R4`: 3-element vectors giving the probe positions

# Returns
A named tuple containing:
  • Rbary: Barycenter position
  • Bbc: Magnetic field at the barycenter
  • Bmag: Magnetic field magnitude at the barycenter
  • LGBx, LGBy, LGBz: Linear gradient estimators for each component
  • LD: Linear divergence estimator
  • LCB: Linear curl estimator
  • curvature: Field‐line curvature vector
  • R_c: Field‐line curvature radius

# References
Based on the method of Chanteur (ISSI, 1998, Ch. 11).
- [lingradest.pro](https://github.com/spedas/bleeding_edge/blob/master/projects/mms/common/curlometer/lingradest.pro)
- [lingradest.py](https://github.com/spedas/pyspedas/blob/master/pyspedas/analysis/lingradest.py#L5)
"""
function lingradest(B1, B2, B3, B4, R1, R2, R3, R4)

    Rs = [R1, R2, R3, R4]
    Bs = [B1, B2, B3, B4]
    Bxs = getindex.(Bs, 1)
    Bys = getindex.(Bs, 2)
    Bzs = getindex.(Bs, 3)

    # Barycenter of the tetrahedron
    Rbary = (R1 .+ R2 .+ R3 .+ R4) ./ 4
    dRs = Ref(Rbary) .- Rs

    # Reciprocal vectors and μ factors
    ks = reciprocal_vectors(R1, R2, R3, R4)
    μs = @. 1 + dot(ks, dRs)

    # Magnetic field at barycenter
    Bbc = sum(μs .* Bs)
    Bmag = norm(Bbc)

    # Linear Gradient estimators
    LGBx = sum(Bxs .* ks)
    LGBy = sum(Bys .* ks)
    LGBz = sum(Bzs .* ks)
    LGB = [LGBx LGBy LGBz]
    # Linear Divergence estimator
    div = sum(dot.(ks, Bs))

    # Linear Curl estimator
    curl = sum(cross.(ks, Bs))
    # Field-line curvature components
    curvature = (LGB' * Bbc) / (Bmag^2)
    R_c = 1 / norm(curvature)

    return (; Rbary, Bbc, Bmag,
        LGBx, LGBy, LGBz,
        div, curl, curvature, R_c)
end

"""
    lingradest(B1::MatrixLike, args...)

Vectorized method for simplified usage. Returns a `StructArray` containing the results.
"""
function lingradest(B1::MatrixLike, args...)
    n = only(setdiff(size(B1), 3))
    B1 = ensure_nxm(B1, 3, n)
    args = ensure_nxm.(args, 3, n)
    lingradest.(eachcol(B1), eachcol.(args)...) |> StructArray
end

"""
    lingradest(B1::AbstractDimArray, args...)

Method for handling dimensional arrays. Takes `AbstractDimArray` inputs with a time dimension
and returns a `DimStack` containing all computed quantities.
"""
function lingradest(B1::AbstractDimArray, args...)
    time = dims(B1, Ti)
    out = lingradest(parent(B1), parent.(args)...)
    das = map(propertynames(out)) do p
        DimArray(getproperty(out, p), time; name=p)
    end
    DimStack(das...)
end


"""
    lingradest(
        Bx1, Bx2, Bx3, Bx4,
        By1, By2, By3, By4,
        Bz1, Bz2, Bz3, Bz4,
        R1, R2, R3, R4
    )

SPEDAS-argument-compatible version of lingradest.
"""
function lingradest(
    Bx1, Bx2, Bx3, Bx4,
    By1, By2, By3, By4,
    Bz1, Bz2, Bz3, Bz4,
    R1, R2, R3, R4
)
    # Construct magnetic field vectors
    B1 = hcat(Bx1, By1, Bz1)
    B2 = hcat(Bx2, By2, Bz2)
    B3 = hcat(Bx3, By3, Bz3)
    B4 = hcat(Bx4, By4, Bz4)

    lingradest(B1, B2, B3, B4, R1, R2, R3, R4)
end