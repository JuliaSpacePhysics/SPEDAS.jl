# hack as `Makie` does not support `NanoDate` directly
using NanoDates: NanoDate

makie_t2x(x) = eltype(x) == NanoDate ? DateTime.(x) : x
makie_x(x) = 1:size(x, 1)