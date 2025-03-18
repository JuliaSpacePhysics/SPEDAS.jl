"""
    abbr(p::Project; lowercase = true)

Get the abbreviation (abbr) of a project.
"""
function abbr(p::Project; lowercase=true)
    ab = p.metadata["abbreviation"]
    return lowercase ? Base.lowercase(ab) : ab
end