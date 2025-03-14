module TimeSeriesExt

using SPEDAS
using TimeSeries
using Makie

function SPEDAS.dropna(ts::TimeArray)
    ts[all.(!isnan, eachrow(values(ts)))]
end

"""
Norm for every timestamp
"""
function SPEDAS.tnorm(ta, name)
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

function SPEDAS.ylabel(ta::TimeArray)
    m = meta(ta)
    m === nothing && return ""
    label = prioritized_get(m, ["label", "long_name"], "")
    unit = prioritized_get(m, ["unit", "units"], "")
    isempty(unit) ? label : "$label ($unit)"
end

function SPEDAS.ylabel(tas::AbstractVector{<:TimeArray})
    op(x, y) = ((x != y) && y != "") ? "$x, $y" : x
    mapreduce(SPEDAS.ylabel, op, tas)
end

"""
Overlay multiple columns of a time series on the same axis
"""
function SPEDAS.tplot!(ax::Axis, ta::TimeArray; kwargs...)
    map(propertynames(ta)) do p
        lines!(ax, getproperty(ta, p); label=string(p))
    end
end

function SPEDAS.tplot(gp::GridPosition, ta::TimeArray; kwargs...)
    ax = Axis(gp, ylabel=ylabel(ta))
    plots = tplot!(ax, ta; kwargs...)
    AxisPlots(ax, plots)
end
end