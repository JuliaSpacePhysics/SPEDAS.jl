# Parker Solar Probe (PSP)

```@docs
SPEDAS.PSP
SPEDAS.PSP.psp
```

## Instruments

```@autodocs
Modules = [SPEDAS.PSP]
Filter = t -> t isa Instrument
```

## Datasets

```@autodocs
Modules = [SPEDAS.PSP]
Filter = t -> t isa AbstractDataSet
```

## Examples

```@example PSP
using SPEDAS
using Unitful
using SPEDAS.PSP

n = PSP.n
```

```@example PSP
tplot(n, "2021-08-09T06", "2021-08-10T18")
```

```@example PSP
# Overlay multiple datasets in the same panel
tplot([n], "2021-08-09T06", "2021-08-10T18")
```

## References

- [Wikipedia](https://en.wikipedia.org/wiki/Parker_Solar_Probe)