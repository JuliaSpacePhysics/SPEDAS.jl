module SPEDASDimensionalDataExt

using DimensionalData
using DimensionalData: AbstractDimArray, DimSelectors, Dim, rebuild
import SPEDAS

# amap: apply f to the intersection of a and b
function SPEDAS.amap(f, a::AbstractDimArray, b::AbstractDimArray)
    shared_selectors = DimSelectors(a)[DimSelectors(b)]
    return f(a[shared_selectors], b[shared_selectors])
end

# _rebuild_data: replace data in a DimArray while preserving all dimensions
SPEDAS._rebuild_data(x::AbstractDimArray, data) = rebuild(x; data)

# _update_coord_dims: update array name and dimension names after coordinate transform
function SPEDAS._update_coord_dims(new_da::AbstractDimArray, da::AbstractDimArray, old_coords, old_new_pairs)
    name_str = string(da.name)
    if any(old -> occursin(old, name_str), old_coords)
        new_name = replace(name_str, old_new_pairs...)
        new_da = rebuild(new_da; name = Symbol(new_name))
    end
    for dim in DimensionalData.dims(new_da)
        dim_name = string(DimensionalData.name(dim))
        if any(old -> occursin(old, dim_name), old_coords)
            new_dim_name = replace(dim_name, old_new_pairs...)
            new_da = DimensionalData.set(new_da, dim => Dim{Symbol(new_dim_name)})
        end
    end
    return new_da
end

end
