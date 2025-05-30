check_year(year) =
    if year > 2025 || year < 1900
        error("IGRF-14 coefficients are not available for year $year")
    end

"""
    get_igrf_coeffs(time)

Get IGRF-14 coefficients for a given time.

Similar to [IRBEM](https://github.com/PRBEM/IRBEM/blob/main/source/igrf_coef.f) implementation,
but with higher precision (IRBEM uses `year` as the time unit).
"""
function get_igrf_coeffs(time)
    # Convert time to year and day of year
    dt = time isa Date ? time : Date(time)
    year0 = year(dt) ÷ 5 * 5
    check_year(year0)
    t0, tf = Date(year0), Date(year0 + 5)
    ratio = (dt - t0) / (tf - t0)
    g0, h0, dg, dh = @inbounds igrf_lookup[year0]
    g = @~ dg * ratio + g0
    h = @~ dh * ratio + h0
    return g, h
end

"""
    get_dipole_terms(g, h)

Compute dipole parameters (θ, φ, x0, y0, z0, b0) from IGRF coefficients.

Returns a named tuple: (θ, φ, x0, y0, z0, b0)
"""
function get_dipole_terms(g, h)
    # Extract coefficients
    g10, g11, g20, g21, g22 = g[2:6]
    h11, _, h21, h22 = h[3:6]

    θ, φ, b0 = get_dipole_angle(g10, g11, h11)
    b02 = b0^2

    l0 = 2g10 * g20 + √3(g11 * g21 + h11 * h21)
    l1 = -g11 * g20 + √3(g10 * g21 + g11 * g22 + h11 * h22)
    l2 = -h11 * g20 + √3(g10 * h21 - h11 * g22 + g11 * h22)
    e = (l0 * g10 + l1 * g11 + l2 * h11) / (4b02)

    z0 = (l0 - g10 * e) / (3b02)
    x0 = (l1 - g11 * e) / (3b02)
    y0 = (l2 - h11 * e) / (3b02)

    return (; θ, φ, x0, y0, z0, b0)
end

"""
    calc_dipole_angle(g10, g11, h11)

Calculate dipole angle (θ, φ, b0) given spherical harmonic coefficients `g10`, `g11`, `h11`.

θ: dipole tilt angle (radians)
φ: dipole longitude/phase (radians)
b0: dipole strength (nT)
"""
@inline function calc_dipole_angle(g10, g11, h11)
    b0 = sqrt(g10^2 + g11^2 + h11^2)
    θ = acos(-g10 / b0)
    φ = atan(h11 / g11)
    return θ, φ, b0
end
