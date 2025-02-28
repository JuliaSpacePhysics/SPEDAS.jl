module SpaceTools

using Dates
using DimensionalData
using DimensionalData.Dimensions
using LinearAlgebra
using Makie
using TimeseriesTools
using Intervals: Interval
using StructArrays
using Statistics
using Unitful, DimensionfulAngles
using Latexify, UnitfulLatexify
using RollingWindowArrays
using InteractiveViz
using DSP, SignalAnalysis
using InverseFunctions

export AbstractDataSet, DataSet
export dropna, rectify_datetime, resolution, samplingrate, smooth, tsplit
export timerange
export timeshift, tnorm, tmean, tcross, tdot
export tstack, tinterp, resample, tresample
export tplot!, tplot, tplot_panel, tplot_panel!
export tsheat, tlims!, tlines!, add_labels!
export ylabel, plot_attributes
export LMN
export rotate, fac_mat, mva, mva_mat, check_mva_mat
export modify_meta, amap, ω2f
export reciprocal_vector, reciprocal_vectors, lingradest
export volumetric_tensor, tetrahedron_quality
export ConstantVelocityApproach, CVA, ConstantThicknessApproach, CTA, DiscontinuityAnalyzer, DA
export Elsässer, σ_c

const DD = DimensionalData
const AbstractDimType = Union{AbstractDimStack,AbstractDimArray}
const AbstractDimMatrix = Union{DimensionalData.AbstractDimMatrix,TimeseriesTools.AbstractDimMatrix}
const AbstractDimVector = Union{DimensionalData.AbstractDimVector,TimeseriesTools.AbstractDimVector}
const MatrixLike = Union{AbstractArray{<:AbstractVector},AbstractMatrix}

include("dataset.jl")
include("mhd.jl")
include("methods.jl")
include("timeseries.jl")
include("timeseries/interactive.jl")
include("timeseries/spectrum.jl")
include("timeseries/methods.jl")
include("utils.jl")
include("utils/timerange.jl")
include("utils/dimensiondata.jl")
include("types.jl")
include("resampling/resample.jl")
include("resampling/interp.jl")
include("meta.jl")
include("plot/types.jl")
include("plot/transform.jl")
include("plot/attributes.jl")
include("plot/tplot.jl")
include("plot/tplot_specapi.jl")
include("plot/panelplot.jl")
include("plot/methods.jl")
include("cotrans/coordinate.jl")
include("cotrans/rotate.jl")
include("cotrans/fac.jl")
include("cotrans/mva.jl")
include("multispacecraft/reciprocal_vector.jl")
include("multispacecraft/tetrahedron.jl")
include("multispacecraft/lingradest.jl")
include("multispacecraft/timing.jl")

end