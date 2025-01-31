module SpaceTools

using Dates
using DimensionalData
using DimensionalData.Dimensions
using LinearAlgebra
using Makie
using TimeseriesTools
using Statistics
using Unitful
using RollingWindowArrays

export AbstractDataSet, DataSet
export degap, rectify_datetime, resolution, samplingrate, smooth
export timeshift, tnorm
export tplot!, tplot, ylabel
export LMN
export rotate, fac_matrix_make, mva, mva_mat

const AbstractDimType = Union{AbstractDimStack,AbstractDimArray}
const AbstractDimMatrix = Union{DimensionalData.AbstractDimMatrix,TimeseriesTools.AbstractDimMatrix}
const AbstractDimVector = Union{DimensionalData.AbstractDimVector,TimeseriesTools.AbstractDimVector}

include("dataset.jl")
include("mhd.jl")
include("timeseries.jl")
include("timeseries/tplot.jl")
include("utils.jl")
include("cotrans/coordinate.jl")
include("cotrans/rotate.jl")
include("cotrans/fac.jl")
include("cotrans/mva.jl")

end