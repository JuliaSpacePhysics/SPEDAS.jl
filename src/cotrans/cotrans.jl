import IRBEM
export cotrans

include("rotate.jl")
include("coordinate.jl")
include("fac.jl")

@reexport using GeoCotrans
using GeoCotrans: coord_maps

"""
    cotrans(A, in, out; backend=:auto)
    cotrans(A, out; in=get_coord(A))

Transform the data to the `out` coordinate system from the `in` coordinate system.

If `backend` is set to `:auto` (default), this function automatically chooses between Julia's [`GeoCotrans`](https://juliaspacephysics.github.io/GeoCotrans.jl) (if available) and Fortran's [`IRBEM`](https://juliaspacephysics.github.io/IRBEM.jl) implementation. Otherwise, it uses the specified backend.

References:

  - [IRBEM-LIB](https://prbem.github.io/IRBEM/): compute magnetic coordinates and perform coordinate conversions ([Documentation](https://prbem.github.io/IRBEM/api/coordinates_transformations.html), [IRBEM.jl](https://github.com/JuliaSpacePhysics/IRBEM.jl))
  - [SPEDAS Cotrans](https://spedas.org/wiki/index.php?title=Cotrans)
"""
function cotrans(A, in, out; backend = :auto)
    backend = Symbol(backend) # handle Module
    @assert backend in (:auto, :GeoCotrans, :IRBEM) "backend must be :auto, :GeoCotrans, or :IRBEM"
    key = (Symbol(lowercase(in)), Symbol(lowercase(out)))
    Ac = if backend == :auto
        haskey(coord_maps, key) ? coord_maps[key](A) : irbem_cotrans(A, in, out)
    elseif backend == :GeoCotrans
        coord_maps[key](A)
    else
        irbem_cotrans(A, in, out)
    end
    return set_coord(Ac, out)
end

cotrans(A, out; in = get_coord(A)) = cotrans(A, in, out)
cotrans(A, f::Function; dims = 1) = map(f, eachslice(parent(A); dims), times(A))

function irbem_cotrans(A, in, out)
    dims = dimnum(A, TimeDim)
    time = parent(times(A))

    data = dims == 1 ?
           IRBEM.transform(time, parent(A)', in, out)' :
           IRBEM.transform(time, parent(A), in, out)
    return rebuild(A; data)
end
