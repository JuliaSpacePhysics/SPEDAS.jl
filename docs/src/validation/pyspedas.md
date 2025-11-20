# Validation with PySPEDAS

!!! note "Performance Notes"
    - Calling Python from Julia (via [PythonCall.jl](https://github.com/JuliaPy/PythonCall.jl)) introduces only a negligible overhead, typically within nanoseconds.
    - Memory allocations shown in Julia benchmarks do not include allocations that occur within Python. To measure Python-side allocations, profiling should be done directly in Python.
    - The documentation and benchmarks are generated using GitHub Actions. Running the code locally with multiple threads (e.g., by setting `JULIA_NUM_THREADS`) can yield even greater performance improvements for Julia.

```@example pyspedas
using PySPEDAS
using SPEDAS
using PythonCall
using DimensionalData
using PySPEDAS: get_data
using CairoMakie, SpacePhysicsMakie
```

## Wave polarization

References: [`twavpol`](@ref), [test_twavpol.py - PySPEDAS](https://github.com/spedas/pyspedas/blob/master/pyspedas/analysis/tests/test_twavpol.py), [Wave polarization using SCM data - PySPEDAS](https://github.com/spedas/mms-examples/blob/master/advanced/Wave_polarization_using_SCM_data.ipynb)

```@example pyspedas
@py import pyspedas.analysis.tests.test_twavpol: TwavpolDataValidation
TwavpolDataValidation.setUpClass()

thc_scf_fac = get_data("thc_scf_fac") |> DimArray
py_tvars = [
    "thc_scf_fac_powspec",
    "thc_scf_fac_degpol",
    "thc_scf_fac_waveangle",
    "thc_scf_fac_elliptict",
    "thc_scf_fac_helict",
]
# PySPEDAS returns non valid values at the first and last frequency bin, the last time bin is also not valid
_subset_py(x) = x[1:end-1,2:end-1]
py_result = DimStack(_subset_py.(DimArray.(get_data.(py_tvars))))
py_result.thc_scf_fac_powspec.metadata[:colorscale] = log10
py_result.thc_scf_fac_helict.metadata[:colorscale] = identity
res = twavpol(thc_scf_fac)

f = Figure(; size=(1200, 800))
tplot(f[1,1], py_result)
tplot(f[1,2], res)
f
```

We can also use single value decomposition (SVD) technique to calculate the wave polarization.

```@example pyspedas
res = twavpol_svd(thc_scf_fac)
tplot(res)
```

### Benchmark

```@example pyspedas
using Chairmarks

@b twavpol(thc_scf_fac), twavpol_svd(thc_scf_fac), pyspedas.twavpol("thc_scf_fac")
```

Julia is about 100 times faster than Python.


## Minimum variance analysis

References: [`mva_eigen`](@ref), [test_minvar.py - PySPEDAS](https://github.com/spedas/pyspedas/blob/master/pyspedas/cotrans_tools/tests/test_minvar.py)

```@example pyspedas
@py import pyspedas.cotrans_tools.tests.test_minvar: TestMinvar
@py import pyspedas.cotrans_tools.minvar_matrix_make: minvar_matrix_make

isapprox_eigenvector(v1, v2) = isapprox(v1, v2) || isapprox(v1, -v2)

pytest = TestMinvar()
pytest.setUpClass()

thb_fgs_gsm = get_data("idl_thb_fgs_gsm_mvaclipped1") |> DimArray
jl_mva_eigen = mva_eigen(thb_fgs_gsm)
jl_mva_mat = jl_mva_eigen.vectors
jl_mva_vals = jl_mva_eigen.values

py_mva_vals = PyArray(pytest.vals.y) |> vec
py_mva_mat = PyArray(pytest.mat.y[0])'
@assert isapprox(jl_mva_vals, py_mva_vals)
@assert all(isapprox_eigenvector.(eachcol(jl_mva_mat), eachcol(py_mva_mat)))
```

Since eigenvectors are only unique up to sign; therefore, the test checks if each Julia eigenvector is approximately equal to the corresponding Python eigenvector or its negative.
Test passed.

### Benchmark

```@example pyspedas
@b mva_eigen(thb_fgs_gsm), minvar_matrix_make("idl_thb_fgs_gsm_mvaclipped1")
```

Julia demonstrates a performance advantage of approximately 1000 times over Python, with significantly reduced memory allocations. 
Moreover, Julia's implementation is generalized for N-dimensional data.
