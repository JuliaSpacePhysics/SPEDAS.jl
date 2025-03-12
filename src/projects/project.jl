using TOML

export AbstractProject, AbstractInstrument
export Project, Instrument, LDataSet

symbolify(d::Dict) = Dict{Symbol,Any}(Symbol(k) => v for (k, v) in d)

function format_pattern(pattern; kwargs...)
    pairs = ("{$k}" => v for (k, v) in kwargs)
    return replace(pattern, pairs...)
end

_dict2nt(d::Dict; f=identity) = NamedTuple((Symbol(key), f(value)) for (key, value) in d)

include("types.jl")
include("toml.jl")
include("mms.jl")

function DataSet(ld::LDataSet; kwargs...)
    DataSet(
        uppercase(format_pattern(ld.format; kwargs...)),
        map(values(ld.variables)) do v
            format_pattern(v; kwargs...)
        end,
        ld.metadata
    )
end