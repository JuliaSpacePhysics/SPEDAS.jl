# Space Physics Plotting

[SpacePhysicsMakie.jl](https://github.com/JuliaSpacePhysics/SpacePhysicsMakie.jl) provides a set of utilities for visualizing space physics data.

`tplot` is a versatile plotting utility that handles various time series formats including vectors, matrices, functions, and strings (product IDs). It renders data as line plots, series plots, heatmaps, or spectrograms.

`tplot` offers flexible visualization options, allowing you to display multiple time series either across separate panels or overlaid within the same panel.

`tplot` seamlessly integrates with [`Speasy.jl`](https://github.com/SciQLop/Speasy.jl), automatically downloading and converting data to `DimArray` when given a product ID string.

Built on `Makie`, `tplot` provides both interactive exploration capabilities and publication-quality output. It features dynamic data loading during zoom/pan operations, efficiently retrieving and rendering data on demand.

```@docs
tplot
tplot_panel
tplot_panel!
```

## Function as `tplot` argument for interactive exploration

`tplot` can handle functions that accept time intervals as arguments.
This allows for creating interactive plots where data is dynamically fetched. So instead of the two-step process:

1. Fetch data: `da = f(t0, t1)`
2. Plot data: `tplot(da)`

We can combine these steps into a single command:

`tplot(f, t0, t1)`

This approach enables efficient interactive exploration of time series.

!!! note
    
    For real-time interactivity, consider using the `GLMakie` backend instead of `CairoMakie` although it is possible to use `tlims!` or `xlims!` to update the plot dynamically.

## Data Transformation

Before plotting, data goes through a transformation pipeline to ensure it's in a plottable format (e.g., `DimArray`).

```@docs
transform
```

You can extend the transformation system by defining methods for your types:

```julia
# Convert MyType to DimArray for plotting
transform(x::MyType) = DimArray(x.data)
```

## Related packages

- [PyTplot](https://pyspedas.readthedocs.io/en/latest/pytplot.html)
- [InteractiveViz.jl](https://github.com/org-arl/InteractiveViz.jl)
- [SciQLop](https://github.com/SciQLop/SciQLop) : A python application built on top of `Qt` to explore multivariate time series effortlessly,