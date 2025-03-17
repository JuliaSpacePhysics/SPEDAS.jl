# Data Model and Project Module

We adopt a data model inspired by the [SPASE Model](https://spase-group.org/data/model/index.html).

## Data Model Overview

The data model organizes data in a hierarchical type structure:

- **Project**: Represents a mission or project (e.g., MMS, THEMIS)
  - Contains multiple instruments
  - Contains multiple datasets
- **Instrument**: Represents a scientific instrument on a spacecraft

  - Associated with a specific project
  - Produces various types of data

- **LDataSet**: A template for generating datasets with parameterized naming patterns
  - Defines the format for dataset names
  - Specifies variables and their naming patterns
- **DataSet**: A concrete dataset created from an LDataSet template
  - Contains actual data parameters
  - Created with specific values (e.g., probe number, data rate)

```@docs; canonical=false
Project
Instrument
LDataSet
DataSet
```

## Project Module and Configuration

We support TOML configuration files to define project-specific metadata. A typical configuration file includes:

- Project metadata
- Instrument definitions
- Dataset template definitions

We use the configuration files to generate appropriate data structures in the project module. For example, the corresponding configuration file of Magnetospheric Multiscale (MMS) module [`src/projects/mms.jl`](https://github.com/Beforerr/SPEDAS.jl/blob/main/src/projects/mms.jl) is [`config/mms.toml`](https://github.com/Beforerr/SPEDAS.jl/blob/main/config/mms.toml).

!!! note

    While configuration files provide a convenient way to structure project metadata, you can also create these data structures directly in code. The configuration approach is optional and primarily serves to separate configuration from implementation.

### Usage Examples

Project-specific instruments and datasets are exported as global variables when importing a project module `using SPEDAS.{project}`, for example:

```@example project
using SPEDAS
using SPEDAS.MMS

mms
```

You can access instruments/datasets directly through the project or via exported variables:

```@example project
mms.instruments.feeps === feeps
```

Dataset templates can be used to create concrete datasets by providing specific parameter values:

```@example project
# Access a dataset template
fpi_dataset = mms.datasets.fpi_moms
```

```@example project
# Create a concrete dataset with specific parameters
dataset = DataSet(fpi_dataset; probe=1, data_rate="fast", data_type="des")
```

### How Configuration Files Are Used

When you import a project module (e.g., `using SPEDAS.MMS`), the system:

1. Reads the corresponding TOML configuration file
2. Creates a `Project` object with the defined metadata
3. Instantiates `Instrument` objects for each instrument definition
4. Creates `LDataSet` (dataset template) objects for each dataset definition

These objects are then accessible through the project namespace (e.g., `mms.instruments.fpi` or `mms.datasets.fpi_moms`).

### Adding a New Project

To add support for a new space physics mission:

1. Create a new TOML file in the `config/` directory (e.g., `config/cluster.toml`)
2. Define the project metadata, instruments, and dataset templates
3. Create a corresponding module in the `src/projects/` directory (for example, `MMS` module is defined in [`src/projects/mms.jl`](https://github.com/Beforerr/SPEDAS.jl/blob/main/src/projects/mms.jl))

The configuration file will be automatically loaded when the project module is imported.
