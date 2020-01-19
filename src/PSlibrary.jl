module PSlibrary

using DataFrames: DataFrame
import JSON

using Pseudopotentials:
    FunctionalType,
    PzExchCorr,
    VwnExchCorr,
    PbeExchCorr,
    BlypExchCorr,
    Pw91GradientCorrected,
    TpssMetaGGA,
    Coulomb,
    PseudizationType,
    AllElectron,
    MartinsTroullier,
    BacheletHamannSchlueter,
    VonBarthCar,
    VanderbiltUltrasoft,
    RrkjNormConserving,
    RrkjusUltrasoft,
    Kjpaw,
    Bpaw,
    NlState,
    OneCoreHole,
    HalfCoreHole

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
const NL_STATE = Dict("starnl" => OneCoreHole, "starhnl" => HalfCoreHole)
const FUNCTIONAL_TYPE = Dict(
    "pz" => PzExchCorr,
    "vwn" => VwnExchCorr,
    "pbe" => PbeExchCorr,
    "blyp" => BlypExchCorr,
    "pw91" => Pw91GradientCorrected,
    "tpss" => TpssMetaGGA,
    "coulomb" => Coulomb,
)
const PSEUDIZATION_TYPE = Dict(
    "ae" => AllElectron,
    "mt" => MartinsTroullier,
    "bhs" => BacheletHamannSchlueter,
    "vbc" => VonBarthCar,
    "van" => VanderbiltUltrasoft,
    "rrkj" => RrkjNormConserving,
    "rrkjus" => RrkjusUltrasoft,
    "kjpaw" => Kjpaw,
    "bpaw" => Bpaw,
)
const Maybe{T} = Union{Nothing,T}

function parse_standardname(name::AbstractString)
    prefix = lowercase(splitext(name)[1])
    element, middle = split(prefix, "."; limit = 2)
    fields = split(split(middle, "_"; limit = 2)[1], "-")  # Ignore the free field
    @assert 1 <= length(fields) <= 5
    v = Vector{Any}(nothing, 5)
    v[1] = occursin("rel", fields[1]) ? "true" : "false"
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
end # function parse_standardname

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
function list_potentials(element::AbstractString, verbose = false)
    @assert lowercase(element) ∈ AVAILABLE_ELEMENTS
    dir = joinpath(@__DIR__, "../data/")
    file = dir * lowercase(element) * ".json"
    if verbose
        df = DataFrame(
            name = String[],
            source = String[],
            relativistic = String[],
            Nl_state = Maybe{NlState}[],
            functional_type = Maybe{FunctionalType}[],
            orbit = Maybe{String}[],
            pseudization_type = Maybe{PseudizationType}[],
            summary = Maybe{String}[],
        )
        d = JSON.parsefile(file)
        for (k, v) in d
            push!(df, [k, v["href"], parse_standardname(k)..., v["meta"]])
        end
    else
        df = DataFrame(name = String[], source = String[], summary = String[])
        d = JSON.parsefile(file)
        for (k, v) in d
            println(v["meta"])
            push!(df, [k, v["href"], v["meta"]])
        end
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
