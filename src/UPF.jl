using Dates: DateTime

using Parameters: @with_kw

@with_kw struct UPF
    info::UpfInfo
    header::UpfHeader
    mesh
    nlcc = nothing
    local::Vector
    nonlocal
    semilocal = nothing
    pswfc = nothing
    full_wfc = nothing
    rhoatom
    paw = nothing
end

struct UpfInfo
    content::String
    inputfile::String
end

struct UpfHeader
    generated::String
    author::Vector{String}
    date::DateTime
    comment::String
    element::String
    pseudo_type::String
    relativistic::String
    is_ultrasoft::Bool
    is_paw::Bool
    is_coulomb::Bool
    has_so::Bool
    has_wfc::Bool
    has_gipaw::Bool
    paw_as_gipaw::Bool
    core_correction::Bool
    functional::String
    z_valence::Float64
    total_psenergy::Float64
    wfc_cutoff::Float64
    rho_cutoff::Float64
    l_max::Float64
    l_max_rho::Float64
    l_local::Float64
    mesh_size::Int
    number_of_wfc::Int
    number_of_proj::Int
end
