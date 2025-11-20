# Data Formats and Retrieval

We support many multidimensional data formats via the interface defined in [SpaceDataModel.jl](https://github.com/JuliaSpacePhysics/SpaceDataModel.jl). Commonly used data formats include: `DimArray` in [DimensionalData.jl](https://github.com/rafaqz/DimensionalData.jl), `CDFVariable` in [CDFDatasets.jl](https://juliaspacephysics.github.io/CDFDatasets.jl/dev/), `DataContainer` in [Speasy.jl](https://sciqlop.github.io/Speasy.jl/dev/) and `HAPIVariable` in [HAPIClient.jl](https://juliaspacephysics.github.io/HAPIClient.jl/dev/).

Metadata, including units, coordinate systems, and other relevant information, are automatically preserved when loading data from CDF files or web servers. This metadata is utilized /& preserved for subsequent processing, analysis, and visualization tasks.

## Data Retrieval

There are multiple ways to retrieve data in the JuliaSpacePhysics Ecosystem:

- [CDAWeb.jl (preferred)](https://juliaspacephysics.github.io/CDAWeb.jl/dev/): a Julia library to access data from NASA's CDAWeb.

- [Speasy (preferred)](https://github.com/SciQLop/speasy): a Python library for accessing space physics data. Integration is provided using the wrapper library [Speasy.jl](https://sciqlop.github.io/Speasy.jl/dev/).

- [PySPEDAS](https://github.com/spedas/pyspedas): Python-based Space Physics Environment Data Analysis Software. Integration is provided using the wrapper library [PySPEDAS.jl](https://github.com/JuliaSpacePhysics/PySPEDAS.jl).

- [HAPI](https://hapi-server.org): Heliophysics Application Programmer’s Interface (HAPI) specification. Integration is provided using the wrapper library [HAPIClient.jl](https://juliaspacephysics.github.io/HAPIClient.jl/dev/).
