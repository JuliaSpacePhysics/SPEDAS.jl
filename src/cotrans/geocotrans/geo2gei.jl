# https://pyspedas.readthedocs.io/en/latest/coords.html#pyspedas.cotrans_tools.cotrans_lib.subgeo2gei

@inline function gei2geo_mat(gst)
    cgst = cos(gst)
    sgst = sin(gst)
    return SA[cgst sgst 0; -sgst cgst 0; 0 0 1]
end

gei2geo_mat(time::AbstractTime) = gei2geo_mat(calculate_gst_alt(time))

geo2gei_mat(x) = inv(gei2geo_mat(x))