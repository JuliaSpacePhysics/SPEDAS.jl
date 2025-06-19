# SPEDAS.jl

[![Build Status](https://github.com/JuliaSpacePhysics/SPEDAS.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/JuliaSpacePhysics/SPEDAS.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![](https://img.shields.io/badge/docs-dev-blue.svg)](https://JuliaSpacePhysics.github.io/SPEDAS.jl/dev/)
[![DOI](https://zenodo.org/badge/923721479.svg)](https://doi.org/10.5281/zenodo.15181866)
[![SciML Code Style](https://img.shields.io/static/v1?label=code%20style&message=SciML&color=9558b2&labelColor=389826)](https://github.com/SciML/SciMLStyle)
[![Coverage](https://codecov.io/gh/JuliaSpacePhysics/SPEDAS.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/JuliaSpacePhysics/SPEDAS.jl)


A collection of tools for space physics / heliophysics: from data loading and processing to plotting and analysis.

## Installation

```julia
using Pkg
Pkg.add("SPEDAS")
```

## Related packages

- [SPEDAS (IDL)](https://spedas.org) / [PySPEDAS](https://github.com/SPEDAS/PySPEDAS) : Space Physics Environment Data Analysis Software framework to support loading, plotting, analysis, and integration of data from a number of space- and ground-based observatories
- [SpacePy](https://github.com/spacepy/spacepy) : A package for Python, targeted at the space sciences, that aims to make basic data analysis, modeling and visualization easier.
- [Kamodo](https://nasa.github.io/Kamodo/) : An official NASA open-source python package built upon the functionalization of datasets
- [autoplot](https://autoplot.org/) : An interactive browser for data on the web
    - [das2](https://das2.org/): Web-based data delivery, visualization, and analysis system from the The University of Iowa.
- [space-analysis.py](https://github.com/Beforerr/space-analysis.py) : Python utils for data analysis in space physics.
- [SpaceAnalysis.jl](https://henry2004y.github.io/VisAnaJulia/dev/) : Space physics analysis tool using Julia
    - minimum variance analysis (MVA)
    - spectral analysis
    - moving box average for filtering magnetometer data
    - coordinate transformations
- [irfu-matlab](https://github.com/irfu/irfu-matlab): Matlab routines to work with space data, particularly with MMS and Cluster/CAA data. Also some general plasma routines.
- [QSAS (C/C++)](http://www.sp.ph.ic.ac.uk/csc-web/QSAS/) : Science Analysis Software for Space Plasmas
- [pysat](https://github.com/pysat/pysat): Python Satellite Data Analysis Toolkit

⚠️ **Development Status**: This package is in active development. While functional, the API may undergo changes in future releases. Please review the documentation and test thoroughly before using in scientific work.

📫 **Contributing**: We welcome contributions! If you're interested in collaborating or need assistance, please open an issue or reach out through our [GitHub repository](https://github.com/JuliaSpacePhysics/SPEDAS.jl).

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
