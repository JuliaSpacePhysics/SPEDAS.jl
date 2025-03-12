module MMS
using ..SpaceTools
export FPIDataSet

const file = joinpath(pkgdir(SpaceTools), "config", "mms.toml")
config = SpaceTools.load_project_config(file)

for (sym, value) in config
    @eval begin
        $sym = $value
        export $sym
    end
end

FPIDataSet(; probe=1, data_rate="fast", data_type="des") = DataSet(fpi_moms; probe, data_rate, data_type)

end