abstract type AbstractDataSet end

@kwdef struct DataSet <: AbstractDataSet
    name::String
    parameters::Vector{String}
end