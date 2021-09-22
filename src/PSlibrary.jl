module PSlibrary

using DataFrames: DataFrame, groupby
using AcuteML: UN, parsehtml, root, nextelement, nodecontent
using REPL.TerminalMenus: RadioMenu, request

export list_elements, list_potentials, download_potentials

abstract type ExchangeCorrelationFunctional end
abstract type LocalDensityApproximationFunctional <: ExchangeCorrelationFunctional end
abstract type GeneralizedGradientApproximationFunctional <: ExchangeCorrelationFunctional end
abstract type MetaGGAFunctional <: ExchangeCorrelationFunctional end
abstract type HybridFunctional <: ExchangeCorrelationFunctional end
struct PerdewZunger <: LocalDensityApproximationFunctional end
struct VoskoWilkNusair <: LocalDensityApproximationFunctional end
struct PerdewBurkeErnzerhof <: GeneralizedGradientApproximationFunctional end
struct BeckeLeeYangParr <: HybridFunctional end
struct PerdewWang91 <: GeneralizedGradientApproximationFunctional end
struct TaoPerdewStaroverovScuseria <: MetaGGAFunctional end
struct Coulomb <: ExchangeCorrelationFunctional end

abstract type Pseudization end
abstract type NormConserving <: Pseudization end
abstract type Ultrasoft <: Pseudization end
abstract type AllElectron <: Pseudization end
abstract type ProjectorAugmentedWaves <: AllElectron end
struct KresseJoubert <: ProjectorAugmentedWaves end
struct Blöchl <: ProjectorAugmentedWaves end
struct TroullierMartins <: NormConserving end
struct BacheletHamannSchlüter <: NormConserving end
struct VonBarthCar <: NormConserving end
struct Vanderbilt <: Ultrasoft end
struct RappeRabeKaxirasJoannopoulos <: NormConserving end
struct RappeRabeKaxirasJoannopoulosUltrasoft <: Ultrasoft end

const LIBRARY_ROOT = "https://www.quantum-espresso.org/pseudopotentials/ps-library/"
const UPF_ROOT = "https://www.quantum-espresso.org"
const ELEMENTS = (
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
const DATABASE = DataFrame(
    element = [],
    name = String[],
    rel = UN{Bool}[],
    Nl_state = UN{String}[],
    functional = UN{ExchangeCorrelationFunctional}[],
    orbit = UN{String}[],
    pseudization = UN{Pseudization}[],
    src = String[],
)
const PERIODIC_TABLE = raw"""
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
const NL_STATE = (starnl = "OneCoreHole", starhnl = "HalfCoreHole")

function analyse_pp_name(name)
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
        if m !== nothing
            v[2] = NL_STATE[Symbol(m[1])]
            break
        end
    end
    i3 = 0
    for (i, x) in enumerate(fields)
        i >= 3 && break
        m = match(r"(pz|vwn|pbe|blyp|pw91|tpss|coulomb)", x)
        if m !== nothing
            type = m[1]
            functional = if type == "pz"
                PerdewZunger()
            elseif type == "vwn"
                VoskoWilkNusair()
            elseif type == "pbe"
                PerdewBurkeErnzerhof()
            elseif type == "blyp"
                BeckeLeeYangParr()
            elseif type == "pw91"
                PerdewWang91()
            elseif type == "tpss"
                TaoPerdewStaroverovScuseria()
            elseif type == "coulomb"
                Coulomb()
            end
            i3, v[3] = i, functional
            break
        end
    end
    if i3 != 0 && length(fields) - i3 == 2
        v[4] = fields[i3+1]
    end
    m = match(r"(ae|mt|bhs|vbc|van|rrkjus|rrkj|kjpaw|bpaw)", fields[end])
    type = m[1]
    pseudization = if type == "ae"
        AllElectron()
    elseif type == "mt"
        TroullierMartins()
    elseif type == "bhs"
        BacheletHamannSchlüter()
    elseif type == "vbc"
        VonBarthCar()
    elseif type == "van"
        Vanderbilt()
    elseif type == "rrkj"
        RappeRabeKaxirasJoannopoulos()
    elseif type == "rrkjus"
        RappeRabeKaxirasJoannopoulosUltrasoft()
    elseif type == "kjpaw"
        KresseJoubert()
    elseif type == "bpaw"
        Blöchl()
    end
    v[5] = m !== nothing ? pseudization : nothing
    return v
end

function _parsehtml(element)
    url = LIBRARY_ROOT * element
    path = download(url)
    str = read(path, String)
    doc = parsehtml(str)
    primates = root(doc)
    anchors = findall("//table//a", primates)
    return map(anchors) do anchor
        (
            name = strip(nodecontent(anchor)),
            src = UPF_ROOT * anchor["href"],
            metadata = nodecontent(nextelement(anchor)),
        )
    end
end

"""
    list_elements(pt=true)

List all elements that has pseudopotentials available in `PSlibrary`. Print the periodic table if `pt` is `true`.
"""
function list_elements(pt = true)
    if pt
        println(PERIODIC_TABLE)
    end
    return groupby(unique!(DATABASE), :element)
end

"""
    list_potentials(element::Union{AbstractString,AbstractChar,Integer})

List all pseudopotentials in `PSlibrary` for a specific element (abbreviation or index).
"""
function list_potentials(element::Union{AbstractString,AbstractChar})
    element = lowercase(string(element))
    @assert element in ELEMENTS "element $element is not recognized!"
    for meta in _parsehtml(element)
        push!(
            DATABASE,
            [uppercasefirst(element), meta.name, analyse_pp_name(meta.name)..., meta.src],
        )
    end
    return list_elements(false)[(uppercasefirst(element),)]
end
function list_potentials(atomic_number::Integer)
    @assert 1 <= atomic_number <= 94
    element = ELEMENTS[atomic_number]
    return list_potentials(element)
end

"""
    download_potential(element::Union{AbstractString,AbstractChar,Integer})

Download one or multiple pseudopotentials from `PSlibrary` for a specific element.
"""
function download_potentials(element)
    df = list_potentials(element)
    display(df)
    paths, finished = String[], false
    while !finished
        printstyled("Enter its index (integer) to download a potential: "; color = :green)
        i = parse(Int, readline())
        printstyled(
            "Enter the file path to save the potential (press enter to skip): ";
            color = :green,
        )
        str = readline()
        path = abspath(expanduser(isempty(str) ? tempname() : strip(str)))  # `abspath` is necessary since the path will depend on where you run it
        download(df.src[i], path)
        push!(paths, path)
        finished = request("Finished?", RadioMenu(["yes", "no"])) == 1
    end
    return paths
end

end
