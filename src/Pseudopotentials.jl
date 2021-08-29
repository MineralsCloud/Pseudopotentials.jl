module Pseudopotentials

export UnifiedPseudopotentialFormat, VanderbiltUltraSoft, AndreaDalCorso, OldNormConserving
export pseudoformat

"""
    PseudopotentialFormat
Represent all possible pseudopotential file formats.
"""
abstract type PseudopotentialFormat end
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
        UnifiedPseudopotentialFormat
    elseif ext in (".VDB", ".VAN")
        VanderbiltUltraSoft
    elseif ext == ".RRKJ3"
        AndreaDalCorso
    else
        OldNormConserving
    end
end

include("UnifiedPseudopotentialFormat.jl")
include("PSlibrary.jl")

end
