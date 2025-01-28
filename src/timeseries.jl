Makie.convert_arguments(P::Type{<:Lines}, ta::TimeArray) = convert_arguments(P, timestamp(ta), values(ta))

ylabel(tas) = ""

function ylabel(ta::TimeArray)
    m = meta(ta)
    m === nothing && return ""
    haskey(m, "label") && haskey(m, "unit") || return ""
    label = m["label"]
    unit = m["unit"]
    isempty(unit) ? label : "$label ($unit)"
end

"""
Overlay multiple columns of a time series on the same axis
"""
function tplot!(ax::Axis, ta; kwargs...)
    for p in propertynames(ta)
        lines!(ax, getproperty(ta, p); label=p)
    end
end

"""

Overlay multiple time series on the same axis
"""
function tplot!(ax::Axis, tas::AbstractVector; kwargs...)
    for ta in tas
        tplot!(ax, ta; kwargs...)
    end
end

"""
Lay out multiple time series on the same figure
"""
function tplot!(f, tas::AbstractVector; linkxaxes=true, kwargs...)
    axs = []
    for (i, ta) in enumerate(tas)
        ax = Axis(f[i, 1]; ylabel=ylabel(ta))
        tplot!(ax, ta; kwargs...)

        # Hide redundant x labels
        linkxaxes && i != length(tas) && hidexdecorations!(ax, grid=false)
        push!(axs, ax)
    end
    linkxaxes && linkxaxes!(axs...)
    f
end

function tplot(tas; linkxaxes=true, figure=(;), kwargs...)
    f = Figure(; figure...)
    axs = []
    for (i, ta) in enumerate(tas)
        ax = Axis(f[i, 1]; ylabel=ylabel(ta))

        for p in propertynames(ta)
            lines!(ax, getproperty(ta, p); label=p)
        end

        # Hide redundant x labels
        linkxaxes && i != length(tas) && hidexdecorations!(ax, grid=false)
        push!(axs, ax)
    end
    linkxaxes && linkxaxes!(axs...)
    f
end