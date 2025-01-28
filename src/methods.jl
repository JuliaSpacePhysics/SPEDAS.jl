"""
Norm for every timestamp
"""
function tnorm(ta, name)
    colnames = name isa Vector{String} ? name : [name]
    TimeArray(
        timestamp(ta),
        norm.(eachrow(values(ta))),
        colnames,
        meta(ta)
    )
end