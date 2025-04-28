# hack as `Makie` does not support `NanoDate` directly
using NanoDates: NanoDate

makie_x(x) = eltype(x) == NanoDate ? DateTime.(x) : x