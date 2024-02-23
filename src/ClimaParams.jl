module ClimaParams

using TOML
using DocStringExtensions

export AbstractTOMLDict
export ParamDict

export float_type,
    get_parameter_values,
    write_log_file,
    log_parameter_information,
    create_toml_dict,
    merge_toml_files,
    get_tagged_parameter_values,
    get_tagged_parameter_names,
    fuzzy_match

include("file_parsing.jl")

end # module
