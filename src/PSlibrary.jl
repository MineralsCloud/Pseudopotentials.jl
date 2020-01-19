module PSlibrary

using DataFrames: DataFrame
import JLD2: @save, @load
import JSON

using Pseudopotentials:
    FunctionalType,
    PerdewZunger,
    VoskoWilkNusair,
    PerdewBurkeErnzerhof,
    BeckeLeeYangParr,
    PerdewWang91,
    TaoPerdewStaroverovScuseria,
    Coulomb,
    Pseudization,
    AllElectron,
    MartinsTroullier,
    BacheletHamannSchlueter,
    VonBarthCar,
    Vanderbilt,
    RappeRabeKaxirasJoannopoulos,
    KresseJoubert,
    Bloechl,
    NlState,
    OneCoreHole,
    HalfCoreHole

export list_elements, list_potentials, download_potential, save_potential

const AVAILABLE_ELEMENTS = (
    "H",
    "He",
    "Li",
    "Be",
    "B",
    "C",
    "N",
    "O",
    "F",
    "Ne",
    "Na",
    "Mg",
    "Al",
    "Si",
    "P",
    "S",
    "Cl",
    "Ar",
    "K",
    "Ca",
    "Sc",
    "Ti",
    "V",
    "Cr",
    "Mn",
    "Fe",
    "Co",
    "Ni",
    "Cu",
    "Zn",
    "Ga",
    "Ge",
    "As",
    "Se",
    "Br",
    "Kr",
    "Rb",
    "Sr",
    "Y",
    "Zr",
    "Nb",
    "Mo",
    "Tc",
    "Ru",
    "Rh",
    "Pd",
    "Ag",
    "Cd",
    "In",
    "Sn",
    "Sb",
    "Te",
    "I",
    "Xe",
    "Cs",
    "Ba",
    "La",
    "Ce",
    "Pr",
    "Nd",
    "Pm",
    "Sm",
    "Eu",
    "Gd",
    "Tb",
    "Dy",
    "Ho",
    "Er",
    "Tm",
    "Yb",
    "Lu",
    "Hf",
    "Ta",
    "W",
    "Re",
    "Os",
    "Ir",
    "Pt",
    "Au",
    "Hg",
    "Tl",
    "Pb",
    "Bi",
    "Po",
    "At",
    "Rn",
    "Fr",
    "Ra",
    "Ac",
    "Th",
    "Pa",
    "U",
    "Np",
    "Pu",
)
const NL_STATE = Dict("starnl" => OneCoreHole, "starhnl" => HalfCoreHole)
const FUNCTIONAL_TYPE = Dict(
    "pz" => PerdewZunger,
    "vwn" => VoskoWilkNusair,
    "pbe" => PerdewBurkeErnzerhof,
    "blyp" => BeckeLeeYangParr,
    "pw91" => PerdewWang91,
    "tpss" => TaoPerdewStaroverovScuseria,
    "coulomb" => Coulomb,
)
const PSEUDIZATION_TYPE = Dict(
    "ae" => AllElectron,
    "mt" => MartinsTroullier,
    "bhs" => BacheletHamannSchlueter,
    "vbc" => VonBarthCar,
    "van" => Vanderbilt,
    "rrkj" => RappeRabeKaxirasJoannopoulos{:NC},
    "rrkjus" => RappeRabeKaxirasJoannopoulos{:US},
    "kjpaw" => KresseJoubert,
    "bpaw" => Bloechl,
)
const Maybe{T} = Union{Nothing,T}

function analyse_pp_name(name::AbstractString)
    v = Vector{Any}(nothing, 5)
    prefix = lowercase(splitext(name)[1])
    if length(split(prefix, "."; limit = 2)) >= 2
        element, middle = split(prefix, "."; limit = 2)
    else
        return v
    end
    fields = split(split(middle, "_"; limit = 2)[1], "-")  # Ignore the free field
    @assert 1 <= length(fields) <= 5
    v[1] = occursin("rel", fields[1]) ? true : false
    for (i, x) in enumerate(fields)
        i >= 2 && break
        m = match(r"(starnl|starhnl)", x)
        if !isnothing(m)
            v[2] = NL_STATE[m[1]]()
            break
        end
    end
    i3 = 0
    for (i, x) in enumerate(fields)
        i >= 3 && break
        m = match(r"(pz|vwm|pbe|blyp|pw91|tpss|coulomb)", x)
        if !isnothing(m)
            i3, v[3] = i, FUNCTIONAL_TYPE[m[1]]()
            break
        end
    end
    if i3 != 0 && length(fields) - i3 == 2
        v[4] = fields[i3+1]
    end
    m = match(r"(ae|mt|bhs|vbc|van|rrkjus|rrkj|kjpaw|bpaw)", fields[end])
    v[5] = !isnothing(m) ? PSEUDIZATION_TYPE[m[1]]() : ""
    return v
end # function analyse_pp_name

"""
    list_elements()

List all elements that has pseudopotentials available in `PSlibrary`.
"""
function list_elements()
    s = raw"""
    H                                                  He
    Li Be                               B  C  N  O  F  Ne
    Na Mg                               Al Si P  S  Cl Ar
    K  Ca Sc Ti V  Cr Mn Fe Co Ni Cu Zn Ga Ge As Se Br Kr
    Rb Sr Y  Zr Nb Mo Tc Ru Rh Pd Ag Cd In Sn Sb Te I  Xe
    Cs Ba    Hf Ta W  Re Os Ir Pt Au Hg Tl Pb Bi Po At Rn
    Fr Ra
          La Ce Pr Nd Pm Sm Eu Gd Tb Dy Ho Er Tm Yb Lu
          Ac Th Pa U  Np Pu
    """
    println(s)
    return pairs(AVAILABLE_ELEMENTS)
end # function list_elements

"""
    list_potentials(element[, verbose, db])

List all pseudopotentials in PSlibrary for a specific element (abbreviation or index).

# Arguments
- `element::Union{AbstractString,Integer}`: the element to find pseudopotentials with. The integer corresponding to the element's atomic index.
- `verbose::Bool=false`: to show the detailed information inferred from the pseudopotential's name according to the [standard naming convention](https://www.quantum-espresso.org/pseudopotentials/naming-convention).
- `db::AbstractString="\$element.jld2"`: The path to save the database file.
"""
function list_potentials(
    element::AbstractString,
    verbose::Bool = false,
    db::AbstractString = "$element.jld2",
)
    element = uppercasefirst(lowercase(element))
    @assert(element ∈ AVAILABLE_ELEMENTS, "element $element is not recognized!")
    if isfile(db)
        @load db df
    else
        dir = joinpath(@__DIR__, "../data/")
        file = dir * lowercase(element) * ".json"
        if verbose
            df = DataFrame(
                name = String[],
                source = String[],
                rel = Maybe{Bool}[],
                Nl_state = Maybe{NlState}[],
                functional = Maybe{FunctionalType}[],
                orbit = Maybe{String}[],
                pseudo = Maybe{Pseudization}[],
                info = Maybe{String}[],
            )
            d = JSON.parsefile(file)
            for (k, v) in d
                push!(df, [k, v["href"], analyse_pp_name(k)..., v["meta"]])
            end
        else
            df = DataFrame(name = String[], source = String[], info = String[])
            d = JSON.parsefile(file)
            for (k, v) in d
                push!(df, [k, v["href"], v["meta"]])
            end
        end
    end
    @save "$element.jld2" df
    return df
end # function list_potentials
function list_potentials(
    i::Integer,
    verbose::Bool = false,
    db::AbstractString = "$element.jld2",
)
    1 <= i <= 94 || error("You can only access element 1 to 94!")
    return list_potentials(AVAILABLE_ELEMENTS[i], verbose, db)
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
"""
    download_potential(element::AbstractString, root::AbstractString)

Download one or multiple pseudopotentials from PSlibrary for a specific element under the same `root`.
"""
function download_potential(element::AbstractString, root::AbstractString)
    df = list_potentials(element)
    println(df)
    paths = String[]
    while true
        println("Enter the index (integer) for the potential that you want to download: ")
        i = parse(Int, readline())
        push!(paths, download(df[i, :].source, expanduser(root)))
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

function save_potential(
    element::AbstractString,
    file::PseudopotentialFile,
    db::AbstractString = "$element.jld2",
)
    df = list_potentials(element, true)
    inferred = analyse_pp_name(file.name)
    push!(df, [file.name, file.source, inferred..., file.info])
    @save db df
    return df
end # function save_potential

end # module PSlibrary
