# Tplot

`tplot` is a versatile plotting utility that handles various time series formats including vectors, matrices, functions, and strings (product IDs). It renders data as line plots, series plots, heatmaps, or spectrograms.

`tplot` offers flexible visualization options, allowing you to display multiple time series either across separate panels or overlaid within the same panel.

`tplot` seamlessly integrates with [`Speasy.jl`](https://github.com/SciQLop/Speasy.jl), automatically downloading and converting data to `DimArray` when given a product ID string.

Built on `Makie`, `tplot` provides both interactive exploration capabilities and publication-quality output. It features dynamic data loading during zoom/pan operations, efficiently retrieving and rendering data on demand.

```@docs
tplot
tplot_panel
tplot_panel!
```

## References

- [PyTplot](https://pyspedas.readthedocs.io/en/latest/pytplot.html)
- [InteractiveViz.jl](https://github.com/org-arl/InteractiveViz.jl)
- [SciQLop](https://github.com/SciQLop/SciQLop) : A python application built on top of `Qt` to explore multivariate time series effortlessly,