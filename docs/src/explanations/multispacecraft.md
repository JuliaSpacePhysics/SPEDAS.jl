# Multi-spacecraft analysis methods

This page demonstrates the use of multi-spacecraft analysis for MMS data. For more details about the package, see [MultiSpacecraftAnalysis.jl](https://juliaspacephysics.github.io/MultiSpacecraftAnalysis.jl/dev/).

```@example mms
using SPEDAS: tlingradest, setmeta
using Dates
using CDAWeb
using DimensionalData
using CairoMakie, SpacePhysicsMakie

t0 = DateTime("2016-12-09T09:02")
t1 = DateTime("2016-12-09T09:04")
fgm_datasets = ntuple(4) do probe
    get_data("MMS$(probe)_FGM_BRST_L2", t0, t1)
end

# Load data from CDF files into memory, MMS FGM data comes with magnitude
fields = ntuple(4) do probe
    DimArray(fgm_datasets[probe]["mms$(probe)_fgm_b_gse_brst_l2"])[X(1:3), Ti(t0..t1)]
end

tplot(fields)
```

```@example mms
mec_datasets = ntuple(4) do probe
    get_data("MMS$(probe)_MEC_BRST_L2_EPHT89D", t0, t1)
end

positions = ntuple(4) do probe
    DimArray(mec_datasets[probe]["mms$(probe)_mec_r_gse"])[Ti(t0..t1)]
end

out = tlingradest(fields, positions)
```

```@example mms
using LinearAlgebra
using Unitful

unitify(x, unit) = x isa Quantity ? x : x * unit

"""
Calculate the parallel component of current density with respect to magnetic field, given `𝐁` and Curl of magnetic field vector `curl𝐁`.
"""
function jparallel(𝐁, curl𝐁)
    𝐁 = unitify.(𝐁, u"nT")
    curl𝐁 = unitify.(curl𝐁, u"nT/km")
    J_parallel = dot(curl𝐁, 𝐁) / norm(𝐁) / Unitful.μ0
    return J_parallel |> u"nA/m^2"
end

jparallel(B::AbstractMatrix, curl𝐁::AbstractMatrix; dim = 2) = jparallel.(eachslice(B; dims = dim), eachslice(curl𝐁; dims = dim))

jp = jparallel(out.Bbc, out.curl)
jp = setmeta(jp, ylabel = "Jparallel\n(nA/m²)")
tplot((out.Bbc, out.div, out.curl, out.curv, jp))
```

## Validation with PySPEDAS

```@example mms
using PySPEDAS
using PythonCall
using Unitful
using Test
@py import pyspedas.projects.mms: mec, fgm, curlometer, lingradest
trange = string.([t0, t1])
fgm_vars = @py fgm(probe=[1, 2, 3, 4], trange=trange, data_rate="brst", time_clip=true, varformat="*_gse_*")
mec_vars = @py mec(probe=[1, 2, 3, 4], trange=trange, data_rate="brst", time_clip=true, varformat="*_r_gse")
posits_py = ["mms1_mec_r_gse", "mms2_mec_r_gse", "mms3_mec_r_gse", "mms4_mec_r_gse"]
fields_py = ["mms1_fgm_b_gse_brst_l2", "mms2_fgm_b_gse_brst_l2", "mms3_fgm_b_gse_brst_l2", "mms4_fgm_b_gse_brst_l2"]
curlometer_vars = curlometer(fields=fields_py, positions=posits_py)
jp_py = PySPEDAS.get_data("jpar")

# Due to interpolation, pyspedas first and last values are NaN
@test (jp ./ u"A/m^2" .|> NoUnits) ≈ (jp_py[2:end-1]) atol=1e-5
```

### Benchmark

```@example mms
using Chairmarks
@b tlingradest($fields, $positions), lingradest(fields=$fields_py, positions=$posits_py), curlometer(fields=$fields_py, positions=$posits_py)
```

Julia is about 100 times faster than Python for similar workflows.

## Dataset info

```@example mms
fgm_datasets[1]
```

# References

- https://github.com/spedas/mms-examples/blob/master/basic/Curlometer%20Technique.ipynb
