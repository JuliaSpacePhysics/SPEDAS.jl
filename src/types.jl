@kwdef mutable struct Defaults
    add_title::Bool
    add_colorbar::Bool
    delay::Float64
    resample::Int
end

"""
    SPEDAS.DEFAULTS

A global constant that holds default parameters:

- `add_title::Bool` defaults to `false`.
- `add_colorbar::Bool` defaults to `true`.
- `delay` : in seconds, the time interval between updates. Default is 0.25.
- `resample::Int` : the number of points to resample to. Default is 6070.
"""
const DEFAULTS = Defaults(;
    add_title=false,
    add_colorbar=true,
    delay=0.25,
    resample=6070
)

abstract type FrequencyDim{T} <: Dimension{T} end
@dim 𝑓 FrequencyDim "Frequency"