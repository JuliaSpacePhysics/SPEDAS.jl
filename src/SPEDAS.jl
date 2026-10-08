"""
Julia-based Space Physics Environment Data Analysis Software

See the [Documentation](https://juliaspacephysics.github.io/SPEDAS.jl) for more information.
"""
module SPEDAS

using Dates
using LinearAlgebra
using Reexport: @reexport
using TimeseriesUtilities: resolve_dim
@reexport using SpaceDataModel
using SpaceDataModel: meta, setmeta, times
@reexport using TimeseriesUtilities
@reexport using MinimumVarianceAnalysis
@reexport using PlasmaWaves
@reexport using MultiSpacecraftAnalysis

export fac_mat, tfac_mat
export get_coord, get_coords, set_coord
export amap

# Hook for extension: rebuild array with new data (DimArray preserves structure via ext)
_rebuild_data(_, data) = data
# Hook for extension: update coordinate-system dim names and array name
_update_coord_dims(new_da, _, _, _) = new_da

include("utils/dimensiondata.jl")
include("cotrans/cotrans.jl")
include("analysis/analysis.jl")
end
