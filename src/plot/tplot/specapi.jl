import Makie.SpecApi as S

# S.Colorbar(plots; label=clabel(ta))] # TODO: find a way to make SpecApi.Colorbar work on grid positions

function tplot_spec(da; verbose=true, kwargs...)
    da = resample(da; verbose)

    if !isspectrogram(da)
        Makie.convert_arguments(LinesPlot, da)
    else
        x = dims(da, Ti).val
        S.Heatmap(x, spectrogram_y_values(da), da.data; heatmap_attributes(da; kwargs...)...)
    end
end

"""
    tplot_panel_s!(ax::Axis, data; kwargs...)

Plot data on an axis.
"""
function tplot_panel_s!(ax::Axis, data; kwargs...)
    specs = tplot_spec(data; kwargs...)
    return plotlist!(ax, specs)
end