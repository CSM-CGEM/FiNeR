finer_srcs = files(
    'finer_backend.f90',
    'finer_file_ini_t.F90',
    'finer_option_t.F90',
    'finer_section_t.f90',
    'finer.f90',
)

finer_lib = static_library(
    'finer',
    finer_srcs,
    dependencies: [penf_dep, stringifor_dep]
)

finer_dep = declare_dependency(
    link_with: finer_lib,
    dependencies: [penf_dep, stringifor_dep]
)