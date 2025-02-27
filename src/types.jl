@kwdef mutable struct Defaults
    add_title::Bool = false
    delay::Float64 = 0.25
end

"""
    SpaceTools.DEFAULTS

A global constant that holds default parameters:

- `add_title::Bool` defaults to `false`.
- `delay` : in seconds, the time interval between updates. Default is 0.25.
"""
const DEFAULTS = Defaults(
    add_title=false,
    delay=0.25
)

struct SpeasyProduct
    id::String
end
