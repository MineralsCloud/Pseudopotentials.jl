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
    CoreValenceInteraction,
    SemicoreValence,
    CoreValence,
    NonLinearCoreCorrection,
    NLCC,
    LinearCoreCorrection

"""
    PseudopotentialFormat
Represent all possible pseudopotential file formats.
"""
abstract type PseudopotentialFormat end

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

abstract type CoreHoleEffect end
struct HalfCoreHole <: CoreHoleEffect end
struct FullCoreHole <: CoreHoleEffect end

abstract type CoreValenceInteraction end
struct SemicoreValence <: CoreValenceInteraction
    orbital::Char
end
struct CoreValence <: CoreValenceInteraction
    orbital::Char
end
struct NonLinearCoreCorrection <: CoreValenceInteraction end
struct LinearCoreCorrection <: CoreValenceInteraction end
const NLCC = NonLinearCoreCorrection

function Base.show(
    io::IO,
    x::Union{ExchangeCorrelationFunctional,Pseudization,CoreValenceInteraction},
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
Base.string(x::SemicoreValence) = "Semicore($(x.orbital))"
Base.string(x::CoreValence) = "Core($(x.orbital))"
Base.string(x::NonLinearCoreCorrection) = "NLCC"
Base.string(x::LinearCoreCorrection) = "LCC"

include("PSlibrary.jl")

end
