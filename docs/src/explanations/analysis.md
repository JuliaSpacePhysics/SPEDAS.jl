# Analysis Tools

```@docs; canonical=false
current_density
```

## Utilities

Most of the utilities operate on the time dimension by default, but you can specify other dimensions using the `dims` parameter. See the [API reference](../api.md) for a complete list of available functions and their parameters.

These utilities are designed to simplify common data analysis tasks for time series data. While most are thin wrappers around existing Julia functions, they ensure proper handling of metadata and dimensions specific to space physics datasets.

### Arithmetic

```@docs; canonical=false
tcross
tderiv
tdot
tsubtract
```

### Time-Domain Operations

```@docs; canonical=false
tclip
tview
tmask
tshift
```
