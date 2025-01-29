module SpaceTools

using Dates
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

const AbstractDimType = Union{AbstractDimStack,AbstractDimArray}

include("dataset.jl")
include("mhd.jl")
include("timeseries.jl")
include("timeseries/tplot.jl")
include("utils.jl")

end