project(
    'FiNeR',
    'fortran',
    version: '2.0.3',
    default_options:[
        'fortran_std=f2008',
    ]
)

fc = meson.get_compiler('fortran')

r16_code = '''
program r16p_support;
     integer, parameter :: r16p = selected_real_kind(33, 4931);
     if(r16p < 0) stop 1;
end program r16p_support
'''
r16_result = fc.run(r16_code, name: 'r16 support')
if r16_result.returncode() == 0
    add_project_arguments('-D_R16P_SUPPORTED', language: 'fortran')
endif

ascii_code = '''
program ascii_support;
     integer, parameter :: ascii = selected_char_kind('ascii');
     if(ascii < 0) stop 1;
end program ascii_support
'''
ascii_supported = fc.run(ascii_code, name: 'ascii support')

if ascii_supported.returncode() == 0
    add_project_arguments('-D_ASCII_SUPPORTED', language : 'fortran')
endif

ascii_neq_code = '''
program ascii_neq_default;
     integer, parameter :: ascii = selected_char_kind('ascii');
     integer, parameter :: default = selected_char_kind('default');
     if(ascii == default) stop 1;
end program ascii_neq_default
'''
ascii_neq_default = fc.run(ascii_neq_code, name: 'ascii neq default')
if ascii_neq_default.returncode() == 0
    add_project_arguments('-D_ASCII_NEQ_DEFAULT', language : 'fortran')
endif

ucs4_code = '''
program ucs4_support;
     integer, parameter :: ucs4 = selected_char_kind('iso_10646');
     if(ucs4 < 0) stop 1;
end program ucs4_support
'''
ucs4_supported = fc.run(ucs4_code, name: 'ucs4 support')
if ucs4_supported.returncode() == 0

    add_project_arguments('-D_UCS4_SUPPORTED', language : 'fortran')
endif


fc_id = fc.get_id()

if 'intel' in fc_id
    add_project_arguments('-fpp', language: 'fortran')
    add_project_arguments('/Qdiag-disable:10448', language: 'fortran')
elif 'gcc' in fc_id
    add_project_arguments('-cpp', language: 'fortran')
    add_project_arguments('-frealloc-lhs', language : 'fortran')
endif

penf_dep = dependency('penf')
stringifor_dep = dependency('stringifor')

subdir('src/lib')