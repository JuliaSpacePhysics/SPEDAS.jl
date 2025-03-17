using TOML

export AbstractProject, AbstractInstrument
export Project, Instrument, LDataSet

symbolify(d::Dict) = Dict{Symbol,Any}(Symbol(k) => v for (k, v) in d)

function format_pattern(pattern; kwargs...)
    pairs = ("{$k}" => v for (k, v) in kwargs)
    return replace(pattern, pairs...)
end

_dict2nt(d::Dict; f=identity) = NamedTuple((Symbol(key), f(value)) for (key, value) in d)

"""
    @load_project_config(file)

Load configuration from a file and export all key-value pairs as constants.
The macro evaluates in the calling module's context.
"""
macro load_project_config(file)
    _load_project_config(file; mod=__module__)
end

function _load_project_config(file; mod=Main, directory=joinpath(pkgdir(@__MODULE__), "config"), export_symbol=true)
    file_path = joinpath(directory, file)
    config = load_project_config(file_path)
    # @eval mod const CONFIG = $config
    @eval mod CONFIG = $config
    for (sym, value) in config
        # @eval mod const $sym = $value
        @eval mod $sym = $value
        export_symbol && @eval mod export $sym
    end
end

include("types.jl")
include("toml.jl")
include("mms.jl")

function DataSet(ld::LDataSet; kwargs...)
    DataSet(
        uppercase(format_pattern(ld.format; kwargs...)),
        Dict(k => format_pattern(v; kwargs...) for (k, v) in ld.parameters),
        ld.metadata
    )
end