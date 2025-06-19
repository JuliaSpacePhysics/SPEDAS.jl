# Quickstart

We provide a few ways to load data, please see [Data](../explanations/data.md) for a detailed explanation of the data formats and retrieval methods.

## Get data with Speasy

[Speasy.jl](https://github.com/SciQLop/Speasy.jl) provides functions to load data from main Space Physics WebServices (CDA,SSC,AMDA,..).

It could be installed using `using Pkg; Pkg.add("Speasy")`.

```@example share
using Speasy: get_data
using SPEDAS

# da = get_data("amda/imf", "2016-6-2", "2016-6-5")
da = get_data("cda/OMNI_HRO_1MIN/Pressure", "2016-6-2", "2016-6-5")
```

### Plot the data

```@example share
tplot(da)
```

## Get data using Heliophysics Application Programmer's Interface (HAPI)

[HAPIClient.jl](https://github.com/JuliaSpacePhysics/HAPIClient.jl) provides functions to load data from HAPI-compliant servers.

It could be installed using `using Pkg; Pkg.add("HAPIClient")`.

```@example hapi
using HAPIClient: get_data

da = get_data("CDAWeb/AC_H0_MFI/Magnitude,BGSEc", "2001-1-2", "2001-1-2T12")
```

### Plot the data

```@example hapi
using SPEDAS

tplot(da)
```

## Get data with PySPEDAS

[PySPEDAS.jl](https://github.com/JuliaSpacePhysics/PySPEDAS.jl) provides a Julia interface to the [PySPEDAS](https://github.com/spedas/pyspedas) Python package, offering a similar API for Julia users to utilize the existing Python routines.

It could be installed using `using Pkg; Pkg.add("https://github.com/JuliaSpacePhysics/PySPEDAS.jl")`.

```@example pyspedas
using SPEDAS: tplot
using PySPEDAS.Projects
using DimensionalData
using CairoMakie

da = themis.fgm(["2020-04-20/06:00", "2020-04-20/08:00"], time_clip=true, probe="d");
keys(da)
# Same as more verbose `pyspedas.projects.themis.fgm(...)`
```

### Plot the data

```@example pyspedas
f = Figure()
tplot(f[1,1], [da.thd_fgs_gsm, da.thd_fgs_btotal])
tplot(f[2,1], [DimArray(da.thd_fgl_gsm), DimArray(da.thd_fgl_btotal)])
f
```
