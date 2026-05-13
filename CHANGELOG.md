# Changelog

## [Unreleased]

### Changed

- **Breaking**: `cotrans` argument order changed to `cotrans(out, A, [times])` and `cotrans(in => out, A, [times])`; `backend` now takes a module (`IRBEM`) instead of a symbol (`:IRBEM`).
- **Breaking**: `IRBEM` is now a weak dependency; load `IRBEM.jl` and pass `backend = IRBEM` to use the Fortran implementation.
- **Breaking**: `pspectrum` is no longer available by default; it is now provided by the `TimeseriesUtilities` DSP extension and requires `import DSP` (or `using DSP`) to be enabled.
- `Unitful` is now a weak dependency; `current_density` returns plain numeric output for numeric input and unitful output when Unitful quantities are loaded.

## [0.2.2] - 2025-11-23

### Changed

- refactor: move multi-spacecraft analysis to MultiSpacecraftAnalysis.jl package ([#85](https://github.com/JuliaSpacePhysics/SPEDAS.jl/pull/85))
- refactor: move wave polarization analysis to PlasmaWaves.jl package ([#84](https://github.com/JuliaSpacePhysics/SPEDAS.jl/pull/84))

## [0.2.1] - 2025-09-01

### Changed

- Refactor MVA functionality out into separate package MinimumVarianceAnalysis.jl ([#82](https://github.com/JuliaSpacePhysics/SPEDAS.jl/pull/82))

## [0.2.0] - 2025-08-17

### Added

- CHANGELOG.md tracking notable changes

### Changed

- Support for SpaceDataModel v0.2 (drop support for v0.1)
- **Breaking**: Move TPlot into [`SpacePhysicsMakie.jl`](https://github.com/JuliaSpacePhysics/SpacePhysicsMakie.jl) ([#76](https://github.com/JuliaSpacePhysics/SPEDAS.jl/pull/76)), now `using SpacePhysicsMakie` is required to use `tplot`.


[unreleased]: https://github.com/JuliaSpacePhysics/SPEDAS.jl/compare/v0.2.2...HEAD
[0.2.2]: https://github.com/JuliaSpacePhysics/SPEDAS.jl/releases/tag/v0.2.2
[0.2.1]: https://github.com/JuliaSpacePhysics/SPEDAS.jl/releases/tag/v0.2.1
[0.2.0]: https://github.com/JuliaSpacePhysics/SPEDAS.jl/releases/tag/v0.2.0
