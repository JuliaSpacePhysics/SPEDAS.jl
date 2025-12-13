# Dynamic power spectra calculations

```@example mms
using CDAWeb
using SPEDAS
using DimensionalData
using CairoMakie
using SpacePhysicsMakie

t0 = "2015-10-16"
t1 = "2015-10-16T03"

ds = CDAWeb.get_dataset("MMS4_SCM_SRVY_L2_SCSRVY", t0, t1; clip=true)
da = DimArray(ds["mms4_scm_acb_gse_scsrvy_srvy_l2"])

tplot(da)
```

```@example mms
nboxpoints = 512

pvar = pspectrum(da)
tplot(pvar[:,:,1])
```

## References

- [Search-coil Magnetometer (SCM) - pyspedas](https://github.com/spedas/mms-examples/blob/master/basic/Search-coil%20Magnetometer%20(SCM).ipynb)
