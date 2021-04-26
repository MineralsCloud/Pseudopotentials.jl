module PSlibrary

using DataFrames: DataFrame
using EzXML: parsehtml, root, nextelement, nodecontent
import JLD2: @save, @load
using REPL.TerminalMenus: RadioMenu, request
using UrlDownload: urldownload

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

export PseudopotentialFile,
    list_elements, list_potential, download_potential

struct PseudopotentialFile
    name::String
    source::String
    info::String
end

const Maybe{T} = Union{Nothing,T}
const LIBRARY_ROOT = "https://www.quantum-espresso.org/pseudopotentials/ps-library/"
const UPF_ROOT = "https://www.quantum-espresso.org"
const ELEMENTS = (
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
const PERIODIC_TABLE = DataFrame(
    element = collect(ELEMENTS),
    database = fill(
        DataFrame(
            name = String[],
            source = String[],
            # rel = Maybe{Bool}[],
            # Nl_state = Maybe{NlState}[],
            # functional = Maybe{FunctionalType}[],
            # orbit = Maybe{String}[],
            # pseudo = Maybe{Pseudization}[],
            info = Maybe{String}[],
        ),
        length(ELEMENTS),
    ),
)
const PERIODIC_TABLE_TEXT = raw"""
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
const NL_STATE = (starnl = OneCoreHole, starhnl = HalfCoreHole)
const FUNCTIONAL_TYPE = (
    pz = PerdewZunger,
    vwn = VoskoWilkNusair,
    pbe = PerdewBurkeErnzerhof,
    blyp = BeckeLeeYangParr,
    pw91 = PerdewWang91,
    tpss = TaoPerdewStaroverovScuseria,
    coulomb = Coulomb,
)
const PSEUDIZATION_TYPE = (
    ae = AllElectron,
    mt = MartinsTroullier,
    bhs = BacheletHamannSchlueter,
    vbc = VonBarthCar,
    van = Vanderbilt,
    rrkj = RappeRabeKaxirasJoannopoulos{:NC},
    rrkjus = RappeRabeKaxirasJoannopoulos{:US},
    kjpaw = KresseJoubert,
    bpaw = Bloechl,
)

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
            v[2] = NL_STATE[m[1]]()
            break
        end
    end
    i3 = 0
    for (i, x) in enumerate(fields)
        i >= 3 && break
        m = match(r"(pz|vwm|pbe|blyp|pw91|tpss|coulomb)", x)
        if m !== nothing
            i3, v[3] = i, FUNCTIONAL_TYPE[m[1]]()
            break
        end
    end
    if i3 != 0 && length(fields) - i3 == 2
        v[4] = fields[i3+1]
    end
    m = match(r"(ae|mt|bhs|vbc|van|rrkjus|rrkj|kjpaw|bpaw)", fields[end])
    v[5] = m !== nothing ? PSEUDIZATION_TYPE[m[1]]() : ""
    return v
end

function _parsehtml(element)
    url = LIBRARY_ROOT * element
    str = urldownload(url, true; parser = String)
    doc = parsehtml(str)
    primates = root(doc)
    anchors = findall("//table//a", primates)
    return map(findall("//table//a", primates)) do anchor
        (
            name = strip(nodecontent(anchor)),
            source = UPF_ROOT * anchor["href"],
            metadata = nodecontent(nextelement(anchor)),
        )
    end
end

"""
    list_elements()

List all elements that has pseudopotentials available in `PSlibrary`.
"""
function list_elements()
    println(PERIODIC_TABLE_TEXT)
    return PERIODIC_TABLE
end

"""
    list_potential(element[, db])

List all pseudopotentials in `PSlibrary` for a specific element (abbreviation or index).

# Arguments
- `element::Union{AbstractString,AbstractChar,Integer}`: the element to find pseudopotentials with. The integer corresponding to the element's atomic index.
- `db::AbstractString="\$element.jld2"`: the path to the database file.

See also: [`save_potential`](@ref)
"""
function list_potential(element::Union{AbstractString,AbstractChar})
    element = element |> string |> lowercase |> uppercasefirst
    @assert element ∈ ELEMENTS "element $element is not recognized!"
    i = findfirst(ELEMENTS .== element)
    return list_potential(i)
end
function list_potential(atomic_number::Integer)
    @assert 1 <= atomic_number <= 94 "atomic number be between 1 to 94!"
    element = ELEMENTS[atomic_number]
    df = DataFrame(name = String[], source = String[], info = Maybe{String}[])
    for meta in _parsehtml(lowercase(element))
        push!(df, [meta.name, meta.source, meta.metadata])
    end
    PERIODIC_TABLE[atomic_number, :database] = df
    return df
end

"""
    download_potential(element::AbstractString, filedir::AbstractString = "")
    download_potential(i::Integer, filedir::AbstractString = "")

Download one or multiple pseudopotentials from `PSlibrary` for a specific element.
"""
function download_potential(element::AbstractString, filedir::AbstractString = "")
    df = list_potential(element)
    display(df)
    paths, finished = String[], false
    while !finished
        printstyled("Enter its index (integer) to download a potential: "; color = :green)
        i = parse(Int, readline())
        potential = urldownload(df.source[i], true; parser = String)
        if isempty(filedir)
            printstyled(
                "Enter the file path to save the potential (press enter to skip): ";
                color = :green,
            )
            path = strip(readline())
        else
            path = expanduser(joinpath(filedir, df.name[i]))
        end
        if isempty(path)
            path, io = mktemp()
            write(io, potential)
        else
            open(expanduser(path), "w") do io
                write(io, potential)
            end
        end
        push!(paths, path)
        finished = (true, false)[request("Finished?", RadioMenu(["yes", "no"]))]
    end
    return paths
end
download_potential(i::Integer, args...) = download_potential(ELEMENTS[i], args...)

end
