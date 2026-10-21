# Time Series

See [TimeseriesUtilities.jl](https://beforerr.github.io/TimeseriesUtilities.jl) for a collection of utilities and tutorials to simplify common time series analysis.

- [outliers](https://beforerr.github.io/TimeseriesUtilities.jl/dev/outliers/): remove spikes from signal.

## Time Series Resampling Methods

> The adjustment of a segment of time-series data set to produce a segment of data which is *scientifically equivalent* but with data sample timing strictly simultaneous with that of another data set is called “resampling”. [paschmannAnalysisMethodsMultispacecraft2000; Chapter 2](@citet)

`tinterp`, `tinterp_na` and `tsync` (TimeseriesUtilities.jl, re-exported) resample series onto common times; see the [TimeseriesUtilities.jl docs](https://beforerr.github.io/TimeseriesUtilities.jl/dev/).
