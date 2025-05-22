# Quickstart

## Get data with Speasy

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

```@example pyspedas
using SPEDAS: tplot
using PySPEDAS.Projects
using DimensionalData
using CairoMakie

da = themis.fgm(["2020-04-20/06:00", "2020-04-20/08:00"], time_clip=true, probe="d")
# The same as more verbose `pyspedas.projects.themis.fgm(...)`
```

### Plot the data

```@example pyspedas
f = Figure()
tplot(f[1,1], [da.thd_fgs_gsm, da.thd_fgs_btotal])
tplot(f[2,1], [DimArray(da.thd_fgl_gsm), DimArray(da.thd_fgl_btotal)])
f
```
