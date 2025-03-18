# Coordinate Systems

This package defines common coordinate systems used in heliophysics and space physics research.

```@contents
Pages = ["coords.md"]
Depth = 2:3
```

## Coordinate Transformations

```@docs; canonical=false
rotate
```

## Standard Coordinate Systems

* GSE (Geocentric Solar Ecliptic)
* GSM (Geocentric Solar Magnetic)
* GEI (Geocentric Equatorial Inertial)
* SM (Solar Magnetic)
* GEO (Geographic)
* J2000

More information can be found in the the following links

- [https://stereo-ssc.nascom.nasa.gov/coordinates_explanation.shtml](https://stereo-ssc.nascom.nasa.gov/coordinates_explanation.shtml)

!!! note "Implementation Status"
    Transformations between these coordinate systems are planned but not yet implemented.

## Specialized Coordinate Systems

The package also provides transformations for analysis-specific coordinate systems:

### Field-Aligned Coordinates (FAC)

A local coordinate system defined relative to the ambient magnetic field direction, useful for studying plasma waves and particle distributions.

```@docs; canonical=false
fac_mat
```

### Minimum Variance Analysis (MVA) and Boundary Normal Coordinates (LMN)

A coordinate system derived from the eigenvalues and eigenvectors of the magnetic field variance matrix, commonly used in analyzing current sheets, discontinuities, and wave propagation.

References:

- [Minimum and Maximum Variance Analysis](https://ui.adsabs.harvard.edu/abs/1998ISSIR...1..185S)
- [https://pyspedas.readthedocs.io/en/latest/coords.html#pyspedas.minvar](https://pyspedas.readthedocs.io/en/latest/coords.html#pyspedas.minvar)

```@docs; canonical=false
mva_mat
mva
check_mva_mat
```

Error estimates for MVA:

```@docs; canonical=false
SPEDAS.Δφij
SPEDAS.B_x3_error
```