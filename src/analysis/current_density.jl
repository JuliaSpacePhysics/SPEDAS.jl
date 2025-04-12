using Unitful: μ0

"""
    current_density(B, V)

Calculate the current density time series from the magnetic field (B) and plasma velocity (V) time series.

Assume 1-D structure along the z-direction. Remember to transform the coordinates of B and V first (e.g. using [`mva`](@ref)
"""
@views function current_density(B, V)
    _B_in, _V_in = tviews(B, V)
    ts = times(_B_in)

    dBdt = tderiv(parent(_B_in), ts)
    dBxdt = dBdt[:, 1]
    dBydt = dBdt[:, 2]
    Vz = tinterp(_V_in[:, 3], ts[1:end-1])

    Jx = @. upreferred(dBydt / (μ0 * Vz))
    Jy = @. upreferred(-dBxdt / (μ0 * Vz))

    B_in = _B_in[1:end-1, :]
    Bx = B_in[:, 1]
    By = B_in[:, 2]
    Bmag = norm.(eachrow(B_in))
    Jpara = @. (Jx * Bx + Jy * By) / Bmag
    Jperp = @. (Jy * Bx - Jx * By) / Bmag
    return (; Jx, Jy, Jpara, Jperp)
end