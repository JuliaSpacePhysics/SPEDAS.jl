# Quickstart

## Get data with Speasy

```@example share
using Speasy
spz = speasy()
using SpaceTools

# da = get_data("amda/imf", "2016-6-2", "2016-6-5")
da = get_data("cda/OMNI_HRO_1MIN/Pressure", "2016-6-2", "2016-6-5")
```

## Plot the data

```@example share
tplot([da])
```