"""
Julia-based Space Physics Environment Data Analysis Software

See the [Documentation](https://juliaspacephysics.github.io/SPEDAS.jl) for more information.
"""
module SPEDAS

using Dates
using Dates: AbstractTime
using LinearAlgebra
using Reexport: @reexport
import TimeseriesUtilities: dimnum
@reexport using SpaceDataModel
using SpaceDataModel: meta, name, setmeta, NoMetadata, NoData, timedim, tdimnum, times, unwrap
import SpaceDataModel as SDM
@reexport using TimeseriesUtilities
using TimeseriesUtilities: ContinuousTimeRanges
export ContinuousTimeRanges
@reexport using MinimumVarianceAnalysis
@reexport using PlasmaWaves
@reexport using MultiSpacecraftAnalysis

export resample, tresample
export fill_gaps
export rotate, select_rotate, fac_mat, tfac_mat
export get_coord, get_coords, set_coord
export amap

# Hook for extension: rebuild array with new data (DimArray preserves structure via ext)
_rebuild_data(_, data) = data
# Hook for extension: update coordinate-system dim names and array name
_update_coord_dims(new_da, _, _, _) = new_da

include("projects/project.jl")
include("timeseries/gap.jl")
include("utils/dimensiondata.jl")
include("resampling/resample.jl")
include("cotrans/cotrans.jl")
include("analysis/analysis.jl")
include("deprecate.jl")
end
