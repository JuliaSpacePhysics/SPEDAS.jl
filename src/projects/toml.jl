using SpaceDataModel: NoMetadata
const NoData = NoMetadata

# Construct a `LDataSet` from a dictionary.
function dict2LDataSet(d::Dict)
    return LDataSet(;
        name = get(d, "name", ""),
        format = get(d, "format", ""),
        data = get(d, "parameters", NoData()),
        metadata = get(d, "metadata", NoMetadata())
    )
end

dmap(f, d::Dict) = Dict(k => f(v) for (k, v) in d)

abbr_sym(p) = Symbol(lowercase(get(p, "abbreviation", name(p))))

# Function to load project configuration from TOML
function load_project_config(toml)
    config = TOML.parsefile(toml)

    # First load all datasets
    datasets = dmap(dict2LDataSet, get(config, "datasets", Dict()))

    # Process instruments and associate datasets with them
    instruments = dmap(get(config, "instruments", Dict())) do v
        dataset_refs = get(v, "datasets", String[])
        v["datasets"] = filter(x -> in(x.first, dataset_refs), datasets)
        Instrument(v)
    end

    project = Project(;
        name = config["name"],
        metadata = get(config, "metadata", Dict()),
        instruments,
        datasets
    )
    dict = Dict{Symbol, Any}()
    dict[abbr_sym(project)] = project
    for (key, value) in pairs(datasets) ∪ pairs(instruments)
        dict[Symbol(key)] = value
    end

    return dict
end
