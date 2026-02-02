"""
Julia-based Space Physics Environment Data Analysis Software

See the [Documentation](https://juliaspacephysics.github.io/SPEDAS.jl) for more information.
"""
module SPEDAS

using Dates
using Dates: AbstractTime
using DimensionalData
using DimensionalData.Dimensions
using DimensionalData: AbstractDimVector, TimeDim
using DimensionalData.Dimensions: Dimension
using LinearAlgebra
using StaticArrays
using Unitful, DimensionfulAngles
using SignalAnalysis
using Reexport: @reexport
@reexport using SpaceDataModel
using SpaceDataModel: meta, name, setmeta, NoMetadata, NoData, timedim, tdimnum, times, unwrap
import SpaceDataModel as SDM
@reexport using TimeseriesUtilities
@reexport using MinimumVarianceAnalysis
@reexport using PlasmaWaves
@reexport using MultiSpacecraftAnalysis

export resample, tresample
export fill_gaps
export rotate, select_rotate, fac_mat, tfac_mat
export get_coord, get_coords, set_coord
export amap, ω2f

const DD = DimensionalData

include("projects/project.jl")
include("timeseries/spectrum.jl")
include("timeseries/gap.jl")
include("utils.jl")
include("utils/dimensiondata.jl")
include("resampling/resample.jl")
include("cotrans/cotrans.jl")
include("analysis/analysis.jl")
include("deprecate.jl")
end
