# Dynamic power spectra calculations

```@example mms
using CDAWeb
using SPEDAS
using DimensionalData
using CairoMakie, SpacePhysicsMakie

t0 = "2015-10-16"
t1 = "2015-10-16T03"

da = getdata(cda"MMS4_SCM_SRVY_L2_SCSRVY/mms4_scm_acb_gse_scsrvy_srvy_l2", t0, t1) |> DimArray

tplot(da)
```

```@example mms
using DSP

metadata = Dict("DISPLAY_TYPE" => "spectrogram", "SCALETYP" => log10, :ylabel => "Frequency (Hz)", :yscale => log10)
pvar = setmeta(pspectrum(da; nfft = 512), metadata)
f = tplot(pvar[:,:,1])
ylims!(5e-2, 2e1)
f
```

## References

- [Search-coil Magnetometer (SCM) - pyspedas](https://github.com/spedas/mms-examples/blob/master/basic/Search-coil%20Magnetometer%20(SCM).ipynb)

