# SPEDAS.jl

[![](https://img.shields.io/badge/docs-dev-blue.svg)](https://JuliaSpacePhysics.github.io/SPEDAS.jl/dev/)
[![DOI](https://zenodo.org/badge/923721479.svg)](https://doi.org/10.5281/zenodo.15181866)

[![SciML Code Style](https://img.shields.io/static/v1?label=code%20style&message=SciML&color=9558b2&labelColor=389826)](https://github.com/SciML/SciMLStyle)
[![Build Status](https://github.com/JuliaSpacePhysics/SPEDAS.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/JuliaSpacePhysics/SPEDAS.jl/actions/workflows/CI.yml?query=branch%3Amain)
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
- [geospacelab](https://github.com/JouleCai/geospacelab): A python-based library to collect, manage, and visualize the geospace data
  - Data sources: Madrigal/EISCAT, Madrigal/GNSS/TECMAP, Madrigal/DMSP...
- [space-analysis.py](https://github.com/Beforerr/space-analysis.py) : Python utils for data analysis in space physics.
- [SpaceAnalysis.jl](https://henry2004y.github.io/VisAnaJulia/dev/) : Space physics analysis tool using Julia
  - minimum variance analysis (MVA)
  - spectral analysis
  - moving box average for filtering magnetometer data
  - coordinate transformations
- [irfu-matlab](https://github.com/irfu/irfu-matlab): Matlab routines to work with space data, particularly with MMS and Cluster/CAA data. Also some general plasma routines.
  - [pyrfu](https://pyrfu.readthedocs.io/en/latest/): Python version of irfu-matlab to work with space data, particularly the Magnetospheric MultiScale (MMS) mission.
- [QSAS (C/C++)](http://www.sp.ph.ic.ac.uk/csc-web/QSAS/) : Science Analysis Software for Space Plasmas
- [pysat](https://github.com/pysat/pysat): Python Satellite Data Analysis Toolkit

⚠️ **Development Status**: This package is in active development. While functional, the API may undergo changes in future releases. Please review the documentation and test thoroughly before using in scientific work.

📫 **Contributing**: We welcome contributions! If you're interested in collaborating or need assistance, please open an issue or reach out through our [GitHub repository](https://github.com/JuliaSpacePhysics/SPEDAS.jl).

!!! note "Notes" - This package originated as a port of [PySPEDAS](https://github.com/spedas/pyspedas) to Julia but has since evolved to extend its functionality. While we strive to maintain an API that is as consistent as possible with the original, certain design improvements have led to intentional deviations. For a direct one-to-one wrapper of the original Python library, see [PySPEDAS.jl](https://github.com/JuliaSpacePhysics/PySPEDAS.jl). - The package now serves as a **meta-package**, with much of its functionality refactored into separate, modular packages to improve maintainability and accelerate development. The broader [JuliaSpacePhysics Ecosystem](https://juliaspacephysics.github.io/ecosystem/) includes tools for coordinate transformations ([`GeoCotrans.jl`](https://github.com/JuliaSpacePhysics/GeoCotrans.jl)), data access ([`CDAWeb.jl`](https://github.com/JuliaSpacePhysics/CDAWeb.jl)), data analysis (e.g., [`MinimumVarianceAnalysis.jl`](https://github.com/JuliaSpacePhysics/MinimumVarianceAnalysis.jl), [`VelocityDistributionFunctions.jl`](https://github.com/JuliaSpacePhysics/VelocityDistributionFunctions.jl), [`PlasmaFormulary.jl`](https://github.com/JuliaSpacePhysics/PlasmaFormulary.jl)), and more domain-specific applications ([`SolarEnergeticParticle.jl`](https://github.com/JuliaSpacePhysics/SolarEnergeticParticle.jl), [`GeoAACGM.jl`](https://github.com/JuliaSpacePhysics/GeoAACGM.jl)).

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

## Reproducibility

```@raw html
<details><summary>The documentation of this package was built using these direct dependencies,</summary>
```

```@example
using Pkg # hide
Pkg.status() # hide
```

```@raw html
</details>
```

```@raw html
<details><summary>and using this machine and Julia version.</summary>
```

```@example
using InteractiveUtils # hide
versioninfo() # hide
```

```@raw html
</details>
```
