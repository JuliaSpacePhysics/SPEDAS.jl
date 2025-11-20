"""
Julia-based Space Physics Environment Data Analysis Software

See the [Documentation](https://juliaspacephysics.github.io/SPEDAS.jl) for more information.
"""
module SPEDAS

using Dates
using Dates: AbstractTime
using DimensionalData
using DimensionalData.Dimensions
using DimensionalData: AbstractDimVector, AbstractDimMatrix, TimeDim
using DimensionalData.Dimensions: Dimension
using LinearAlgebra
using NaNStatistics
using Intervals: Interval
using StaticArrays
using Statistics
using Unitful, DimensionfulAngles
using SignalAnalysis
using NamedTupleTools
using Reexport
@reexport using SpaceDataModel
using SpaceDataModel: meta, name, setmeta, NoMetadata, NoData
@reexport using TimeseriesUtilities
@reexport using MinimumVarianceAnalysis
@reexport using PlasmaWaves

# export TimeRange
export tstack, tinterp, tinterp_nans, tsync, resample, tresample
export fill_gaps
export rotate, select_rotate, fac_mat, tfac_mat, mva, mva_eigen, check_mva_eigen
export get_coord, get_coords, set_coord
export standardize, amap, ω2f
export reciprocal_vector, reciprocal_vectors, lingradest
export volumetric_tensor, tetrahedron_quality
export ConstantVelocityApproach, CVA, ConstantThicknessApproach, CTA
export DiscontinuityAnalyzer, DA
export Elsässer, σ_c

const DD = DimensionalData
const AbstractDimType = Union{AbstractDimStack, AbstractDimArray}
const MatrixLike = Union{AbstractArray{<:AbstractVector}, AbstractMatrix}

include("projects/project.jl")
include("mhd.jl")
include("timeseries/spectrum.jl")
include("timeseries/gap.jl")
include("utils.jl")
include("utils/dimensiondata.jl")
include("resampling/resample.jl")
include("resampling/interp.jl")
include("cotrans/cotrans.jl")
include("multispacecraft/reciprocal_vector.jl")
include("multispacecraft/tetrahedron.jl")
include("multispacecraft/lingradest.jl")
include("multispacecraft/timing.jl")
include("analysis/analysis.jl")
end
