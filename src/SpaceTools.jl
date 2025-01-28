module SpaceTools

using Makie
using TimeSeries

export tplot!, tplot

include("mhd.jl")
include("timeseries.jl")


abstract type AbstractDataSet end

@kwdef struct DataSet <: AbstractDataSet
    name::String
    parameters::Vector{String}
end


end