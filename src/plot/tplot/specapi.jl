import Makie.SpecApi as S

# S.Colorbar(plots; label=clabel(ta))] # TODO: find a way to make SpecApi.Colorbar work on grid positions

function plot2spec(da; resample=(; verbose=true), kwargs...)
    da = SPEDAS.resample(da; resample...)

    if !isspectrogram(da)
        plot2spec(LinesPlot, da; kwargs...)
    else
        plot2spec(SpecPlot, da; kwargs...)
    end
end

"""
    tplot_panel_s!(ax::Axis, data; kwargs...)

Plot data on an axis.
"""
function tplot_panel_s!(ax::Axis, data; kwargs...)
    specs = plot2spec(data; kwargs...)
    return plotlist!(ax, specs)
end