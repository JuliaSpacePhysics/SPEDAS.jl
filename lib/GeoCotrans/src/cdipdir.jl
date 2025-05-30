"""
    cdipdir(time)

Compute dipole direction in GEO coordinates. [PySPEDAS]

References
- https://pyspedas.readthedocs.io/en/latest/coords.html#pyspedas.cotrans_tools.cotrans_lib.cdipdir
"""
function cdipdir(time)
    # Convert time to year and day of year
    g, h = get_igrf_coeffs(time)

    # Schmidt normalization for spherical harmonic coefficients
    # IGRF model uses Schmidt semi-normalized spherical harmonic coefficients
    s = 1.0
    for i in 2:14
        mn = floor(Int, i * (i - 1) / 2 + 1)
        s = floor(Int, s * (2 * i - 3) / (i - 1))
        g[mn+1] *= s
        h[mn+1] *= s
        g[mn] *= s
        h[mn] *= s
        p = s
        for j in 2:(i-1)
            aa = (j == 2) ? 2.0 : 1.0
            p *= sqrt(aa * (i - j + 1) / (i + j - 2))
            mnn = mn + j - 1
            g[mnn+1] *= p
            h[mnn+1] *= p
            g[mnn] *= p
            h[mnn] *= p
        end
    end

    g10 = -g[2]  # Adjusting for 1-based indexing in Julia
    g11 = g[3]
    h11 = h[3]

    sq = g11^2 + h11^2
    sqq = sqrt(sq)
    sqr = sqrt(g10^2 + sq)
    s10 = -h11 / sqq
    c10 = -g11 / sqq
    st0 = sqq / sqr
    ct0 = g10 / sqr

    return SA[st0*c10, st0*s10, ct0]
end

"""
    calc_dipole_geo(time)

Compute dipole direction in GEO coordinates. [IRBEM]
"""
function calc_dipole_geo(time)
    g, h = get_igrf_coeffs(time)
    θ, φ = @inbounds calc_dipole_angle(g[2], g[3], h[3])
    return SA[sin(θ)*cos(φ), sin(θ)*sin(φ), cos(θ)]
end

calc_dipole_gei(time) = geo2gei_mat(time) * calc_dipole_geo(time)
