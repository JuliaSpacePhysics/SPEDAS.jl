# https://github.com/PRBEM/IRBEM/blob/e7cecb00caf97bb6357f063d2ba1aa76d71a3705/source/init_nouveau.f#L438

"""
    gei2gsm_mat(time)

Compute the GEI to GSM transformation matrix.

First axis: sun direction (xS, yS, zS)
Second axis: y-axis (cross product of dipole and sun, normalized)
Third axis: z-axis (cross product of sun and y-axis, normalized)
"""
function gei2gsm_mat(time)
    gst, _, ra, dec, _ = csundir(time)
    dipole_gei = geo2gei_mat(gst) * calc_dipole_geo(time)
    v1 = calc_sun_gei(ra, dec)
    v2 = normalize(dipole_gei × v1)
    v3 = v1 × v2
    return transpose(hcat(v1, v2, v3))
end

gsm2gei_mat(x) = inv(gei2gsm_mat(x))