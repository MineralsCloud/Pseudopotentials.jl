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
    generated::UN{String}, att"generated"
    author::UN{String}, att"author"
    date::UN{String}, att"date"
    comment::UN{String}, att"comment"
    element::String, att"element"
    pseudo_type::String, att"pseudo_type"
    relativistic::String, att"relativistic"
    is_ultrasoft::String, att"is_ultrasoft"
    is_paw::String, att"is_paw"
    is_coulomb::UN{String} = ".false.", att"is_coulomb"
    has_so::UN{String} = ".false.", att"has_so"
    has_wfc::String, att"has_wfc"
    has_gipaw::UN{String} = ".false.", att"has_gipaw"
    paw_as_gipaw::UN{String}, att"paw_as_gipaw"  # Suggested "required" but can be missing
    core_correction::String, att"core_correction"
    functional::String, att"functional"
    z_valence::Float64, att"z_valence"
    total_psenergy::UN{Float64} = 0, att"total_psenergy"
    wfc_cutoff::UN{Float64} = 0, att"wfc_cutoff"
    rho_cutoff::UN{Float64} = 0, att"rho_cutoff"
    l_max::Float64, att"l_max"
    l_max_rho::UN{Float64}, att"l_max_rho"  # Suggested "required" but can be missing
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
    rmax::UN{Float64}, att"rmax"  # Suggested "required" but can be missing
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

@aml struct Vnl "PP_VNL"
    l::String, att"L"
    j::String, att"J"
    text::String, txt""
end

@aml struct Semilocal "PP_SEMILOCAL"
    chi::Vector{Vnl}, "PP_VNL"
end

@aml struct Nlcc "PP_NLCC"
    text::String, txt""
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
    ultrasoft_cutoff_radius::UN{Float64}, att"ultrasoft_cutoff_radius"  # Suggested "required" but can be missing
    text::String, txt""
end

@aml struct Dij "PP_DIJ"
    columns::UInt, att"columns"
    size::UInt, att"size"
    type::String, att"type"
    text::String, txt""
end

@aml struct Q "PP_Q"
    text::String, txt""
end

@aml struct Multipoles "PP_MULTIPOLES"
    text::String, txt""
end

@aml struct Qfcoeff "PP_QFCOEFF"
    text::String, txt""
end

@aml struct Rinner "PP_RINNER"
    text::String, txt""
end

@aml struct Qijl "PP_QIJL"
    angular_momentum::Int, att"angular_momentum"
    first_index::UN{Int}, att"first_index"
    second_index::UN{Int}, att"second_index"
    composite_index::UN{Int}, att"composite_index"
    is_null::UN{String}, att"is_null"
    text::String, txt""
end

@aml struct Augmentation "PP_AUGMENTATION"
    q_with_l::String, att"q_with_l"
    nqf::UN{Int}, att"nqf"
    nqlc::UN{Int}, att"nqlc"
    shape::UN{String}, att"shape"
    iraug::UN{Int}, att"iraug"
    raug::UN{Float64}, att"raug"
    augmentation_epsilon::UN{Float64}, att"augmentation_epsilon"
    cutoff_r::UN{Float64}, att"cutoff_r"
    cutoff_r_index::UN{Int}, att"cutoff_r_index"
    l_max_aug::UN{Int}, att"l_max_aug"
    q::Q, "PP_Q"
    multipoles::Multipoles, "PP_MULTIPOLES"
    qfcoeff::UN{Qfcoeff}, "PP_QFCOEFF"
    rinner::UN{Rinner}, "PP_RINNER"
    qijl::Vector{Qijl}, "PP_QIJL"
end

@aml struct Nonlocal "PP_NONLOCAL"
    beta::Vector{Beta}, "PP_BETA"
    dij::Dij, "PP_DIJ"
    augmentation::UN{Augmentation}, "PP_AUGMENTATION"
end

@aml struct Rhoatom "PP_RHOATOM"
    text::String, txt""
end

@aml struct Aewfc "PP_AEWFC"
    l::UInt, att"l"
    index::UN{Int}, att"index"
    label::UN{String}, att"label"
    text::String, txt""
end

@aml struct FullWfc "PP_FULL_WFC"
    aewfc::Vector{Aewfc}, "PP_AEWFC"
end

@aml struct UPF doc"UPF"
    version::VersionNumber, att"version"
    info::Info, "PP_INFO"
    header::Header, "PP_HEADER"
    mesh::Mesh, "PP_MESH", validate
    nlcc::UN{Nlcc}, "PP_NLCC"
    loc::Local, "PP_LOCAL"
    nonlocal::Nonlocal, "PP_NONLOCAL"
    semilocal::UN{Semilocal}, "PP_SEMILOCAL"
    pswfc::UN{Pswfc}, "PP_PSWFC"
    full_wfc::UN{FullWfc}, "PP_FULL_WFC"
    rhoatom::Rhoatom, "PP_RHOATOM"
    # paw::UN{Paw}, "PP_PAW"
end

function validate(x::Mesh)
    r, rab = map(getdata, (x.r, x.rab))
    return x.mesh == length(r) == length(rab) && size(r) == size(rab)
end

function fixenumeration!(doc, name)
    children = findall("//*[contains(name(), '$name')]", doc)  # See https://stackoverflow.com/a/40124534/3260253
    if !isempty(children)  # Need to change something
        for child in children
            setnodename!(child, name)
        end
    end
    return doc
end

function Base.parse(::Type{UPF}, str)
    doc = parsexml(str)
    fixenumeration!(doc, "PP_CHI")
    fixenumeration!(doc, "PP_BETA")
    fixenumeration!(doc, "PP_AEWFC")
    fixenumeration!(doc, "PP_QIJL")
    return UPF(doc)
end

getdata(x::Union{Rhoatom,Nlcc,Local,R,Rab,Chi,Beta,Dij,Q,Multipoles,Qijl}) = parsevec(x.text)

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
