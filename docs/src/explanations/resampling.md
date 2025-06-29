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
tinterp_nans
tsync
resample
tresample
```
