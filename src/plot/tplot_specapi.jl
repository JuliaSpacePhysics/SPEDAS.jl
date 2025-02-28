# S.Colorbar(plots; label=clabel(ta))] # TODO: find a way to make SpecApi.Colorbar work on grid positions

function tplot_spec(da::AbstractDimMatrix; labels=labels(da), samples=10000, kwargs...)
    x = dims(da, Ti).val

    if length(x) > samples
        indices = round.(Int, range(1, length(x), length=samples))
        x = x[indices]
        da = da[indices, :]
        @info "Data resampled to $samples points"
    end

    if !isspectrogram(da)
        map(eachcol(da.data), labels) do y, label
            S.Lines(x, y; label, kwargs...)
        end
    else
        S.Heatmap(x, spectrogram_y_values(da), da.data; heatmap_attributes(da; kwargs...)...)
    end
end

tplot_spec(f::Function, tmin, tmax; kwargs...) = tplot_spec(f(tmin, tmax); kwargs...)
tplot_spec(args...; kwargs...) = tplot_spec(get_data(args...); kwargs...)

"""
    tplot_panel_s!(ax::Axis, data; kwargs...)

Plot data on an axis.
"""
function tplot_panel_s!(ax::Axis, data; kwargs...)
    specs = tplot_spec(data; kwargs...)
    return plotlist!(ax, specs)
end