using TOML

"""
    @load_project_config(file)

Load configuration from a file and export all key-value pairs as constants.
The macro evaluates in the calling module's context.
"""
macro load_project_config(file)
    _load_project_config(file; mod=__module__)
end

function repr2doc(x; mime="text/plain")
    """
    ```julia
    $(repr(mime, x))
    ```
    """
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

include("utils.jl")
include("toml.jl")
include("MMS/MMS.jl")
include("THEMIS/THEMIS.jl")
include("PSP/PSP.jl")
include("Juno/Juno.jl")