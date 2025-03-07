# Data Formats and Retrieval

We primarily uses [DimensionalData.jl](https://github.com/rafaqz/DimensionalData.jl) for data representation and processing. This approach provides a powerful and flexible way to work with multi-dimensional data in space physics applications.

## DimensionalData

`DimensionalData.jl` provides labeled dimensions for Julia arrays, making it easier to work with complex scientific data. In `SpaceTools.jl`, we use two main types:

- `DimArray`: A multidimensional array with named dimensions
- `DimStack`: A collection of DimArrays that share some or all dimensions

Metadata, including units, coordinate systems, and other relevant information, are automatically preserved when loading data from CDF files or web servers. This metadata is utilized /& preserved for subsequent processing, analysis, and visualization tasks.

`SpaceTools` uses several standard dimensions for space physics data:

- `Ti`: Time dimension
- `𝑓`: Frequency dimension

## Data Retrieval

`SpaceTools` supports retrieving data from multiple sources and automatically converting it to DimensionalData format:

- [Speasy (preferred)](https://github.com/SciQLop/speasy): a Python library for accessing space physics data. Integration is provided using the wrapper library [`Speasy.jl`](https://github.com/SciQLop/Speasy.jl).

- [PySPEDAS](https://github.com/spedas/pyspedas): Python-based Space Physics Environment Data Analysis Software. Integration is provided using the wrapper library [`PySPEDAS.jl`](https://github.com/Beforerr/PySPEDAS.jl).

- [HAPI](https://hapi-server.org): Heliophysics Application Programmer’s Interface (HAPI) specification. Integration is provided using the wrapper library [`HAPIClient.jl`](https://github.com/Beforerr/HAPIClient.jl).
