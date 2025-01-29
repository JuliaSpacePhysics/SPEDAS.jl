DimensionalDataMakie = Base.get_extension(DimensionalData, :DimensionalDataMakie)
using .DimensionalDataMakie: _series

# https://github.com/MakieOrg/AlgebraOfGraphics.jl/blob/master/src/entries.jl
struct FigureAxes
    figure::Figure
    axes::AbstractArray{<:Axis}
end

Makie.convert_arguments(P::Type{<:Lines}, ta::TimeArray) = convert_arguments(P, timestamp(ta), values(ta))


ylabel(ta) = ""

function ylabel(tas::AbstractVector{<:TimeArray})
    op(x, y) = x == y ? x : "$x, $y"
    mapreduce(ylabel, op, tas)
end

function ylabel(ta::TimeArray)
    m = meta(ta)
    m === nothing && return ""
    label = get(m, "label", "")
    unit = get(m, "unit", "")
    isempty(unit) ? label : "$label ($unit)"
end

"""
Overlay multiple columns of a time series on the same axis
"""
function tplot!(ax::Axis, ta::TimeArray; kwargs...)
    for p in propertynames(ta)
        lines!(ax, getproperty(ta, p); label=string(p))
    end
end

"""
Overlay multiple columns of a time series on the same axis
"""
function tplot!(ax::Axis, ta::AbstractDimArray; labeldim=nothing, kwargs...)
    args, attributes = _series(ta, kwargs, labeldim)
    series!(ax, args...; labels=attributes.labels, kwargs...)
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

function tplot(gp::GridPosition, tas::AbstractVector; kwargs...)
    ax = Axis(gp, ylabel=ylabel(ta))
    plots = map(tas) do ta
        tplot!(ax, ta; kwargs...)
    end
    ax, plots
end

function tplot(gp::GridPosition, ta::AbstractDimArray; labeldim=nothing, kwargs...)
    args, attributes = _series(ta, kwargs, labeldim)
    series(gp, args...; attributes...)
end

"""
Lay out multiple time series on the same figure
"""
function tplot(f, tas::AbstractVector; add_legend=true, link_xaxes=true, kwargs...)
    aps = map(enumerate(tas)) do (i, ta)
        ap = tplot(f[i, 1], ta; kwargs...)
        # Hide redundant x labels
        link_xaxes && i != length(tas) && hidexdecorations!(ap.axis, grid=false)
        ap
    end
    axs = map(ap -> ap.axis, aps)
    link_xaxes && linkxaxes!(axs...)
    add_legend && axislegend.(axs)
    FigureAxes(f, axs)
end

function tplot(tas; figure=(;), kwargs...)
    f = Figure(; figure...)
    fa = tplot(f, tas; kwargs...)
    fa
end


Base.show(io::IO, fg::FigureAxes) = show(io, fg.figure)
Base.display(fg::FigureAxes) = display(fg.figure)

Base.iterate(fg::FigureAxes) = iterate((fg.figure, fg.axes))
Base.iterate(fg::FigureAxes, i) = iterate((fg.figure, fg.axes), i)