"""
Coordinate systems, transformations, and geomagnetic field models.

## Coordinate systems

- [`GEO`](@ref): $(description(GEO))
- [`GSM`](@ref): Geocentric Solar Magnetic (GSM) coordinate system.
- [`GSE`](@ref): Geocentric Solar Ecliptic (GSE) coordinate system.
- [`GEI`](@ref): Geocentric Equatorial Inertial (GEI) coordinate system.
- [`GDZ`](@ref): $(description(GDZ))
- [`MAG`](@ref): Magnetic (MAG) coordinate system.
- [`SPH`](@ref): $(description(SPH))
- [`J2000`](@ref): J2000 (J2000) coordinate system.

## Coordinate transformations

- [`geo2gei`](@ref), [`gei2geo`](@ref): Transform between GEO and GEI coordinate systems.
- [`geo2gsm`](@ref), [`gsm2geo`](@ref): Transform between GEO and GSM coordinate systems.
- [`gei2gsm`](@ref), [`gsm2gei`](@ref): Transform between GEI and GSM coordinate systems.
- [`gse2gsm`](@ref), [`gsm2gse`](@ref): Transform between GSE and GSM coordinate systems.

### References

- [Coordinate transformations between geocentric systems](https://www.mssl.ucl.ac.uk/grid/iau/extra/local_copy/SP_coords/geo_tran.htm)

## International Geomagnetic Reference Field (IGRF)

> The International Geomagnetic Reference Field (IGRF) is a standard mathematical description of the Earth's main magnetic field. It is used widely in studies of the Earth's deep interior, crust, ionosphere, and magnetosphere.

### Functions

- [`igrf_B`](@ref): Compute the geomagnetic field (IGRF-14, dipole model)

### Examples

```julia
r, θ, φ = 6500., 30., 4.
t = Date(2021, 3, 28)
Br, Bθ, Bφ = igrf_B(r, θ, φ, t)

# Input position in geodetic coordinates, output magnetic field in East-North-Up (ENU) coordinates
Be, Bn, Bu = igrf_B(GDZ(0, 60.39299, 5.32415), t)
```

### References

- [IAGA - NOAA/NCEI](https://www.ncei.noaa.gov/products/international-geomagnetic-reference-field)
- [IGRF-14 Evaluation](https://iaga-vmod.github.io/IGRF14eval/README.html)

### Elsewhere

- [SatelliteToolboxGeomagneticField.jl](https://github.com/JuliaSpace/SatelliteToolboxGeomagneticField.jl): Models to compute the geomagnetic field (IGRF-13, dipole model)
- [ppigrf](https://github.com/IAGA-VMOD/ppigrf): Pure Python code to calculate IGRF model predictions.
- [geopack](https://github.com/tsssss/geopack): Python code to calculate IGRF model predictions.
"""
module GeoCotrans
using Dictionaries
using Dates
using Dates: AbstractTime
using LinearAlgebra
using StaticArrays
using AstroLib: ct2lst, jdcnv

include("constants.jl")
include("types.jl")
include("igrf.jl")
include("car2sph.jl")
include("csundir.jl")
include("cdipdir.jl")
include("geo2gei.jl")
include("gei2gsm.jl")
include("gse2gsm.jl")
include("gdz2geo.jl")

const coord_text = Dict(
    :geo => "Geographic (GEO)",
    :gei => "Geocentric Equatorial Inertial (GEI)",
    :gse => "Geocentric Solar Ecliptic (GSE)",
    :gsm => "Geocentric Solar Magnetic (GSM)"
)

trans_doc(c1, c2) = """
    $(c1)2$(c2)(x, t)

Transforms `x` vector from $(coord_text[c1]) to $(coord_text[c2]) coordinates at time `t`.
"""

trans_doc(c1, c2, mat) = """
$(trans_doc(c1, c2))

See also: [`$(mat)`](@ref)
"""

const coord_pairs = (
    # Direct transformations
    (:geo, :gei), (:gei, :geo),
    (:gei, :gsm), (:gsm, :gei),
    (:gse, :gsm), (:gsm, :gse),
    # Chain transformations
    (:geo, :gsm), (:gsm, :geo)
)

geo2gsm_mat(t) = gei2gsm_mat(t) * geo2gei_mat(t)
gsm2geo_mat(t) = inv(geo2gsm_mat(t))

for p in coord_pairs
    doc = trans_doc(p[1], p[2])
    func = Symbol(p[1], "2", p[2])
    matfunc = Symbol(func, :_mat)
    @eval @doc $doc $func(x, t)=$matfunc(t) * x
    @eval export $func
end

function description(::Type{GDZ})
    "Geodetic (GDZ) coordinate system `(altitude [km], latitude [deg], longitude [deg])`."
end
function long_description(::Type{GDZ})
    """Defined using a reference ellipsoid. Both the altitude and latitude depend on the ellipsoid used. GeoCotrans uses the WGS84 reference ellipsoid."""
end

function description(::Type{GEO})
    "Geocentric geographic cartesian coordinate system `(x [𝐋], y [𝐋], z [𝐋])`."
end
description(::Type{GSM}) = "Geocentric Solar Magnetic (GSM) coordinate system."
description(::Type{GSE}) = "Geocentric Solar Ecliptic (GSE) coordinate system."
description(::Type{GEI}) = "Geocentric Equatorial Inertial (GEI) coordinate system."
description(::Type{MAG}) = "Magnetic (MAG) coordinate system."
function description(::Type{SPH})
    "Geocentric geographic spherical (SPH) coordinate system `(r [𝐋], θ [deg], φ [deg])`."
end
description(::Type{J2000}) = "J2000 (J2000) coordinate system."

export gdz2sph

@doc trans_doc(:gse, :gsm, :gse2gsm_mat) gse2gsm

pair2func(p) = getfield(GeoCotrans, Symbol(p[1], "2", p[2]))
const coord_maps = dictionary(p => pair2func(p) for p in coord_pairs)

end
