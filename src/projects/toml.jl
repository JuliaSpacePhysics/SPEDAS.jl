# Function to load project configuration from TOML
function load_project_config(toml)
    config = TOML.parsefile(toml)

    instruments = _dict2nt(get(config, "instruments", Dict()); f=Instrument)
    datasets = _dict2nt(get(config, "datasets", Dict()); f=LDataSet)

    project = Project(;
        name=config["name"],
        metadata=get(config, "metadata", Dict()),
        instruments,
        datasets
    )

    dict = Dict{Symbol,Any}()
    dict[Symbol(abbr(project))] = project
    for (key, value) in pairs(datasets) ∪ pairs(instruments)
        dict[key] = value
    end

    return dict
end