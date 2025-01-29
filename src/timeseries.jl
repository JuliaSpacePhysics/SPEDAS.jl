Makie.convert_arguments(P::Type{<:Lines}, ta::TimeArray) = convert_arguments(P, timestamp(ta), values(ta))

function ylabel(tas)
    op(x, y) = x == y ? x : "$x, $y"
    mapreduce(ylabel, op, tas)
end

function ylabel(ta::TimeArray{T}) where {T}
    m = meta(ta)
    m === nothing && return ""
    label = get(m, "label", "")
    unit = get(m, "unit", "")
    isempty(unit) ? label : "$label ($unit)"
end

"""
Overlay multiple columns of a time series on the same axis
"""
function tplot!(ax::Axis, ta; kwargs...)
    for p in propertynames(ta)
        lines!(ax, getproperty(ta, p); label=string(p))
    end
end

"""
    tplot!(ax, tas; kwargs...)

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
    f, axs
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