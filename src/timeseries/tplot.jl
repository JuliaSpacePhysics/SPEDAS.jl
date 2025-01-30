DimensionalDataMakie = Base.get_extension(DimensionalData, :DimensionalDataMakie)
using .DimensionalDataMakie: _series

# https://github.com/MakieOrg/AlgebraOfGraphics.jl/blob/master/src/entries.jl
struct FigureAxes
    figure::Figure
    axes::AbstractArray{<:Axis}
end

struct AxisPlots
    axis::Axis
    plots
end

Makie.convert_arguments(P::Type{<:Lines}, ta::TimeArray) = convert_arguments(P, timestamp(ta), values(ta))


ylabel(ta) = ""

function ylabel(tas::AbstractVector{<:TimeArray})
    op(x, y) = ((x != y) && y != "") ? "$x, $y" : x
    mapreduce(ylabel, op, tas)
end

function prioritized_get(c, keys::AbstractVector, default)
    values = get.(Ref(c), keys, nothing)
    something(values..., default)
end

function ylabel(ta::TimeArray)
    m = meta(ta)
    m === nothing && return ""
    label = prioritized_get(m, ["label", "long_name"], "")
    unit = prioritized_get(m, ["unit", "units"], "")
    isempty(unit) ? label : "$label ($unit)"
end

"""
Overlay multiple columns of a time series on the same axis
"""
function tplot!(ax::Axis, ta::TimeArray; kwargs...)
    map(propertynames(ta)) do p
        lines!(ax, getproperty(ta, p); label=string(p))
    end
end

function tplot(gp::GridPosition, ta::TimeArray; kwargs...)
    ax = Axis(gp, ylabel=ylabel(ta))
    plots = tplot!(ax, ta; kwargs...)
    AxisPlots(ax, plots)
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
Setup the axis on a position and plot multiple time series on it
"""
function tplot(gp::GridPosition, tas::AbstractVector; kwargs...)
    ax = Axis(gp, ylabel=ylabel(tas))
    plots = map(tas) do ta
        tplot!(ax, ta; kwargs...)
    end
    AxisPlots(ax, plots)
end

"""
Overlay multiple columns of a time series on the same axis
"""
function tplot!(ax::Axis, ta::AbstractDimArray; labeldim=nothing, kwargs...)
    args, attributes = _series(ta, kwargs, labeldim)
    series!(ax, args...; labels=attributes.labels, kwargs...)
end

"""
Plot a multivariate time series on a position in a figure
"""
function tplot(gp::GridPosition, ta::AbstractDimArray; labeldim=nothing, kwargs...)
    args, attributes = _series(ta, kwargs, labeldim)
    series(gp, args...; attributes...)
end


"""
Lay out multiple time series on the same figure across different panels (rows)
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
    f
end


Base.show(io::IO, fg::FigureAxes) = show(io, fg.figure)
Base.display(fg::FigureAxes) = display(fg.figure)

Base.iterate(fg::FigureAxes) = iterate((fg.figure, fg.axes))
Base.iterate(fg::FigureAxes, i) = iterate((fg.figure, fg.axes), i)