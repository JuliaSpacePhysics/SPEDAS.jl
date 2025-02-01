# Coordinate Systems

This package defines common coordinate systems used in heliophysics and space physics research.

More information can be found in the the following links

- https://stereo-ssc.nascom.nasa.gov/coordinates_explanation.shtml

## Standard Coordinate Systems

* GSE (Geocentric Solar Ecliptic)
* GSM (Geocentric Solar Magnetic)
* GEI (Geocentric Equatorial Inertial)
* SM (Solar Magnetic)
* GEO (Geographic)
* J2000

!!! note "Implementation Status"
    Transformations between these coordinate systems are planned but not yet implemented.

## Specialized Coordinate Systems

The package also provides transformations for analysis-specific coordinate systems:

* **FAC** (Field-Aligned Coordinates): A local coordinate system defined relative to the ambient magnetic field direction, useful for studying plasma waves and particle distributions.

```@docs
fac_mat
```

* **MVA** (Minimum-Variance Analysis): A coordinate system derived from the eigenvalues and eigenvectors of the magnetic field variance matrix, commonly used in analyzing current sheets, discontinuities, and wave propagation.


```@docs
mva_mat
mva
check_mva_mat
```