# SPEDAS.jl

[![Build Status](https://github.com/Beforerr/SPEDAS.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/Beforerr/SPEDAS.jl/actions/workflows/CI.yml?query=branch%3Amain)

A collection of tools for space physics / heliophysics: from data loading and processing to plotting and analysis.

## Installation

```julia
using Pkg
Pkg.add(PackageSpec(url="https://github.com/Beforerr/SPEDAS.jl"))
```

## Related packages

- [SPEDAS (IDL)](https://spedas.org) / [PySPEDAS](https://github.com/SPEDAS/PySPEDAS) : Space Physics Environment Data Analysis Software framework to support loading, plotting, analysis, and integration of data from a number of space- and ground-based observatories
- [Kamodo](https://nasa.github.io/Kamodo/) : An official NASA open-source python package built upon the functionalization of datasets
- [space-analysis.py](https://github.com/Beforerr/space-analysis.py) : Python utils for data analysis in space physics.
- [SpaceAnalysis.jl](https://henry2004y.github.io/VisAnaJulia/dev/) : Space physics analysis tool using Julia
    - minimum variance analysis (MVA)
    - spectral analysis
    - moving box average for filtering magnetometer data
    - coordinate transformations
- [QSAS (C/C++)](http://www.sp.ph.ic.ac.uk/csc-web/QSAS/) : Science Analysis Software for Space Plasmas

⚠️ **Development Status**: This package is in active development. While functional, the API may undergo changes in future releases. Please review the documentation and test thoroughly before using in scientific work.

📫 **Contributing**: We welcome contributions! If you're interested in collaborating or need assistance, please open an issue or reach out through our [GitHub repository](https://github.com/Beforerr/SPEDAS.jl).

## Explanations

```@contents
Pages = [
    "explanations/coords.md",
    "explanations/multispacecraft.md",
    "explanations/tplot.md",
    "explanations/resampling.md"
]
Depth = 1
```
