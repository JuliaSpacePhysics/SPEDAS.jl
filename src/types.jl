@kwdef mutable struct Defaults
    add_title::Bool
    add_colorbar::Bool
    delay::Float64
end

"""
    SpaceTools.DEFAULTS

A global constant that holds default parameters:

- `add_title::Bool` defaults to `false`.
- `add_colorbar::Bool` defaults to `true`.
- `delay` : in seconds, the time interval between updates. Default is 0.25.
"""
const DEFAULTS = Defaults(;
    add_title=false,
    add_colorbar=true,
    delay=0.25
)

struct SpeasyProduct
    id::String
end
