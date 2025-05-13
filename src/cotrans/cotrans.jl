import IRBEM
using AstroLib: ct2lst, jdcnv

export cotrans
export geo2gei, gei2geo

include("geo2gei.jl")
include("coordinate.jl")

"""
    cotrans(A, out, in=get_coord(A))

Transform the data to the specified coordinate system.
"""
function cotrans(A, in, out)
    time = parent(times(A))
    data = IRBEM.transform(time, parent(A), in, out)
    set_coord(rebuild(A; data=data), out)
end

cotrans(A, out; in=get_coord(A)) = cotrans(A, in, out)
cotrans(A, f::Function; dims=1) = map(f, eachslice(parent(A); dims), times(A))

for f in (:gei2geo, :geo2gei)
    @eval $f(A) = map($f, eachslice(parent(A); dims=dimnum(A, TimeDim)), times(A))
end
