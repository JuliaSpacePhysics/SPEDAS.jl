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
using InteractiveViz

# export AbstractDataSet, DataSet
export degap, rectify_datetime, resolution, samplingrate, smooth
export timeshift, tnorm
export tplot!, tplot, ylabel, plot_attributes
export tsheat
export LMN
export rotate, fac_mat, mva, mva_mat, check_mva_mat
export amap

const DD = DimensionalData
const AbstractDimType = Union{AbstractDimStack,AbstractDimArray}
const AbstractDimMatrix = Union{DimensionalData.AbstractDimMatrix,TimeseriesTools.AbstractDimMatrix}
const AbstractDimVector = Union{DimensionalData.AbstractDimVector,TimeseriesTools.AbstractDimVector}

# include("dataset.jl")
include("mhd.jl")
include("timeseries.jl")
include("timeseries/tplot.jl")
include("timeseries/interactive.jl")
include("timeseries/spectrum.jl")
include("utils.jl")
include("plot.jl")
include("cotrans/coordinate.jl")
include("cotrans/rotate.jl")
include("cotrans/fac.jl")
include("cotrans/mva.jl")

end