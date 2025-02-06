# Tplot

`tplot` is a versatile plotting utility that handles various time series formats including vectors, matrices, functions, and strings. It renders data as line plots, series plots, heatmaps, or spectrograms.

It also offers flexible visualization options, allowing you to display multiple time series either across separate panels or overlaid within the same panel.

Built on `Makie`, `tplot` provides both interactive exploration capabilities and publication-quality output. It features dynamic data loading during zoom/pan operations, efficiently retrieving and rendering data on demand.

```@docs
tplot
tplot_panel
tplot_panel!
```

## References

- [PyTplot](https://pyspedas.readthedocs.io/en/latest/pytplot.html)
- [InteractiveViz.jl](https://github.com/org-arl/InteractiveViz.jl)