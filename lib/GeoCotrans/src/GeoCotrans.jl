"""
# Coordinate transformations between geocentric systems.

## Supported transformations

- [`geo2gei`](@ref), [`gei2geo`](@ref): Transform between $(coord_text[:geo]) and $(coord_text[:gei]) coordinate systems.
- [`geo2gsm`](@ref), [`gsm2geo`](@ref): Transform between $(coord_text[:geo]) and $(coord_text[:gsm]) coordinate systems.
- [`gei2gsm`](@ref), [`gsm2gei`](@ref): Transform between $(coord_text[:gei]) and $(coord_text[:gsm]) coordinate systems.
- [`gse2gsm`](@ref), [`gsm2gse`](@ref): Transform between $(coord_text[:gse]) and $(coord_text[:gsm]) coordinate systems.

## References

- [Coordinate transformations between geocentric systems](https://www.mssl.ucl.ac.uk/grid/iau/extra/local_copy/SP_coords/geo_tran.htm)
- [ppigrf](https://github.com/IAGA-VMOD/ppigrf): Pure Python code to calculate IGRF model predictions.
"""
module GeoCotrans
using Dictionaries
using Dates
using Dates: AbstractTime
using LinearAlgebra
using StaticArrays
using LazyArrays
using AstroLib: ct2lst, jdcnv

include("igrf_coef.jl")
include("igrf.jl")
include("csundir.jl")
include("cdipdir.jl")
include("geo2gei.jl")
include("gei2gsm.jl")
include("gse2gsm.jl")

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

@doc trans_doc(:gse, :gsm, :gse2gsm_mat) gse2gsm

pair2func(p) = getfield(GeoCotrans, Symbol(p[1], "2", p[2]))
const coord_maps = dictionary(p => pair2func(p) for p in coord_pairs)

end
