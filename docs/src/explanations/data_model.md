# Data Model

We adopt a data model inspired by the [SPASE Model](https://spase-group.org/data/model/index.html).

## Data Model Overview

The data model organizes data in a hierarchical structure:

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

## Usage Examples

Project-specific instruments and datasets are exported as global variables when importing a project module `using SPEDAS.{project}`, for example:

```@example project
using SPEDAS
using SPEDAS.MMS

mms
```

You can access instruments directly through the project or via exported variables:

```@example project
mms.instruments.feeps === feeps
```

Dataset templates can be used to create concrete datasets with specific parameters:

```@example project
# Access a dataset template
fpi_dataset = mms.datasets.fpi_moms

# Create a concrete dataset with specific parameters
dataset = DataSet(fpi_dataset; probe=1, data_rate="fast", data_type="des")
```