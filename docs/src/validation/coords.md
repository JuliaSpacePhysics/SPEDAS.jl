# Compare Coordinate Transformations with IRBEM and PySPEDAS

See [Coordinate Systems](../explanations/coords.md) for more information.


!!! note "Takeaway"
    Julia's implementation yields results very close to IRBEM's and PySPEDAS's one, and is an order of magnitude faster. (Julia's one uses finer interpolation than IRBEM's and PySPEDAS's one to determine IGRF coefficients and sun's direction, leading to more accurate transformations.)

References: [`cotrans`](@ref), [test_cotrans.py - PySPEDAS](https://github.com/spedas/pyspedas/blob/master/pyspedas/cotrans_tools/tests/cotrans.py)

## Setup


```@example coords
using PySPEDAS
using SPEDAS
using PythonCall
using DimensionalData
using Chairmarks
using Test
```

Setup using PySPEDAS test cases.

```@example coords
@py import pyspedas.cotrans_tools.tests.cotrans: CotransTestCases

pytest = CotransTestCases()
pytest.test_cotrans()

trange = ["2010-02-25/00:00:00", "2010-02-25/23:59:59"]
pyspedas.projects.themis.state(trange, probe="a", time_clip=true)

tha_pos = PySPEDAS.get_data(DimArray, "tha_pos")
tha_pos_gse = PySPEDAS.get_data(DimArray, "tha_pos_gse")
jl_tha_pos = set(tha_pos, Dim{:time}=>Ti)
jl_tha_pos_gse = set(tha_pos_gse, Dim{:time}=>Ti)
```

## Validation

Transform coordinates using Julia native implementation, IRBEM, and PySPEDAS.

GEI <-> GEO

```@example coords
jl_tha_pos_geo = gei2geo(jl_tha_pos)
ir_tha_pos_geo = cotrans(jl_tha_pos', "GEI", "GEO")'
py_tha_pos_geo = PySPEDAS.get_data(DimArray, "tha_pos_new_geo")

@test jl_tha_pos_geo ≈ parent(py_tha_pos_geo)
@test jl_tha_pos_geo ≈ ir_tha_pos_geo
```

GEI <-> GSM

```@example coords
jl_tha_pos_gsm = gei2gsm(jl_tha_pos)
ir_tha_pos_gsm = cotrans(jl_tha_pos', "GEI", "GSM")'
pyspedas.cotrans("tha_pos", "tha_pos_new_gsm", coord_in="GEI", coord_out="GSM")
py_tha_pos_gsm = PySPEDAS.get_data(DimArray, "tha_pos_new_gsm")

@test isapprox(jl_tha_pos_gsm, parent(py_tha_pos_gsm), rtol=1e-5)
@test isapprox(jl_tha_pos_gsm, ir_tha_pos_gsm, rtol=1e-3)
```

GSE <-> GSM

```@example coords
jl_tha_pos_gsm = gse2gsm(jl_tha_pos_gse)
ir_tha_pos_gsm = cotrans(jl_tha_pos_gse', "GSE", "GSM")'
pyspedas.cotrans("tha_pos_gse", "tha_pos_new_gsm", coord_in="GSE", coord_out="GSM")
py_tha_pos_gsm = PySPEDAS.get_data(DimArray, "tha_pos_new_gsm")

@test isapprox(jl_tha_pos_gsm, parent(py_tha_pos_gsm), rtol=1e-5)
@test isapprox(jl_tha_pos_gsm, ir_tha_pos_gsm, rtol=1e-3)
```


Validate results: `GEI/GEO` transformations is quite accurate, while there are some differences in `GSE/GSM` transformations between Julia native implementation and IRBEM's one.

## Benchmark

Depends on the transformation, Julia's implementation is about 10-40 times faster than IRBEM's (Fortran) implementation, and 20-50 times faster than PySPEDAS's (Python) implementation.

```@example coords
@b gei2geo($jl_tha_pos), cotrans($jl_tha_pos', "GEI", "GEO"), pyspedas.cotrans("tha_pos", "tha_pos_new_geo", coord_in="GEI", coord_out="GEO")
```

```@example coords
@b gei2gsm($jl_tha_pos), cotrans($jl_tha_pos', "GEI", "GSM"), pyspedas.cotrans("tha_pos", "tha_pos_new_gsm", coord_in="GEI", coord_out="GSM")
```

```@example coords
@b gse2gsm($jl_tha_pos_gse), cotrans($jl_tha_pos_gse', "GSE", "GSM"), pyspedas.cotrans("tha_pos_gse", "tha_pos_new_gsm", coord_in="GSE", coord_out="GSM")
```