"""
    current_density(B, V)

Calculate the current density time series from magnetic field (B) and plasma velocity (V) time series.

Assume 1-D structure along the z-direction. Remember to transform the coordinates of B and V first (e.g. using [`mva`](https://juliaspacephysics.github.io/MinimumVarianceAnalysis.jl/dev/)
"""
function current_density(B, V)
    μ0 = 4π * 1.0e-7
    return _current_density(B, V) do dBdt, Vz
        @. dBdt / (μ0 * Vz)
    end
end

function _current_density(f, B, V)
    B, V = tview.((B, V), Ref(trange(B, V)))
    dBdt = parent(tderiv(B))
    ts = times(B)[1:(end - 1)]
    Vz = parent(tinterp(V, ts))[:, 3]

    Jx = f(dBdt[:, 2], Vz)
    Jy = f(-dBdt[:, 1], Vz)

    @views begin
        B_in = parent(B)[1:(end - 1), :]
        Bx = B_in[:, 1]
        By = B_in[:, 2]
        Bmag = norm.(eachrow(B_in))
        Jpara = @. (Jx * Bx + Jy * By) / Bmag
        Jperp = @. (Jy * Bx - Jx * By) / Bmag
    end
    return (; Jx, Jy, Jpara, Jperp)
end
