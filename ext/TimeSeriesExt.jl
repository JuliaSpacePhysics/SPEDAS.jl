module TimeSeriesExt

using SpaceTools
using TimeSeries
using Makie

function SpaceTools.degap(ts::TimeArray)
    ts[all.(!isnan, eachrow(values(ts)))]
end

"""
Norm for every timestamp
"""
function SpaceTools.tnorm(ta, name)
    colnames = name isa Vector{String} ? name : [name]
    TimeArray(
        timestamp(ta),
        norm.(eachrow(values(ta))),
        colnames,
        meta(ta)
    )
end



# Plotting
Makie.convert_arguments(P::Type{<:Lines}, ta::TimeArray) = convert_arguments(P, timestamp(ta), values(ta))

function SpaceTools.ylabel(ta::TimeArray)
    m = meta(ta)
    m === nothing && return ""
    label = prioritized_get(m, ["label", "long_name"], "")
    unit = prioritized_get(m, ["unit", "units"], "")
    isempty(unit) ? label : "$label ($unit)"
end

function SpaceTools.ylabel(tas::AbstractVector{<:TimeArray})
    op(x, y) = ((x != y) && y != "") ? "$x, $y" : x
    mapreduce(SpaceTools.ylabel, op, tas)
end

"""
Overlay multiple columns of a time series on the same axis
"""
function SpaceTools.tplot!(ax::Axis, ta::TimeArray; kwargs...)
    map(propertynames(ta)) do p
        lines!(ax, getproperty(ta, p); label=string(p))
    end
end

function SpaceTools.tplot(gp::GridPosition, ta::TimeArray; kwargs...)
    ax = Axis(gp, ylabel=ylabel(ta))
    plots = tplot!(ax, ta; kwargs...)
    AxisPlots(ax, plots)
end
end