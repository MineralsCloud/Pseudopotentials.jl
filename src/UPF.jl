using AcuteML

export UPF, getdata

istrue(str) = occursin(r"t(rue)?"i, str)

function parsevec(str)
    vec = Float64[]
    for line in split(str, r"\R"; keepempty = false)
        append!(vec, map(x -> parse(Float64, x), split(line, r"[ \t]"; keepempty = false)))
    end
    return vec
end

@aml struct Info "PP_INFO"
    text::String, txt""
    inputfile::UN{String}, "PP_INPUTFILE"
end

@aml struct Header empty"PP_HEADER"
    generated::String, att"generated"
    author::String, att"author"
    date::String, att"date"
    comment::String, att"comment"
    element::String, att"element"
    pseudo_type::String, att"pseudo_type"
    relativistic::String, att"relativistic"
    is_ultrasoft::String, att"is_ultrasoft"
    is_paw::String, att"is_paw"
    is_coulomb::String = ".false.", att"is_coulomb"
    has_so::String = ".false.", att"has_so"
    has_wfc::String, att"has_wfc"
    has_gipaw::String = ".false.", att"has_gipaw"
    paw_as_gipaw::String, att"paw_as_gipaw"
    core_correction::String, att"core_correction"
    functional::String, att"functional"
    z_valence::Float64, att"z_valence"
    total_psenergy::Float64 = 0, att"total_psenergy"
    wfc_cutoff::Float64 = 0, att"wfc_cutoff"
    rho_cutoff::Float64 = 0, att"rho_cutoff"
    l_max::Float64, att"l_max"
    l_max_rho::Float64, att"l_max_rho"
    l_local::UN{Int}, att"l_local"
    mesh_size::UInt, att"mesh_size"
    number_of_wfc::UInt, att"number_of_wfc"
    number_of_proj::UInt, att"number_of_proj"
end

@aml struct R "PP_R"
    size::UInt, att"size"
    text::String, txt""
end

@aml struct Rab "PP_RAB"
    size::UInt, att"size"
    text::String, txt""
end

@aml struct Mesh "PP_MESH"
    dx::UN{Float64}, att"dx"
    mesh::UN{Int}, att"mesh"
    xmin::UN{Float64}, att"xmin"
    rmax::Float64, att"rmax"
    zmesh::UN{Float64}, att"zmesh"
    r::R, "PP_R"
    rab::Rab, "PP_RAB"
end

@aml struct Chi "PP_CHI"
    n::UN{UInt}, att"n"
    l::UInt, att"l"
    index::UN{Int}, att"index"
    label::UN{String}, att"label"
    occupation::Float64, att"occupation"
    pseudo_energy::UN{Float64}, att"pseudo_energy"
    cutoff_radius::UN{Float64}, att"cutoff_radius"
    ultrasoft_cutoff_radius::UN{Float64}, att"ultrasoft_cutoff_radius"
    text::String, txt""
end

@aml struct Pswfc "PP_PSWFC"
    chi::Vector{Chi}, "PP_CHI"
end

@aml struct Local "PP_LOCAL"
    text::String, txt""
end

@aml struct Beta "PP_BETA"
    angular_momentum::Int, att"angular_momentum"
    index::UN{Int}, att"index"
    label::UN{String}, att"label"
    cutoff_radius::UN{Float64}, att"cutoff_radius"
    cutoff_radius_index::UN{Int}, att"cutoff_radius_index"
    norm_conserving_radius::UN{Float64}, att"norm_conserving_radius"
    ultrasoft_cutoff_radius::Float64, att"ultrasoft_cutoff_radius"
    text::String, txt""
end

@aml struct Dij "PP_DIJ"
    columns::UInt, att"columns"
    size::UInt, att"size"
    type::String, att"type"
    text::String, txt""
end

@aml struct Augmentation "PP_AUGMENTATION"
    PP_RINNER::UN
end

@aml struct Nonlocal "PP_NONLOCAL"
    beta::Vector{Beta}, "PP_BETA"
    dij::Dij, "PP_DIJ"
    augmentation::UN{Augmentation}, "PP_AUGMENTATION"
end

@aml struct RhoAtom "PP_RHOATOM"
    text::String, txt""
end

@aml struct UPF doc"UPF"
    version::VersionNumber, att"version"
    info::Info, "PP_INFO"
    header::Header, "PP_HEADER"
    mesh::Mesh, "PP_MESH", validate
    # nlcc::UN{PpNlcc}, "PP_NLCC"
    loc::Local, "PP_LOCAL"
    nonlocal::Nonlocal, "PP_NONLOCAL"
    # semilocal::UN, "PP_SEMILOCAL"
    pswfc::Pswfc, "PP_PSWFC"
    # full_wfc::UN, "PP_FULL_WFC"
    rhoatom::RhoAtom, "PP_RHOATOM"
    # paw::UN, "PP_PAW"
end

function validate(x::Mesh)
    r, rab = map(getdata, (x.r, x.rab))
    return x.mesh == length(r) == length(rab) && size(r) == size(rab)
end

function fixenumeration!(doc, name)
    children = findall("//*[contains(name(), '$name')]", doc)  # See https://stackoverflow.com/a/40124534/3260253
    if isempty(children)  # No need to change anything
        return doc
    else
        for child in children
            setnodename!(child, name)
        end
        return doc
    end
end

function Base.parse(::Type{UPF}, str)
    doc = parsexml(str)
    doc = fixenumeration!(doc, "PP_CHI")
    doc = fixenumeration!(doc, "PP_BETA")
    return UPF(doc)
end

getdata(x::Union{RhoAtom,Local,R,Rab,Chi,Beta}) = parsevec(x.text)
getdata(x::Dij) = parse(Float64, x.text)

function Base.getproperty(x::Header, name::Symbol)
    if name in (
        :is_ultrasoft,
        :is_paw,
        :is_coulomb,
        :has_so,
        :has_wfc,
        :has_gipaw,
        :paw_as_gipaw,
        :core_correction,
    )
        return istrue(getfield(x, name))
    else
        return getfield(x, name)
    end
end
