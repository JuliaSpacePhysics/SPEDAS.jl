"""
    gdz2sph(alt, lat, lon)

Convert `(alt [km], lat [deg], lon [deg])` in Geodetic coordinate to Spherical geocentric coordinate.
"""
function gdz2sph(alt, lat, lon)
    θ = (90 - lat)
    st = sind(θ)
    ct = cosd(θ)

    st2 = st * st
    ct2 = ct * ct
    one = EARTH_A2 * st2
    two = EARTH_B2 * ct2
    three = one + two

    # Calculate radius terms
    rho = sqrt(three)
    r = sqrt(alt * (alt + 2 * rho) + (EARTH_A2 * one + EARTH_B2 * two) / three)

    # Calculate direction cosines
    cd = (alt + rho) / r
    sd = EARTH_A2_B2_DIFF / rho * ct * st / r
    colat = acosd(ct * cd - st * sd)
    return r, colat, lon
end
