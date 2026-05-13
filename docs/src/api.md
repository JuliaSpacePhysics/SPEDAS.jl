# API Reference

```@index
Pages = ["api.md"]
```

## Data Model

```@autodocs
Modules = [SPEDAS.SpaceDataModel]
```

## Coordinate Transformations

See [GeoCotrans.jl](https://juliaspacephysics.github.io/GeoCotrans.jl) for more details. IRBEM.jl can be loaded separately and selected with `backend = IRBEM`.

```@docs
cotrans
```

## SPEDAS

```@autodocs
Modules = [SPEDAS]
```

## Timeseries Utilities

```@autodocs
Modules = [SPEDAS.TimeseriesUtilities]
```
