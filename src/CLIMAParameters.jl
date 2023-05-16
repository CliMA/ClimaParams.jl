module CLIMAParameters

using TOML
using DocStringExtensions

export AbstractTOMLDict
export ParamDict, AliasParamDict

export float_type,
    get_parameter_values!,
    get_parameter_values,
    write_log_file,
    log_parameter_information,
    create_toml_dict,
    merge_toml_files

include("file_parsing.jl")

end # module
