module Pseudopotentials

export PerdewZunger,
    VoskoWilkNusair,
    PerdewBurkeErnzerhof,
    PBE,
    PerdewBurkeErnzerhofRevisedForSolids,
    PBEsol,
    BeckeLeeYangParr,
    BLYP,
    PerdewWang91,
    TaoPerdewStaroverovScuseria,
    TPSS,
    Coulomb,
    KresseJoubert,
    Blöchl,
    TroullierMartins,
    BacheletHamannSchlüter,
    BHS,
    VonBarthCar,
    Vanderbilt,
    RappeRabeKaxirasJoannopoulos,
    RRKJ,
    RappeRabeKaxirasJoannopoulosUltrasoft,
    RRKJUs,
    ValenceCoreState,
    SemicoreState,
    CoreState,
    NonLinearCoreCorrection,
    NLCC

"""
    Pseudopotential

Represent a pseudopotential file.
"""
abstract type Pseudopotential end

"""
    ExchangeCorrelationFunctional

Represent exchange-correlation functional types.
"""
abstract type ExchangeCorrelationFunctional end
abstract type LocalDensityApproximation <: ExchangeCorrelationFunctional end
abstract type GeneralizedGradientApproximation <: ExchangeCorrelationFunctional end
abstract type MetaGGA <: ExchangeCorrelationFunctional end
abstract type Hybrid <: ExchangeCorrelationFunctional end
struct PerdewZunger <: LocalDensityApproximation end
struct VoskoWilkNusair <: LocalDensityApproximation end
struct PerdewBurkeErnzerhof <: GeneralizedGradientApproximation end
struct PerdewBurkeErnzerhofRevisedForSolids <: GeneralizedGradientApproximation end
struct BeckeLeeYangParr <: Hybrid end
struct PerdewWang91 <: GeneralizedGradientApproximation end
struct TaoPerdewStaroverovScuseria <: MetaGGA end
struct Coulomb <: ExchangeCorrelationFunctional end
const PBE = PerdewBurkeErnzerhof
const PBEsol = PerdewBurkeErnzerhofRevisedForSolids
const BLYP = BeckeLeeYangParr
const TPSS = TaoPerdewStaroverovScuseria

"""
    Pseudization

Represent the pseudization types.
"""
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
const BHS = BacheletHamannSchlüter
const RRKJ = RappeRabeKaxirasJoannopoulos
const RRKJUs = RappeRabeKaxirasJoannopoulosUltrasoft

struct CoreHole
    half::Bool
end

abstract type ValenceCoreState end
struct SemicoreState <: ValenceCoreState
    orbital::Char
end
struct CoreState <: ValenceCoreState
    orbital::Char
end
struct NonLinearCoreCorrection <: ValenceCoreState end
const NLCC = NonLinearCoreCorrection

function Base.show(
    io::IO,
    x::Union{ExchangeCorrelationFunctional,Pseudization,ValenceCoreState},
)
    print(IOContext(io, :limit => true), string(x))
end

Base.string(x::ExchangeCorrelationFunctional) = string(typeof(x))
Base.string(x::PerdewBurkeErnzerhof) = "PBE"
Base.string(x::PerdewBurkeErnzerhofRevisedForSolids) = "PBEsol"
Base.string(x::BeckeLeeYangParr) = "BLYP"
Base.string(x::TaoPerdewStaroverovScuseria) = "TPSS"
Base.string(x::Pseudization) = string(typeof(x))
Base.string(x::TroullierMartins) = "TM"
Base.string(x::BacheletHamannSchlüter) = "BHS"
Base.string(x::RappeRabeKaxirasJoannopoulos) = "RRKJ"
Base.string(x::RappeRabeKaxirasJoannopoulosUltrasoft) = "RRKJUs"
Base.string(x::SemicoreState) = "Semicore($(x.orbital))"
Base.string(x::CoreState) = "Core($(x.orbital))"
Base.string(x::NonLinearCoreCorrection) = "NLCC"

end
