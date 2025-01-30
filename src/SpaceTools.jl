module SpaceTools

using Dates
using LinearAlgebra
using Makie
using TimeSeries
using TimeseriesTools
using Statistics
using Unitful
using RollingFunctions
using RollingWindowArrays

export AbstractDataSet, DataSet
export resolution, smooth
export tplot!, tplot
export fac_matrix_make

const AbstractDimType = Union{AbstractDimStack,AbstractDimArray}

include("dataset.jl")
include("mhd.jl")
include("timeseries.jl")
include("timeseries/tplot.jl")
include("utils.jl")
include("cotrans/fac.jl")

end