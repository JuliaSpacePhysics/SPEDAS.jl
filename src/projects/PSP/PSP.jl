@doc project_doc("PSP", "Parker Solar Probe")
module PSP
using ..SPEDAS: @load_project_config
using SpaceDataModel: Project, DataSet
using Unitful

global psp::Project

@load_project_config "PSP.toml"

n = DataSet("Density",
    [
        SpeasyProduct("PSP_SWP_SPI_SF00_L3_MOM/DENS"; labels=["SPI Proton"]),
        Fix2(*, u"cm^-3") ∘ SpeasyProduct("PSP_SWP_SPC_L3I/np_moment"; labels=["SPC Proton"]),
        SpeasyProduct("PSP_FLD_L3_RFS_LFR_QTN/N_elec"; labels=["RFS Electron"]),
        SpeasyProduct("PSP_FLD_L3_SQTN_RFS_V1V2/electron_density"; labels=["SQTN Electron"])
    ]
)

end