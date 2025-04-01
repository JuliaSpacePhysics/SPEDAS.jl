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
tplot([da])
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