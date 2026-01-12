# SPEDAS.jl

[![DOI](https://zenodo.org/badge/923721479.svg)](https://doi.org/10.5281/zenodo.15181866)
[![version](https://juliahub.com/docs/General/SPEDAS/stable/version.svg)](https://juliahub.com/ui/Packages/General/SPEDAS)

[![SciML Code Style](https://img.shields.io/static/v1?label=code%20style&message=SciML&color=9558b2&labelColor=389826)](https://github.com/SciML/SciMLStyle)
[![Build Status](https://github.com/JuliaSpacePhysics/SPEDAS.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/JuliaSpacePhysics/SPEDAS.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/JuliaSpacePhysics/SPEDAS.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/JuliaSpacePhysics/SPEDAS.jl)

A collection of tools for space physics / heliophysics: from data loading and processing to plotting and analysis.

## Installation

```julia
using Pkg
Pkg.add("SPEDAS")
```

## Explanations

!!! note "Notes" 
    - This package began as a Julia port of [PySPEDAS](https://github.com/spedas/pyspedas) but has since expanded beyond a direct translation. While we aim to keep the API broadly consistent with the original, some intentional differences reflect design improvements in the Julia ecosystem. If you need a one-to-one wrapper of the Python library, see [PySPEDAS.jl](https://github.com/JuliaSpacePhysics/PySPEDAS.jl).
    - The package now functions as a **meta-package**. Much of its functionality has been refactored into separate, modular components to improve maintainability and accelerate development. The broader [JuliaSpacePhysics Ecosystem](https://juliaspacephysics.github.io/ecosystem/) includes tools for coordinate transformations ([GeoCotrans.jl](https://github.com/JuliaSpacePhysics/GeoCotrans.jl)), data access (e.g., [CDAWeb.jl](https://github.com/JuliaSpacePhysics/CDAWeb.jl)), data analysis (e.g., [VelocityDistributionFunctions.jl](https://github.com/JuliaSpacePhysics/VelocityDistributionFunctions.jl)), and more specialized applications (e.g., [GeoAACGM.jl](https://github.com/JuliaSpacePhysics/GeoAACGM.jl)).
    - The primary goal of this package is to coordinate diverse data sources and analysis methods, providing a unified, high-level interface for scientific workflows. A secondary goal is to ensure consistent interfaces and to validate results against tools such as `PySPEDAS`.

Plasma wave analysis is supported through the [PlasmaWaves.jl](https://juliaspacephysics.github.io/PlasmaWaves.jl/dev/) package. See, for example, the section on [wave polarization analysis](./validation/pyspedas.md#wave-polarization). Plasma electromagnetic dispersion-relation solving is supported through [PlasmaBO.jl](https://github.com/JuliaSpacePhysics/PlasmaBO.jl).

Energetic particle analysis is provided by [SolarEnergeticParticle.jl](https://juliaspacephysics.github.io/SolarEnergeticParticle.jl). See, for example, the sections on [onset analysis](https://juliaspacephysics.github.io/SolarEnergeticParticle.jl/dev/onset/) and [velocity dispersion analysis (VDA)](https://juliaspacephysics.github.io/SolarEnergeticParticle.jl/dev/vda/).

Multi-spacecraft analysis methods are provided by [MultiSpacecraftAnalysis.jl](https://juliaspacephysics.github.io/MultiSpacecraftAnalysis.jl), see the section on [using reciprocal vectors to estimate spatial gradients](./explanations/multispacecraft.md).

[`SpacePhysicsMakie.jl`](https://juliaspacephysics.github.io/SpacePhysicsMakie.jl/dev/) provides utilities for visualizing and composing space physics time series data.

## Contents

```@contents
Pages = [
    "explanations/data.md",
    "explanations/data_model.md",
    "explanations/coords.md",
    "explanations/multispacecraft.md",
    "explanations/timeseries.md"
]
Depth = 1
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
  - spectral analysis
  - moving box average for filtering magnetometer data
- [irfu-matlab](https://github.com/irfu/irfu-matlab): Matlab routines to work with space data, particularly with MMS and Cluster/CAA data. Also some general plasma routines.
  - [pyrfu](https://pyrfu.readthedocs.io/en/latest/): Python version of irfu-matlab to work with space data, particularly the Magnetospheric MultiScale (MMS) mission.
- [QSAS (C/C++)](http://www.sp.ph.ic.ac.uk/csc-web/QSAS/) : Science Analysis Software for Space Plasmas
- [pysat](https://github.com/pysat/pysat): Python Satellite Data Analysis Toolkit

⚠️ **Development Status**: This package is in active development. While functional, the API may undergo changes in future releases. Please review the documentation and test thoroughly before using in scientific work.

📫 **Contributing**: We welcome contributions! If you're interested in collaborating or need assistance, please open an issue or reach out through our [GitHub repository](https://github.com/JuliaSpacePhysics/SPEDAS.jl).


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

```@bibliography
```