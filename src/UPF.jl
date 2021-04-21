using AcuteML

export UPF

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
    is_ultrasoft, att"is_ultrasoft"
    is_paw, att"is_paw"
    is_coulomb = false, att"is_coulomb"
    has_so = false, att"has_so"
    has_wfc, att"has_wfc"
    has_gipaw = false, att"has_gipaw"
    paw_as_gipaw, att"paw_as_gipaw"
    core_correction, att"core_correction"
    @extractor begin
        is_ultrasoft = istrue(is_ultrasoft)
        is_paw = istrue(is_paw)
        is_coulomb = istrue(is_coulomb)
        has_so = istrue(has_so)
        has_wfc = istrue(has_wfc)
        has_gipaw = istrue(has_gipaw)
        paw_as_gipaw = istrue(paw_as_gipaw)
        core_correction = istrue(core_correction)
    end
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

@aml struct Mesh "PP_MESH"
    dx::UN{Float64}, att"dx"
    mesh::UN{Int}, att"mesh"
    xmin::UN{Float64}, att"xmin"
    rmax::Float64, att"rmax"
    zmesh::UN{Float64}, att"zmesh"
    r, "PP_R"
    rab, "PP_RAB"
    @extractor begin
        r = parsevec(r)
        rab = parsevec(rab)
    end
end

@aml struct UPF doc"UPF"
    version::VersionNumber, att"version"
    info::Info, "PP_INFO"
    header::Header, "PP_HEADER"
    mesh::Mesh, "PP_MESH", checkmesh
    # nlcc::UN{PpNlcc}, "PP_NLCC"
    local_, "PP_LOCAL"
    # nonlocal, "PP_NONLOCAL"
    # semilocal::UN, "PP_SEMILOCAL"
    # pswfc = nothing, "PP_PSWFC"
    # full_wfc::UN, "PP_FULL_WFC"
    rhoatom, "PP_RHOATOM"
    # paw::UN, "PP_PAW"
    @extractor begin
        local_ = parsevec(local_)
        rhoatom = parsevec(rhoatom)
    end
end

function checkmesh(x)
    return x.mesh == length(x.r) == length(x.rab) && size(x.r) == size(x.rab)
end

Base.parse(::Type{UPF}, str) = UPF(parsexml(str))
