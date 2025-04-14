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
import Speasy
using SPEDAS: tplot
using SPEDAS.PSP

PSP.n
```

```@example PSP
tplot(PSP.n, "2021-08-09", "2021-08-10")
```

## References

- [Wikipedia](https://en.wikipedia.org/wiki/Parker_Solar_Probe)