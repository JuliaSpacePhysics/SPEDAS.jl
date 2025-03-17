module MMS
using ..SPEDAS
export FPIDataSet

load_config() = SPEDAS.@load_project_config "mms.toml"
load_config()

FPIDataSet(; probe=1, data_rate="fast", data_type="des") = DataSet(fpi_moms; probe, data_rate, data_type)

end