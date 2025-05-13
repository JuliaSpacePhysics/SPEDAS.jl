# https://pyspedas.readthedocs.io/en/latest/coords.html#pyspedas.cotrans_tools.cotrans_lib.subgeo2gei

@inline function gei2geo_mat(time)
    gst = calculate_gst(time)
    cgst = cos(gst)
    sgst = sin(gst)
    return SA[cgst sgst 0; -sgst cgst 0; 0 0 1]
end

"""
    gei2geo(pos, time)

Converts geocentric equatorial inertial (GEI) coordinates to geographical (GEO) coordinates.
"""
gei2geo(pos, time) = gei2geo_mat(time) * pos

"""
    geo2gei(pos, time)

Converts geographical (GEO) coordinates to geocentric equatorial inertial (GEI) coordinates.
"""
geo2gei(pos, time) = inv(gei2geo_mat(time)) * pos

"""
    calculate_gst(time)

Calculate Greenwich sidereal time (GST) in radians from the given time.

Reference: https://aa.usno.navy.mil/faq/GAST, https://github.com/JuliaAstro/AstroLib.jl/blob/main/src/ct2lst.jl
"""
function calculate_gst(time)
    # ct2lst returns local sidereal time in hours (0-24)
    # For Greenwich, longitude=0, so GST = LST
    return ct2lst(0, jdcnv(time)) * 2π / 24
end

"""
    calculate_gst_alt(time)

Alternative implementation of Greenwich sidereal time calculation based on the
reference algorithm from `pyspedas.cotrans_tools.csundir_vect`.
"""
function calculate_gst_alt(time::DateTime)
    # Extract time components
    iyear = year(time)
    idoy = dayofyear(time)
    # Julian day and Greenwich mean sidereal time calculation
    fday = Time(time).instant / Day(1)
    jj = 365 * (iyear - 1900) + floor((iyear - 1901) / 4) + idoy
    dj = jj - 0.5 + fday
    gst = mod(279.690983 + 0.9856473354 * dj + 360.0 * fday + 180.0, 360.0)
    return gst * 2π / 360
end