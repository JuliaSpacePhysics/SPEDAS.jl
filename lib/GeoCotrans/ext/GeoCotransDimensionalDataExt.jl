module GeoCotransDimensionalDataExt
using DimensionalData
using DimensionalData: TimeDim
using GeoCotrans: coord_maps

for f in nameof.(coord_maps)
    @eval import GeoCotrans: $f
    @eval @inline function $f(A)
        dims = dimnum(A, TimeDim)
        times = A.dims[dims]
        data = stack($f, eachslice(parent(A); dims), times; dims)
        return rebuild(A, data)
    end
    @eval export $f
end

end
