module PSlibrary

using DataFrames: DataFrame
using EzXML: parsehtml, root, nextelement, nodecontent
import JLD2: @save, @load
using REPL.Terminals: TTYTerminal
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
    list_elements, list_potential, download_potential, save_potential

struct PseudopotentialFile
    name::String
    source::String
    info::String
end

const LIBRARY_ROOT = "https://www.quantum-espresso.org/pseudopotentials/ps-library/"
const UPF_ROOT = "https://www.quantum-espresso.org"
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

function _parsehtml(element)
    url = LIBRARY_ROOT * element
    str = urldownload(url, true; parser = String)
    doc = parsehtml(str)
    primates = root(doc)
    anchors = findall("//table//a", primates)
    return map(findall("//table//a", primates)) do anchor
        (name = strip(nodecontent(anchor)), source = UPF_ROOT * anchor["href"], metadata = nodecontent(nextelement(anchor)))
    end
end # function _parsehtml

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
    list_potential(element[, db])

List all pseudopotentials in `PSlibrary` for a specific element (abbreviation or index).

# Arguments
- `element::Union{AbstractString,AbstractChar,Integer}`: the element to find pseudopotentials with. The integer corresponding to the element's atomic index.
- `db::AbstractString="\$element.jld2"`: the path to the database file.

See also: [`save_potential`](@ref)
"""
function list_potential(
    element::Union{AbstractString,AbstractChar},
    db::AbstractString = "$element.jld2",
)
    element = (uppercasefirst ∘ lowercase ∘ string)(element)
    @assert(element ∈ AVAILABLE_ELEMENTS, "element $element is not recognized!")
    if isfile(db)
        @load db df  # Load database `db` to variable `df`
    else
        df = DataFrame(
            name = String[],
            source = String[],
            # rel = Maybe{Bool}[],
            # Nl_state = Maybe{NlState}[],
            # functional = Maybe{FunctionalType}[],
            # orbit = Maybe{String}[],
            # pseudo = Maybe{Pseudization}[],
            info = Maybe{String}[],
        )
        map(_parsehtml(lowercase(element))) do meta
            push!(df, [meta.name, meta.source, meta.metadata])
        end
    end
    @save db df
    return df
end # function list_potential
function list_potential(i::Integer, db::AbstractString = "$(AVAILABLE_ELEMENTS[i]).jld2")
    1 <= i <= 94 || error("You can only access element 1 to 94!")
    return list_potential(AVAILABLE_ELEMENTS[i], db)
end # function list_potential

"""
    download_potential(element::AbstractString)
    download_potential(i::Integer)

Download one or multiple pseudopotentials from `PSlibrary` for a specific element.
"""
function download_potential(element::AbstractString)
    df = list_potential(element)
    display(df)
    paths = String[]
    while true
        print("Enter the index (integer) for the potential that you want to download: ")
        i = parse(Int, readline())
        print("Enter the path you want to save the file: ")
        path = readline()
        pp = urldownload(df[i, :].source, true; parser = String)
        if isempty(path)
            path, io = mktemp()
            write(io, pp)
        else
            open(expanduser(path), "w") do io
                write(io, pp)
            end
        end
        push!(paths, path)
        finished = pairs((true, false))[request("Finished?", RadioMenu(["yes", "no"]))]
        if finished
            break
        end
        continue
    end
    return paths
end # function download_potential
"""
    download_potential(element::AbstractString, root::AbstractString)

Download one or multiple pseudopotentials from `PSlibrary` for a specific element under the same `root`.
"""
function download_potential(element::AbstractString, root::AbstractString)
    df = list_potential(element)
    display(df)
    paths = String[]
    while true
        print("Enter the index (integer) for the potential that you want to download: ")
        i = parse(Int, readline())
        row = df[i, :]
        push!(paths, download(row.source, expanduser(joinpath(root, row.name))))
        finished = pairs((true, false))[request("Finished?", RadioMenu(["yes", "no"]))]
        if finished
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

"""
    save_potential(element, file[, db])

Save a `PseudopotentialFile` to the `element`'s list.

# Arguments
- `element::Union{AbstractString,Integer}`: the element to save pseudopotentials with. The integer corresponding to the element's atomic index.
- `file::PseudopotentialFile`: the object that stores the information of that file.
- `db::AbstractString="\$element.jld2"`: the path to the database file.

See also: [`list_potential`](@ref)
"""
function save_potential(
    element::AbstractString,
    file::PseudopotentialFile,
    db::AbstractString = "$element.jld2",
)
    df = list_potential(element)
    inferred = analyse_pp_name(file.name)
    push!(df, [file.name, file.source, inferred..., file.info])
    @save db df
    return df
end # function save_potential
function save_potential(
    i::Integer,
    file::PseudopotentialFile,
    db::AbstractString = "$(AVAILABLE_ELEMENTS[i]).jld2",
)
    1 <= i <= 94 || error("You can only access element 1 to 94!")
    return save_potential(AVAILABLE_ELEMENTS[i], file, db)
end # function save_potential

end # module PSlibrary
