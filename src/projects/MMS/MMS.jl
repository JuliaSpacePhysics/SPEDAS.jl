@doc project_doc("MMS", "Magnetospheric Multiscale")
module MMS
using ..SPEDAS: @load_project_config
using SpaceDataModel: DataSet
export FPIDataSet

@load_project_config "MMS.toml"

FPIDataSet(; probe=1, data_rate="fast", data_type="des") = DataSet(fpi_moms; probe, data_rate, data_type)

end