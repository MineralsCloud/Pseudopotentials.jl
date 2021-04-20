using AcuteML

export UPF, PpInfo, PpHeader

@aml struct PpInfo "PP_INFO"
    content::String, txt""
    inputfile::UN{String}, "PP_INPUTFILE"
end

@aml struct PpHeader "PP_HEADER"
    generated::String, att"generated"
    author::String, att"author"
    date::String, att"date"
    comment::String, att"comment"
    element::String, att"element"
    pseudo_type::String, att"pseudo_type"
    relativistic::String, att"relativistic"
    is_ultrasoft::String, att"is_ultrasoft"
    is_paw::String, att"is_paw"
    is_coulomb::String, att"is_coulomb"
    has_so::String, att"has_so"
    has_wfc::String, att"has_wfc"
    has_gipaw::String, att"has_gipaw"
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

@aml struct PpMesh "PP_MESH"
    dx::UN{Float64}, att"dx"
    mesh::UN{Int}, att"mesh"
    xmin::UN{Float64}, att"xmin"
    rmax::Float64, att"rmax"
    zmesh::UN{Float64}, att"zmesh"
    r::String, "PP_R"
    rab::String, "PP_RAB"
end

@aml struct UPF doc"UPF"
    version::VersionNumber, att"version"
    info::PpInfo, "PP_INFO"
    header::PpHeader, "PP_HEADER"
    mesh::PpMesh, "PP_MESH"
    # nlcc::UN{PpNlcc}, "PP_NLCC"
    # pp_local::Vector, "PP_LOCAL"
    # nonlocal, "PP_NONLOCAL"
    # semilocal::UN, "PP_SEMILOCAL"
    # pswfc = nothing, "PP_PSWFC"
    # full_wfc::UN, "PP_FULL_WFC"
    # rhoatom, "PP_RHOATOM"
    # paw::UN, "PP_PAW"
end

Base.read(io::IO, ::Type{UPF}) = read(io, String) |> parsexml |> UPF
Base.read(filename::AbstractString, ::Type{UPF}) = read(filename, String) |> parsexml |> UPF
