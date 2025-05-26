import IRBEM
export cotrans

include("coordinate.jl")
include("geocotrans/GeoCotrans.jl")

using .GeoCotrans: coord_maps

"""
    cotrans(A, in, out)
    cotrans(A, out; in=get_coord(A))

Transform the data to the `out` coordinate system from the `in` coordinate system.

This function automatically choose between Julia's [`GeoCotrans`](@ref) (if available) and Fortran's `IRBEM` implementation.

References:
- [IRBEM-LIB](https://prbem.github.io/IRBEM/): compute magnetic coordinates and perform coordinate conversions ([Documentation](https://prbem.github.io/IRBEM/api/coordinates_transformations.html), [IRBEM.jl](https://github.com/Beforerr/IRBEM.jl))
- [SPEDAS Cotrans](https://spedas.org/wiki/index.php?title=Cotrans)
"""
function cotrans(A, in, out)
    key = (Symbol(lowercase(in)), Symbol(lowercase(out)))
    Ac = haskey(coord_maps, key) ? coord_maps[key](A) : irbem_cotrans(A, in, out)
    return set_coord(Ac, out)
end

cotrans(A, out; in=get_coord(A)) = cotrans(A, in, out)
cotrans(A, f::Function; dims=1) = map(f, eachslice(parent(A); dims), times(A))

function irbem_cotrans(A, in, out)
    dims = dimnum(A, TimeDim)
    time = parent(times(A))

    data = dims == 1 ?
           IRBEM.transform(time, parent(A)', in, out)' :
           IRBEM.transform(time, parent(A), in, out)
    return rebuild(A; data)
end

for f in nameof.(coord_maps)
    @eval import .GeoCotrans: $f
    @eval @inline function $f(A)
        dims = dimnum(A, TimeDim)
        data = stack($f, eachslice(parent(A); dims), times(A); dims)
        return rebuild(A, data)
    end
    @eval export $f
end
