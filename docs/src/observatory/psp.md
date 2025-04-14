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
using Speasy: SpeasyProduct
using SPEDAS
using Unitful

n = DataSet("Density",
    [
        SpeasyProduct("PSP_SWP_SPI_SF00_L3_MOM/DENS"; labels=["SPI Proton"]),
        Base.Fix2(*, u"cm^-3") ∘ SpeasyProduct("PSP_SWP_SPC_L3I/np_moment"; labels=["SPC Proton"]),
        SpeasyProduct("PSP_FLD_L3_RFS_LFR_QTN/N_elec"; labels=["RFS Electron"]),
        SpeasyProduct("PSP_FLD_L3_SQTN_RFS_V1V2/electron_density"; labels=["SQTN Electron"])
    ]
)
```

```@example PSP
tplot(n, "2021-08-09T06", "2021-08-10T18")
```

## References

- [Wikipedia](https://en.wikipedia.org/wiki/Parker_Solar_Probe)