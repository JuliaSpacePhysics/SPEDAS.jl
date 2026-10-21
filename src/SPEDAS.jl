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
@reexport using GeoCotrans

export fac_mat, tfac_mat
export get_coord, get_coords, set_coord
export amap
export cotrans

# Hook for extension: update coordinate-system dim names and array name
_update_coord_dims(new_da, _, _, _) = new_da

include("utils/dimensiondata.jl")
include("cotrans/cotrans.jl")
include("analysis/analysis.jl")
end
