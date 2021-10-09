add_languages('cpp', required: true)
cpp = meson.get_compiler('cpp')

if not import('fs').is_dir('murmur-fix')
  message('Updating MurmurHash3.cpp...')
  # HACK sanity_check.py allows only few file names in packagefiles dir so we exploit
  # the allowed generator.sh name to update MurmurHash3.cpp with the updated version
  # which fixes the following set of issues when building with eg. GCC 9.3:
  #   cxxmph/MurmurHash3.cpp:81:23: warning: always_inline function might not be inlinable [-Wattributes]
  #   81 | FORCE_INLINE uint64_t fmix ( uint64_t k )
  #   cxxmph/MurmurHash3.cpp:68:23: error: inlining failed in call to always_inline ‘uint32_t fmix(uint32_t)’: function body can be overwritten at link time
  #   68 | FORCE_INLINE uint32_t fmix ( uint32_t h )
  # The only difference between the updated sources and the original ones is the
  # addition of 'inline' attribute to fmix() and getblock() which fixes the error,
  # because this changes the linkage of those symbols so that they are no longer external
  run_command('generator.sh', check: true)
endif

inc = include_directories('..')
cxxmph_lib = library('cxxmph', [
    'murmur-fix/MurmurHash3.cpp',
    'trigraph.cc',
    'mph_bits.cc',
    'mph_index.cc',
    'string_util.cc',
  ],
  include_directories: inc,
  version: meson.project_version(),
  # NOTE we need to use override_options here because cpp_std doesn't have any effect
  # in the project's default_options if there's no 'cpp' in the initial languages list
  override_options: 'cpp_std=c++11',
  install: not meson.is_subproject() or get_option('default_library') == 'shared',
  cpp_args: cpp.get_supported_arguments([
    # XXX cxxmph/mph_bits.h:58:17: warning: unused function 'nextpoweroftwo' [-Wunused-function]
    '-Wno-unused-function',
    # XXX cxxmph/mph_bits.h:58:17: warning: 'static' function 'nextpoweroftwo' declared in header file should be declared 'static inline' [-Wunneeded-internal-declaration]
    '-Wno-unneeded-internal-declaration',
    # XXX This issue looks like it might be dangerous but this piece of code is actually used
    # only in debugging statements where lifetime of the dangling reference never exceeds
    # the lifetime of the referenced object.
    # cxxmph/string_util.h:118:27: warning: binding reference member 'line_' to stack allocated parameter 'line' [-Wdangling-field]
    '-Wno-dangling-field',
  ]),
)
cxxmph_internal_dep = declare_dependency(link_with: cxxmph_lib, include_directories: inc)
if not meson.is_subproject()
  install_headers([
      'mph_bits.h',
      'mph_map.h',
      'mph_index.h',
      'MurmurHash3.h',
      'trigraph.h',
      'seeded_hash.h',
      'stringpiece.h',
      'hollow_iterator.h',
      'string_util.h',
    ],
    subdir: 'cxxmph',
  )
endif

executable('cxxmph', 'cxxmph.cc',
  dependencies: cxxmph_internal_dep,
  install: not meson.is_subproject(),
  build_by_default: not meson.is_subproject(),
  override_options: 'cpp_std=c++11',
)

cxxmph_bm_lib = library('cxxmph_bm', 'benchmark.cc', 'bm_common.cc',
  dependencies: cxxmph_internal_dep,
  include_directories: inc,
  override_options: 'cpp_std=c++11',
  build_by_default: not meson.is_subproject(),
  cpp_args: cpp.get_supported_arguments([
    # XXX cxxmph/benchmark.cc:110:10: warning: 'auto_ptr<cxxmph::Benchmark>' is deprecated [-Wdeprecated-declarations]
    '-Wno-deprecated-declarations',
  ]),
)
executable('bm_map', 'bm_map.cc',
  link_with: cxxmph_bm_lib,
  dependencies: cxxmph_internal_dep,
  override_options: 'cpp_std=c++11',
  build_by_default: not meson.is_subproject(),
)

if get_option('build_tests')
  tests = [
    'seeded_hash_test',
    'mph_bits_test',
    'hollow_iterator_test',
    'mph_index_test',
    'trigraph_test',
  ]
  foreach t: tests
    test(t, executable(t, t + '.cc',
      dependencies: cxxmph_internal_dep,
      override_options: 'cpp_std=c++11',
    ))
  endforeach

  # NOTE check-based tests rely on obsolete check API and do not compile neither
  # with meson wrap-based dependency nor with any fairly recent check package
  # cxxmph_test_lib = library('cxxmph_test', 'test.cc',
  #   dependencies: [cxxmph_internal_dep, check_dep],
  #   override_options: 'cpp_std=c++11',
  # )
  # check_tests = [
  #   'test_test',
  #   'map_tester_test',
  #   'mph_map_test',
  #   'dense_hash_map_test',
  #   'string_util_test',
  # ]
  # foreach t: check_tests
  #   test(t, executable(t, t + '.cc',
  #     link_with: cxxmph_test_lib,
  #     dependencies: cxxmph_internal_dep,
  #     override_options: 'cpp_std=c++11',
  #   ))
  # endforeach
endif
