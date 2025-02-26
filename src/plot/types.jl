struct AxisPlots
    axis
    plots
end

struct PanelAxesPlots
    pos
    axisPlots::Vector{AxisPlots}
end

PanelAxesPlots(gps, ap) = PanelAxesPlots(gps, [ap])

function Base.getproperty(obj::PanelAxesPlots, sym::Symbol)
    sym in fieldnames(PanelAxesPlots) && return getfield(obj, sym)
    getproperty.(obj.axisPlots, sym)
end
