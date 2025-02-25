# Time Series Resampling Methods

> The adjustment of a segment of time-series data set to produce a segment of data which is *scientifically equivalent* but with data sample timing strictly simultaneous with that of another data set is called “resampling”. [paschmannAnalysisMethodsMultispacecraft2000; Chapter 2](@citet)

## Time Series Interpolation

Flexible time series interpolation through the `tinterp` function.

This function supports interpolation for both vector-like and matrix-like time series. Other features include:

- Returns scalar value for single time point interpolation
- Returns DimArray for multiple time points interpolation, preserving metadata and dimensions. 
- Customizable interpolation method through the `interp` keyword argument

```@docs
tinterp
```

### Basic Usage

```julia
using SpaceTools
using Dates
using DataInterpolations

# Interpolate at a single time point
val = tinterp(time_series, DateTime("2023-01-01T12:00:00"))

# Interpolate at multiple time points
new_times = DateTime("2023-01-01"):Hour(1):DateTime("2023-01-02")
interpolated = tinterp(time_series, new_times; interp=CubicSpline)
```

## Utilities

```@docs
dropna
rectify_datetime
```