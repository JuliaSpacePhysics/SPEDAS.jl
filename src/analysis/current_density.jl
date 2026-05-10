"""
    current_density(B, V)

Calculate the current density time series from magnetic field (B) and plasma velocity (V) time series.

Assume 1-D structure along the z-direction. Remember to transform the coordinates of B and V first (e.g. using [`mva`](@ref)
"""
function current_density(B, V)
    μ0 = 4π * 1.0e-7
    return _current_density(B, V) do dBdt, Vz
        @. dBdt / (μ0 * Vz)
    end
end

function _current_density(f, B, V)
    _B_in, _V_in = tviews(B, V)
    ts = times(_B_in)

    Bx = parent(_B_in)[:, 1]
    By = parent(_B_in)[:, 2]
    dBxdt = tderiv(Bx, ts)
    dBydt = tderiv(By, ts)
    Vz = tinterp(_V_in[:, 3], ts[1:(end - 1)])

    Jx = f(dBydt, Vz)
    Jy = f(-dBxdt, Vz)

    @views begin
        B_in = _B_in[1:(end - 1), :]
        Bx = B_in[:, 1]
        By = B_in[:, 2]
        Bmag = norm.(eachrow(B_in))
        Jpara = @. (Jx * Bx + Jy * By) / Bmag
        Jperp = @. (Jy * Bx - Jx * By) / Bmag
    end
    return (; Jx, Jy, Jpara, Jperp)
end
