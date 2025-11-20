# Unitify Quantity using common convention
unitify(x, unit) = x isa Quantity ? x : x * unit
Bᵤ(x) = unitify(x, u"nT")
∇Bᵤ(x) = unitify(x, u"nT/km")
