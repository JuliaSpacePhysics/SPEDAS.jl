# Time Series Utilities

The following utilities are designed to simplify common data analysis tasks for time series data. While most are thin wrappers around existing Julia functions, they ensure proper handling of metadata and dimensions.

Most of the utilities operate on the time dimension by default, but you can specify other dimensions using the `dim` or `query` parameter.


## Statistics

```@docs; canonical=false
tstat
tmean
tmedian
tsum
tvar
tstd
tsem
```

## Arithmetic

```@docs; canonical=false
tcross
tderiv
tdot
tsubtract
```

## Time-Domain Operations

```@docs; canonical=false
tclip
tview
tmask
tshift
```
