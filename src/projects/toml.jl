# Function to load project configuration from TOML
function load_project_config(toml)
    config = TOML.parsefile(toml)

    instruments = _dict2nt(config["instruments"]; f=Instrument)
    datasets = _dict2nt(config["datasets"]; f=LDataSet)

    project = Project(;
        name=config["name"],
        metadata=config["metadata"],
        instruments,
        datasets
    )

    dict = Dict{Symbol,Any}()
    proj_abbr = config["metadata"]["abbreviation"]
    dict[Symbol(proj_abbr)] = project
    for (key, value) in pairs(datasets) ∪ pairs(instruments)
        dict[key] = value
    end

    return dict
end