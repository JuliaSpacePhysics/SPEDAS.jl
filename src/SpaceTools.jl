module SpaceTools

using Dates
using DimensionalData
using LinearAlgebra
using Makie
using TimeseriesTools
using Statistics
using Unitful
using RollingWindowArrays

export AbstractDataSet, DataSet
export degap, rectify_datetime, resolution, samplingrate, smooth
export tplot!, tplot, ylabel
export rotate, fac_matrix_make

const AbstractDimType = Union{AbstractDimStack,AbstractDimArray}

include("dataset.jl")
include("mhd.jl")
include("timeseries.jl")
include("timeseries/tplot.jl")
include("utils.jl")
include("cotrans/rotate.jl")
include("cotrans/fac.jl")

end