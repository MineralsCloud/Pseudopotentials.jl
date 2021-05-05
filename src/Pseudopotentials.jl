module Pseudopotentials

export UnifiedPseudopotentialFormat, VanderbiltUltraSoft, AndreaDalCorso, OldNormConserving
export pseudoformat, islda, isgga

"""
    PseudopotentialFormat
Represent all possible pseudopotential file formats.
"""
abstract type PseudopotentialFormat end
"""
    UnifiedPseudopotentialFormat <: PseudopotentialFormat
A singleton representing the new UPF format.
If it doesn't work, the pseudopotential format is determined by
the file name.
"""
struct UnifiedPseudopotentialFormat <: PseudopotentialFormat end
"""
    VanderbiltUltraSoft <: PseudopotentialFormat
A singleton representing the Vanderbilt US pseudopotential code.
"""
struct VanderbiltUltraSoft <: PseudopotentialFormat end
"""
    AndreaDalCorso <: PseudopotentialFormat
A singleton representing the Andrea Dal Corso's code (old format).
"""
struct AndreaDalCorso <: PseudopotentialFormat end
"""
    OldNormConserving <: PseudopotentialFormat
A singleton representing the old PWscf norm-conserving format.
"""
struct OldNormConserving <: PseudopotentialFormat end

"""
    pseudoformat(data::AbstractString)

Return the pseudopotential format.

The pseudopotential file is assumed to be in the new UPF format.
If it doesn't work, the pseudopotential format is determined by
the file name:
- "*.vdb or *.van": Vanderbilt US pseudopotential code
- "*.RRKJ3": Andrea Dal Corso's code (old format)
- none of the above: old PWscf norm-conserving format
"""
function pseudoformat(data::AbstractString)
    ext = uppercase(splitext(data)[2])
    return if ext == ".UPF"
        UnifiedPseudopotentialFormat()
    elseif ext ∈ (".VDB", ".VAN")
        VanderbiltUltraSoft()
    elseif ext == ".RRKJ3"
        AndreaDalCorso()
    else
        OldNormConserving()
    end
end

abstract type FunctionalType end
struct PerdewZunger <: FunctionalType end
struct VoskoWilkNusair <: FunctionalType end
struct PerdewBurkeErnzerhof <: FunctionalType end
struct BeckeLeeYangParr <: FunctionalType end
struct PerdewWang91 <: FunctionalType end
struct TaoPerdewStaroverovScuseria <: FunctionalType end
struct Coulomb <: FunctionalType end

islda(::FunctionalType) = false
islda(::PerdewZunger) = true
islda(::VoskoWilkNusair) = true

isgga(::FunctionalType) = false
isgga(::PerdewBurkeErnzerhof) = true

Base.show(io::IO, ::PerdewZunger) = print(io, "PZ")
Base.show(io::IO, ::VoskoWilkNusair) = print(io, "VWN")
Base.show(io::IO, ::PerdewBurkeErnzerhof) = print(io, "PBE")
Base.show(io::IO, ::BeckeLeeYangParr) = print(io, "BLYP")
Base.show(io::IO, ::PerdewWang91) = print(io, "PW91")
Base.show(io::IO, ::TaoPerdewStaroverovScuseria) = print(io, "TPSS")
Base.show(io::IO, ::Coulomb) = print(io, "Coulomb")

abstract type Pseudization end
struct AllElectron <: Pseudization end
struct MartinsTroullier <: Pseudization end
struct BacheletHamannSchlueter <: Pseudization end
struct VonBarthCar <: Pseudization end
struct Vanderbilt <: Pseudization end
struct RappeRabeKaxirasJoannopoulos{T} <: Pseudization end
struct KresseJoubert <: Pseudization end
struct Bloechl <: Pseudization end

Base.show(io::IO, ::AllElectron) = print(io, "AE")
Base.show(io::IO, ::MartinsTroullier) = print(io, "MT")
Base.show(io::IO, ::BacheletHamannSchlueter) = print(io, "BHS")
Base.show(io::IO, ::VonBarthCar) = print(io, "VBC")
Base.show(io::IO, ::RappeRabeKaxirasJoannopoulos{:NC}) = print(io, "RRKJ")
Base.show(io::IO, ::RappeRabeKaxirasJoannopoulos{:US}) = print(io, "RRKJ US")
Base.show(io::IO, ::KresseJoubert) = print(io, "KJ PAW")
Base.show(io::IO, ::Bloechl) = print(io, "B PAW")

abstract type NlState end
struct OneCoreHole <: NlState end
struct HalfCoreHole <: NlState end

include("UnifiedPseudopotentialFormat.jl")
include("PSlibrary.jl")

end
