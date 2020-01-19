module PSlibrary

using DataFrames: DataFrame
import JSON

export list_elements, list_potentials, download_potential

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

"List all elements that has pseudopotentials available in PSlibrary."
function list_elements()
    s = raw"""
    H                                                  He
    Li Be                               B  C  N  O  F  Ne
    Na Mg                               Al Si P  S  Cl Ar
    K  Ca Sc Ti V  Cr Mn Fe Co Ni Cu Zn Ga Ge As Se Br Kr
    Rb Sr Y  Zr Nb Mo Tc Ru Rh Pd Ag Cd In Sn Sb Te I  Xe
    Cs Ba    Hf Ta W  Re Os Ir Pt Au Hg Tl Pb Bi Po At Rn
    Fr Ra    Rf Db Sg Bh Hs Mt Ds Rg Cn Nh Fl Mc Lv Ts Og
    Uue
          La Ce Pr Nd Pm Sm Eu Gd Tb Dy Ho Er Tm Yb Lu
          Ac Th Pa U  Np Pu
    """
    println(s)
end # function list_elements

"""
    list_potentials(element::AbstractString)
    list_potentials(i::Integer)

List all pseudopotentials in PSlibrary for a specific element (abbreviation or index).
"""
function list_potentials(element::AbstractString)
    @assert lowercase(element) ∈ AVAILABLE_ELEMENTS
    dir = joinpath(@__DIR__, "../data/")
    file = dir * lowercase(element) * ".json"
    df = DataFrame(name = [], source = [], summary = [])
    d = JSON.parsefile(file)
    for (k, v) in d
        push!(df, [k, v["href"], v["meta"]])
    end
    return df
end # function list_potentials
function list_potentials(i::Integer)
    1 <= i <= 94 || error("You can only access element 1 to 94!")
    return list_potentials(AVAILABLE_ELEMENTS[i])
end # function list_potentials

"""
    download_potential(element::AbstractString)
    download_potential(i::Integer)

Download one or multiple pseudopotentials from PSlibrary for a specific element.
"""
function download_potential(element::AbstractString)
    df = list_potentials(element)
    println(df)
    paths = String[]
    while true
        println("Enter the index (integer) for the potential that you want to download: ")
        i = parse(Int, readline())
        println("Enter the path you want to save the file: ")
        path = readline()
        push!(paths, if isempty(path)
            download(df[i, :].source)
        else
            download(df[i, :].source, expanduser(path))
        end)
        println("Finished? [t/f]: ")
        if strip(readline()) == "t"
            break
        end
        continue
    end
    return paths
end # function download_potential
function download_potential(i::Integer)
    1 <= i <= 94 || error("You can only access element 1 to 94!")
    return download_potential(AVAILABLE_ELEMENTS[i])
end # function download_potential

end # module PSlibrary
