# Coordinate Systems and Transformations

This package defines common coordinate systems used in heliophysics and space physics research.

```@contents
Pages = ["coords.md"]
Depth = 2:3
```

## Standard Coordinate Systems

Systems based on the Earth-Sun line

* GSE (Geocentric Solar Ecliptic)
* GSM (Geocentric Solar Magnetic)

Systems based on the Earth's rotation axis

* GEO (Geographic)
* GEI (Geocentric Equatorial Inertial)
* J2000

Systems based on the dipole axis of the Earth's magnetic field

* SM (Solar Magnetic)
* MAG (Geomagnetic)

Other coordinate systems

- [Altitude Adjusted Corrected Geogmagnetic Coordinates (AACGM)](https://superdarn.thayer.dartmouth.edu/aacgm.html)


More information can be found in the the following links

- [https://stereo-ssc.nascom.nasa.gov/coordinates_explanation.shtml](https://stereo-ssc.nascom.nasa.gov/coordinates_explanation.shtml)
- [Geocentric systems](https://www.mssl.ucl.ac.uk/grid/iau/extra/local_copy/SP_coords/geo_sys.htm)


## Coordinate Transformations

```@docs; canonical=false
rotate
```

A comprehensive description of the transformations can be found in [hapgoodSpacePhysicsCoordinate1992](@citet)

### Coordinate transformations between geocentric systems

```@docs; canonical=false
cotrans
```

```@example coords
using DimensionalData
using Speasy, SPEDAS
using CairoMakie, SpacePhysicsMakie

pos_gse = get_data("cda/THC_L1_STATE/thc_pos_gse", "2015-10-16", "2015-10-17") |> DimArray

pos_gsm = cotrans(pos_gse, "GSM")
pos_sm = cotrans(pos_gse, "SM")
pos_geo = cotrans(pos_gse, "GEO")

tplot((pos_gse, pos_gsm, pos_sm, pos_geo))
```

## Specialized Coordinate Systems

The package also provides transformations for analysis-specific coordinate systems:

### Field-Aligned Coordinates (FAC)

A local coordinate system defined relative to the ambient magnetic field direction, useful for studying plasma waves and particle distributions.

```@docs; canonical=false
fac_mat
```

### Minimum Variance Analysis (MVA) and Boundary Normal Coordinates (LMN)

A coordinate system derived from the eigenvalues and eigenvectors of the magnetic field variance matrix, commonly used in analyzing current sheets, discontinuities, and wave propagation.

See [MinimumVarianceAnalysis.jl](https://juliaspacephysics.github.io/MinimumVarianceAnalysis.jl/dev/) for more details.

```@docs; canonical=false
mva_eigen
mva
check_mva_eigen
```

See also: [Comparison with PySPEDAS](../validation/pyspedas.md#minimum-variance-analysis).

## Reference

- [The International Radiation Belt Environment Modeling (IRBEM) library](https://prbem.github.io/IRBEM/)


- [PySPEDAS: Coordinate Systems](https://pyspedas.readthedocs.io/en/latest/coords.html)
- [geopack](https://github.com/tsssss/geopack): Python version of geopack and Tsyganenko models
- [geospacelab](https://github.com/JouleCai/geospacelab): A python-based library to collect, manage, and visualize geospace data (e.g. OMNI, geomagnetic indices, EISCAT, DMSP, SWARM, TEC, AMPERE, etc.).
- [aacgmv2](https://github.com/aburrell/aacgmv2): Python library for AACGM-v2 magnetic coordinates
