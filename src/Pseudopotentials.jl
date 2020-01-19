module Pseudopotentials

export UnifiedPseudopotentialFormat, VanderbiltUltraSoft, AndreaDalCorso, OldNormConserving
export pseudopot_format, islda, isgga

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
    pseudopot_format(data::AbstractString)

Return the pseudopotential format.

The pseudopotential file is assumed to be in the new UPF format.
If it doesn't work, the pseudopotential format is determined by
the file name:
- "*.vdb or *.van": Vanderbilt US pseudopotential code
- "*.RRKJ3": Andrea Dal Corso's code (old format)
- none of the above: old PWscf norm-conserving format
"""
function pseudopot_format(data::AbstractString)
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
struct PzExchCorr <: FunctionalType end
struct VwnExchCorr <: FunctionalType end
struct PbeExchCorr <: FunctionalType end
struct BlypExchCorr <: FunctionalType end
struct Pw91GradientCorrected <: FunctionalType end
struct TpssMetaGGA <: FunctionalType end
struct Coulomb <: FunctionalType end

islda(::FunctionalType) = false
islda(::PzExchCorr) = true
islda(::VwnExchCorr) = true

isgga(::FunctionalType) = false
isgga(::PbeExchCorr) = true

abstract type PseudizationType end
struct AllElectron <: PseudizationType end
struct MartinsTroullier <: PseudizationType end
struct BacheletHamannSchlueter <: PseudizationType end
struct VonBarthCar <: PseudizationType end
struct VanderbiltUltrasoft <: PseudizationType end
struct RrkjNormConserving <: PseudizationType end
struct RrkjusUltrasoft <: PseudizationType end
struct Kjpaw <: PseudizationType end
struct Bpaw <: PseudizationType end

abstract type NlState end
struct OneCoreHole <: NlState end
struct HalfCoreHole <: NlState end

# include("UPF.jl")
include("PSlibrary.jl")

end
