module PSlibrary

using DataFrames
import JSON

export list_potentials

const LIBRARY_ROOT = "https://www.quantum-espresso.org/pseudopotentials/ps-library/"
const UPF_ROOT = "https://www.quantum-espresso.org/upf_files/"
const AVAILABLE_ELEMENTS = (
    "h",
    "he",
    "li",
    "be",
    "b",
    "c",
    "n",
    "o",
    "f",
    "ne",
    "na",
    "mg",
    "al",
    "si",
    "p",
    "s",
    "cl",
    "ar",
    "k",
    "ca",
    "sc",
    "ti",
    "v",
    "cr",
    "mn",
    "fe",
    "co",
    "ni",
    "cu",
    "zn",
    "ga",
    "ge",
    "as",
    "se",
    "br",
    "kr",
    "rb",
    "sr",
    "y",
    "zr",
    "nb",
    "mo",
    "tc",
    "ru",
    "rh",
    "pd",
    "ag",
    "cd",
    "in",
    "sn",
    "sb",
    "te",
    "i",
    "xe",
    "cs",
    "ba",
    "la",
    "ce",
    "pr",
    "nd",
    "pm",
    "sm",
    "eu",
    "gd",
    "tb",
    "dy",
    "ho",
    "er",
    "tm",
    "yb",
    "lu",
    "hf",
    "ta",
    "w",
    "re",
    "os",
    "ir",
    "pt",
    "au",
    "hg",
    "tl",
    "pb",
    "bi",
    "po",
    "at",
    "rn",
    "fr",
    "ra",
    "ac",
    "th",
    "pa",
    "u",
    "np",
    "pu",
)

function list_potentials(element::AbstractString)
    @assert element ∈ AVAILABLE_ELEMENTS
    dir = joinpath(@__DIR__, "../data/")
    file = dir * lowercase(element) * ".json"
    df = DataFrame(name = [], source = [], description = [])
    d = JSON.parsefile(file)
    for (k, v) in d
        push!(df, [k, v["href"], v["meta"]])
    end
    return df
end # function list_potentials

end # module PSlibrary
