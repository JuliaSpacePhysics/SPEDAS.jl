"""
    car2sph(x, y, z)

Convert `(x, y, z)` in Cartesian coordinate to `(r, colat [deg], lon [deg])` in spherical coordinate.
"""
function car2sph(x, y, z)
    sq = x^2 + y^2
    r = sqrt(sq + z^2)
    if sq == 0.0
        lon = 0.0
        colat = ifelse(z < 0.0, 180.0, 0.0)
    else
        # sqrt of x-y plane projection
        ρ = sqrt(sq)
        lon = atand(y, x)
        colat = atand(ρ, z)
        # wrap longitude into [0,360)
        lon = ifelse(lon < 0.0, lon + 360.0, lon)
    end
    return r, colat, lon
end
