export cotrans

include("rotate.jl")
include("coordinate.jl")
include("fac.jl")

@reexport using GeoCotrans
using GeoCotrans: coord_maps

"""
    cotrans(out, A, [times]; in=get_coord(A), backend=GeoCotrans)
    cotrans(in => out, A, [times]; backend=GeoCotrans)

Transform data to the `out` coordinate system.

By default, this uses Julia's [`GeoCotrans`](https://juliaspacephysics.github.io/GeoCotrans.jl).
Use `backend = IRBEM` after loading IRBEM.jl to call Fortran's
[`IRBEM`](https://juliaspacephysics.github.io/IRBEM.jl) implementation.

References:

  - [IRBEM-LIB](https://prbem.github.io/IRBEM/): compute magnetic coordinates and perform coordinate conversions ([Documentation](https://prbem.github.io/IRBEM/api/coordinates_transformations.html), [IRBEM.jl](https://github.com/JuliaSpacePhysics/IRBEM.jl))
  - [SPEDAS Cotrans](https://spedas.org/wiki/index.php?title=Cotrans)
"""
function cotrans(out, A, args...; in = get_coord(A), backend = GeoCotrans, kw...)
    isnothing(in) && throw(ArgumentError("input coordinate system required; use `cotrans(in => out, A, times)` or pass `in = ...`"))
    @assert nameof(backend) ∈ (:GeoCotrans, :IRBEM) "backend must be either GeoCotrans or IRBEM"
    Ac = backend === GeoCotrans ?
        _geocotrans_cotrans(A, in, out, args...; kw...) :
        _irbem_cotrans(A, in, out, args...; kw...)
    return set_coord(Ac, out)
end

cotrans(pair::Pair, A, args...; kw...) =
    cotrans(last(pair), A, args...; in = first(pair), kw...)

function _geocotrans_cotrans(A, in, out, args...; kw...)
    _symbol(s) = Symbol(lowercase(string(s)))

    transform = get(coord_maps, (_symbol(in), _symbol(out)), nothing)
    isnothing(transform) && throw(ArgumentError("GeoCotrans has no $(in) => $(out) transform; load IRBEM.jl and use `backend = IRBEM` if IRBEM supports it"))
    return transform(A, args...; kw...)
end

_irbem_cotrans(A, in, out, args...; kw...) =
    throw(ArgumentError("IRBEM backend not available; load IRBEM.jl and pass `backend = IRBEM`"))
