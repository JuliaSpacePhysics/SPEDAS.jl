# Validation with PySPEDAS

```@example pyspedas
using PySPEDAS
using SpaceTools
using PythonCall
using DimensionalData
using PySPEDAS: get_data
using CairoMakie
using SpaceTools: tplot
using NaNMath
using Chairmarks
```

## Wave polarization

https://github.com/spedas/mms-examples/blob/master/advanced/Wave_polarization_using_SCM_data.ipynb
https://github.com/spedas/pyspedas/blob/master/pyspedas/analysis/tests/test_twavpol.py

```@example pyspedas
@py import pyspedas.analysis.tests.test_twavpol: TwavpolDataValidation
TwavpolDataValidation.setUpClass()

thc_scf_fac = get_data(DimArray, "thc_scf_fac")
py_tvars = [
    "thc_scf_fac_powspec",
    "thc_scf_fac_degpol",
    "thc_scf_fac_waveangle",
    "thc_scf_fac_elliptict",
    "thc_scf_fac_helict",
]
py_result = get_data(DimStack, py_tvars)
res = twavpol(thc_scf_fac)

f = Figure(;size=(1200, 800))
tplot(f[1,1], py_result)
tplot(f[1,2], res)
f
```

### Benchmark

```@example pyspedas
@b twavpol(thc_scf_fac), pyspedas.twavpol("thc_scf_fac")
```

Julia is about 100 times faster than Python.