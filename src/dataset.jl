meta(ds::DataSet) = ds.metadata
title(ds::DataSet) = ds.name
transform(ds::DataSet) = ds.parameters

function axis_attributes(ds::DataSet; add_title=false, kwargs...)
    attrs = Attributes(; kwargs...)
    add_title && (attrs[:title] = title(ds))
    attrs
end
