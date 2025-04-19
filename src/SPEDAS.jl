"""
Julia-based Space Physics Environment Data Analysis Software

See the [Documentation](https://beforerr.github.io/SPEDAS.jl/dev/) for more information.
"""
module SPEDAS

using Dates
using NanoDates
using Dates: AbstractTime
using DimensionalData
using DimensionalData.Dimensions
using DimensionalData: TimeDim
using DimensionalData.Dimensions: Dimension
using LinearAlgebra
using NaNStatistics
using Makie
using TimeseriesTools
using Intervals: Interval
using StaticArrays
using OhMyThreads
using Statistics
using Unitful, DimensionfulAngles
using Latexify, UnitfulLatexify
using RollingWindowArrays
using FFTW, DSP, SignalAnalysis
using Tullio
using Bumper
using InverseFunctions
using NamedTupleTools
using Accessors: @set
using Reexport
@reexport using SpaceDataModel

export dropna, rectify_datetime, resolution, samplingrate, smooth, tsplit
export timerange, TimeRange, common_timerange
export norm_combine, tnorm_combine
export tstack, tinterp, tinterp_nans, resample, tresample, tfilter
export find_spikes, replace_outliers
export fill_gaps
export ylabel, plot_attributes
export LMN
export rotate, select_rotate, fac_mat, tfac_mat, mva, mva_eigen, check_mva_eigen
export get_coord, get_coords, set_coord
export standardize, modify_meta, amap, ω2f
export reciprocal_vector, reciprocal_vectors, lingradest
export volumetric_tensor, tetrahedron_quality
export ConstantVelocityApproach, CVA, ConstantThicknessApproach, CTA, DiscontinuityAnalyzer, DA
export Elsässer, σ_c
export spectral_matrix, wavpol, twavpol, wpol_helicity, polarization

const DD = DimensionalData
const AbstractDimType = Union{AbstractDimStack,AbstractDimArray}
const AbstractDimMatrix = Union{DimensionalData.AbstractDimMatrix,TimeseriesTools.AbstractDimMatrix}
const AbstractDimVector = Union{DimensionalData.AbstractDimVector,TimeseriesTools.AbstractDimVector}
const MatrixLike = Union{AbstractArray{<:AbstractVector},AbstractMatrix}

include("projects/project.jl")
include("mhd.jl")
include("timeseries/timeseries.jl")
include("timeseries/spectrum.jl")
include("timeseries/spike.jl")
include("timeseries/gap.jl")
include("utils.jl")
include("utils/timerange.jl")
include("utils/dimensiondata.jl")
include("types.jl")
include("resampling/resample.jl")
include("resampling/interp.jl")
include("meta.jl")
include("plot/transform.jl")
include("plot/attributes.jl")
include("plot/tplot.jl")
include("cotrans/coordinate.jl")
include("cotrans/rotate.jl")
include("cotrans/fac.jl")
include("cotrans/mva.jl")
include("multispacecraft/reciprocal_vector.jl")
include("multispacecraft/tetrahedron.jl")
include("multispacecraft/lingradest.jl")
include("multispacecraft/timing.jl")
include("analysis/analysis.jl")
include("waves/polarization.jl")
include("waves/helicty.jl")
include("waves/spectral_matrix.jl")

end