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
pvar = setmeta(pspectrum(da; nfft = 512), yscale=log10)
f = tplot(pvar[:,:,1])
ylims!(5e-2, 2e1)
f
```

## References

- [Search-coil Magnetometer (SCM) - pyspedas](https://github.com/spedas/mms-examples/blob/master/basic/Search-coil%20Magnetometer%20(SCM).ipynb)

