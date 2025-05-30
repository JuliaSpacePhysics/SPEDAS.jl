"""
    gse2gsm_mat(time)

Compute the GSE to GSM transformation matrix T3 = <- psi,X>, 
where the rotation angle psi is the GSE-GSM angle.

This transformation is a rotation in the GSE YZ plane from the GSE Z axis to the GSM Z axis.
"""
function gse2gsm_mat(time)
    dipole_gei = geo2gei_mat(time) * calc_dipole_geo(time)
    # Get sun direction parameters
    _, _, sra, sdec, obliq = csundir(time)
    sun_gei = calc_sun_gei(sra, sdec)
    # Calculate ecliptic pole direction in GEI
    pole_gei = SA[0.0, -sin(obliq), cos(obliq)]

    # Calculate cross product of dipole and sun directions
    gmgs = cross(dipole_gei, sun_gei)
    # Calculate magnitude of cross product
    rgmgs = norm(gmgs)
    # Calculate cosine and sine of GSE-GSM angle
    cdze = dot(pole_gei, dipole_gei) / rgmgs
    sdze = dot(pole_gei, gmgs) / rgmgs
    return SA[1 0 0; 0 cdze sdze; 0 -sdze cdze]
end

gsm2gse_mat(time) = inv(gse2gsm_mat(time))
