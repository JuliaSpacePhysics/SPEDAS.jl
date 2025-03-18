# Project Modules

See [Data Model](./explanations/data_model.md) section for more details.

## Time History of Events and Macroscale Interactions during Substorms (THEMIS)

```@docs
SPEDAS.THEMIS
SPEDAS.THEMIS.themis
```

```@autodocs
Modules = [SPEDAS.THEMIS]
Filter = t -> !(t isa Project)
```

## Magnetospheric Multiscale (MMS)

```@docs
SPEDAS.MMS
SPEDAS.MMS.mms
```

```@autodocs
Modules = [SPEDAS.MMS]
Filter = t -> !(t isa Project)
```

## Parker Solar Probe (PSP)

```@docs
SPEDAS.PSP
SPEDAS.PSP.psp
```

```@autodocs
Modules = [SPEDAS.PSP]
Filter = t -> !(t isa Project)
```

## References

- [PySPEDAS Projects](https://pyspedas.readthedocs.io/en/latest/projects.html)