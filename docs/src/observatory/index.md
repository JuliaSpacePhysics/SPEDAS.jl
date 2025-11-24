# Observatory Modules

> Observatory: The host (spacecraft, network, facility) for instruments making observations.

See [Data Model](../explanations/data_model.md) section for more details.

The ecosystem provides broad, flexible functionality for retrieving and loading data. If a mission or observatory does not require additional processing, you can use packages such as [CDAWeb.jl](https://juliaspacephysics.github.io/CDAWeb.jl/dev/), [Speasy.jl](https://sciqlop.github.io/Speasy.jl/dev/), or [HAPIClient.jl](https://juliaspacephysics.github.io/HAPIClient.jl/dev/) to accomplish the same tasks. An example of this approach appears in the [SolarEnergeticParticles](https://juliaspacephysics.github.io/SolarEnergeticParticle.jl/dev/) package, which offers utilities for accessing energetic-particle data from multiple missions (PSP, SOHO, STEREO, and Wind).

When post-processing routines are needed and available in [PySPEDAS](https://pyspedas.readthedocs.io/en/latest/projects.html), you can instead use [PySPEDAS.jl](https://github.com/JuliaSpacePhysics/PySPEDAS.jl), a wrapper library that allows you to call those routines and access the processed data directly from the Python side in Julia.

## Mission specific packages

- [DMSPData.jl](https://juliaspacephysics.github.io/DMSPData.jl/dev/): Access and process [Defense Meteorological Satellite Program](https://www.wikipedia.org/wiki/Defense_Meteorological_Satellite_Program) data from the [Madrigal database](https://cedar.openmadrigal.org/).
- [ELFINData.jl](https://juliaspacephysics.github.io/ELFINData.jl/dev/): A high-level Julia interface to the [ELFIN](https://elfin.igpp.ucla.edu/) mission's particle and field measurements. 
- [EISCATData.jl](https://juliaspacephysics.github.io/EISCATData.jl/dev/): Access and process [EISCAT](https://www.wikipedia.org/wiki/EISCAT) incoherent scatter radar data from the [Madrigal database](https://cedar.openmadrigal.org/).

We also include some preliminary mission definitions here.

- [Parker Solar Probe (PSP)](psp.md)
- [Magnetospheric Multiscale (MMS)](mms.md)
- [Juno](juno.md)
- [Time History of Events and Macroscale Interactions during Substorms (THEMIS)](themis.md)

## References

- [SPASE Data Model](https://spase-group.org/data/index.html)
- [PySPEDAS Projects](https://pyspedas.readthedocs.io/en/latest/projects.html)
