module MMS
using ..SPEDAS
export FPIDataSet

const file = joinpath(pkgdir(SPEDAS), "config", "mms.toml")
config = SPEDAS.load_project_config(file)

for (sym, value) in config
    @eval begin
        $sym = $value
        export $sym
    end
end

FPIDataSet(; probe=1, data_rate="fast", data_type="des") = DataSet(fpi_moms; probe, data_rate, data_type)

end