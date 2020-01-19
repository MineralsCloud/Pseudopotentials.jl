module PSlibrary

using DataFrames
import JSON

export list_potentials

const LIBRARY_ROOT = "https://www.quantum-espresso.org/pseudopotentials/ps-library/"
const UPF_ROOT = "https://www.quantum-espresso.org/upf_files/"

function list_potentials(element::AbstractString)
    dir = joinpath(@__DIR__, "../data/")
    file = dir * element * ".json"
    df = DataFrame(name = [], source = [], description = [])
    d = JSON.parsefile(file)
    for (k, v) in d
        push!(df, [k, v["href"], v["meta"]])
    end
    return df
end # function list_potentials

end # module PSlibrary
