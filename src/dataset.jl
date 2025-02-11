abstract type AbstractDataSet end

struct DataSet <: AbstractDataSet
    name::String
    parameters::Vector
    metadata::Dict
end

DataSet(name, parameters; metadata=Dict()) = DataSet(name, parameters, metadata)

meta(ta::DataSet) = ta.metadata
Base.length(tas::DataSet) = length(tas.parameters)
Base.getindex(tas::DataSet, i) = tas.parameters[i]
Base.map(f, tas::DataSet) = map(f, tas.parameters)

title(ta::DataSet) = ta.name

function axis_attributes(ta::DataSet; add_title=false, kwargs...)
    attrs = Attributes(; kwargs...)
    add_title && (attrs[:title] = title(ta))
    attrs
end

"Setup the panel on a position and plot multiple time series on it"
function tplot_panel(gp, tas::DataSet, args...; add_title=false, kwargs...)
    ax = Axis(gp; axis_attributes(tas; add_title)...)
    plots = map(tas) do ta
        tplot_panel!(ax, ta, args...; kwargs...)
    end
    AxisPlots(ax, plots)
end
