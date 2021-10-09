tests = [
  'graph_tests',
  'select_tests',
  'compressed_seq_tests',
  'compressed_rank_tests',
] + (
  # XXX this test relies on <unistd.h> and won't compile on Windows
  host_machine.system() != 'windows' ? ['cmph_benchmark_test'] : []
)

foreach t: tests
  test(t, executable(t, t + '.c',
      dependencies: cmph_dep,
      include_directories: include_directories('..'),
  ))
endforeach

programs = ['packed_mphf_tests', 'mphf_tests']

foreach p: programs
  executable(p, p + '.c',
    dependencies: cmph_dep,
    # XXX those programs use bogus include path '../wingetopt.h' so we trick them
    # to use the correct header by adding the '/workaround' subdir so the path
    # resolves to the actual file '../src/wingetopt.h'
    include_directories: include_directories('..', '../src/workaround'),
    build_by_default: false,
  )
endforeach
