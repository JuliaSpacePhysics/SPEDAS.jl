# `tplot` and `tplot_panel`

The `tplot` system provides a unified interface for time series visualization:

- `tplot_panel`: Creates single panel plots with support for multiple data types
- `tplot`: Combines multiple panels into a figure

Both functions are built on Makie's recipe system, allowing customization through plot attributes and functions.

```@example tplot
using CairoMakie, SpacePhysicsMakie
using Unitful
```

## Flexible and composable `tplot_panel`

```@example tplot
# Create sample data
n = 24
data1 = rand(n) * 4u"km/s"  # Vector with units
data2 = rand(n) * 4u"km/s"  # Same units
data3 = rand(n) * 1u"eV"    # Different units
data4 = rand(n,4)           # Matrix (for heatmap)

f = Figure()

# Basic Plotting
tplot_panel(f[1, 1], data1; axis=(;title="Single time series"))

# Multiple Series (same y-axis)
tplot_panel(f[2, 1], [data1, data2]; axis=(;title="Multiple series"), plottype=Lines)

# Dual Y-Axes (different units)
tplot_panel(f[3, 1], (data1, data3); axis=(;title="Dual y-axes"))

# Matrix as series
tplot_panel(f[1, 2], data4'; axis=(;title="Series"), plottype=Series)

# Overlay Series on Heatmap
tplot_panel(f[2, 2], [data4, data1, data2]; axis=(;title="Heatmap with overlays"))

# XY Plot (non-time series)
tplot_panel(f[3, 2], data2, data3; axis=(;title="XY plot (fallback)"))

f
```

## Combining Multiple Panels

You can also combine multiple panels into a single figure using `tplot`. By default, it links the x-axis of each panel and layouts the panels in a single column.

```@example tplot
tvars = [
    data1,                  
    [data1, data2],        
    (data1, data3),
]
tplot(tvars)
```

`tplot` also supports plotting on `GridPosition` and `GridSubposition` objects

```@example tplot
f=Figure()
tvars2 = [
    data4,
    [data4, data1, data2],
    (data2, data3)
]
tplot(f[1,1], tvars)
tplot(f[1,2], tvars2)
f
```
