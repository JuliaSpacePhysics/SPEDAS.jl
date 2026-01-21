# Quickstart

Here, we show an example of loading data from CDAWeb using Speasy.jl and visualizing it with SpacePhysicsMakie.jl. For additional approaches to retrieving data, see the [Julia Space Physics Tutorials](https://juliaspacephysics.github.io/tutorials/data_loading/). You can also refer to the [Data](../explanations/data.md) page for a detailed explanation of supported data formats and retrieval methods.

## Get data with Speasy

[Speasy.jl](https://github.com/SciQLop/Speasy.jl) provides functions to load data from main Space Physics WebServices (CDA,SSC,AMDA,..).

It could be installed using `using Pkg; Pkg.add("Speasy")`.

```@example share
using Speasy
using CairoMakie, SpacePhysicsMakie

# da = get_data("amda/imf", "2016-6-2", "2016-6-5")
data = Speasy.get_data("cda/OMNI_HRO_1MIN/Pressure", "2016-6-2", "2016-6-3"; sanitize=true)
```

### Plot the data

```@example share
tplot(data)
```