# https://github.com/MakieOrg/AlgebraOfGraphics.jl/blob/master/src/entries.jl
struct FigureAxes
    figure
    axes::AbstractArray{Axis}
end

struct AxisPlots
    axis::Axis
    plots
end

struct PanelAxesPlots
    pos
    axisPlots::Vector{AxisPlots}
end

PanelAxesPlots(pos, ap::AxisPlots) = PanelAxesPlots(pos, [ap])

function Base.getproperty(obj::PanelAxesPlots, sym::Symbol)
    sym in fieldnames(PanelAxesPlots) && return getfield(obj, sym)
    getproperty.(obj.axisPlots, sym)
end


Base.display(fg::FigureAxes) = display(fg.figure)
Base.show(io::IO, fg::FigureAxes) = show(io, fg.figure)
Base.show(io::IO, m::MIME, fg::FigureAxes) = show(io, m, fg.figure)
Base.show(io::IO, ::MIME"text/plain", fg::FigureAxes) = print(io, "FigureAxes()")
Base.showable(mime::MIME{M}, fg::FigureAxes) where {M} = showable(mime, fg.figure)

Base.iterate(fg::FigureAxes) = iterate((fg.figure, fg.axes))
Base.iterate(fg::FigureAxes, i) = iterate((fg.figure, fg.axes), i)