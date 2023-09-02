include(cmake/SystemLink.cmake)
include(cmake/LibFuzzer.cmake)
include(CMakeDependentOption)
include(CheckCXXCompilerFlag)


macro(session_time_cap_supports_sanitizers)
  if((CMAKE_CXX_COMPILER_ID MATCHES ".*Clang.*" OR CMAKE_CXX_COMPILER_ID MATCHES ".*GNU.*") AND NOT WIN32)
    set(SUPPORTS_UBSAN ON)
  else()
    set(SUPPORTS_UBSAN OFF)
  endif()

  if((CMAKE_CXX_COMPILER_ID MATCHES ".*Clang.*" OR CMAKE_CXX_COMPILER_ID MATCHES ".*GNU.*") AND WIN32)
    set(SUPPORTS_ASAN OFF)
  else()
    set(SUPPORTS_ASAN ON)
  endif()
endmacro()

macro(session_time_cap_setup_options)
  option(session_time_cap_ENABLE_HARDENING "Enable hardening" ON)
  option(session_time_cap_ENABLE_COVERAGE "Enable coverage reporting" OFF)
  cmake_dependent_option(
    session_time_cap_ENABLE_GLOBAL_HARDENING
    "Attempt to push hardening options to built dependencies"
    ON
    session_time_cap_ENABLE_HARDENING
    OFF)

  session_time_cap_supports_sanitizers()

  if(NOT PROJECT_IS_TOP_LEVEL OR session_time_cap_PACKAGING_MAINTAINER_MODE)
    option(session_time_cap_ENABLE_IPO "Enable IPO/LTO" OFF)
    option(session_time_cap_WARNINGS_AS_ERRORS "Treat Warnings As Errors" OFF)
    option(session_time_cap_ENABLE_USER_LINKER "Enable user-selected linker" OFF)
    option(session_time_cap_ENABLE_SANITIZER_ADDRESS "Enable address sanitizer" OFF)
    option(session_time_cap_ENABLE_SANITIZER_LEAK "Enable leak sanitizer" OFF)
    option(session_time_cap_ENABLE_SANITIZER_UNDEFINED "Enable undefined sanitizer" OFF)
    option(session_time_cap_ENABLE_SANITIZER_THREAD "Enable thread sanitizer" OFF)
    option(session_time_cap_ENABLE_SANITIZER_MEMORY "Enable memory sanitizer" OFF)
    option(session_time_cap_ENABLE_UNITY_BUILD "Enable unity builds" OFF)
    option(session_time_cap_ENABLE_CLANG_TIDY "Enable clang-tidy" OFF)
    option(session_time_cap_ENABLE_CPPCHECK "Enable cpp-check analysis" OFF)
    option(session_time_cap_ENABLE_PCH "Enable precompiled headers" OFF)
    option(session_time_cap_ENABLE_CACHE "Enable ccache" OFF)
  else()
    option(session_time_cap_ENABLE_IPO "Enable IPO/LTO" ON)
    option(session_time_cap_WARNINGS_AS_ERRORS "Treat Warnings As Errors" ON)
    option(session_time_cap_ENABLE_USER_LINKER "Enable user-selected linker" OFF)
    option(session_time_cap_ENABLE_SANITIZER_ADDRESS "Enable address sanitizer" ${SUPPORTS_ASAN})
    option(session_time_cap_ENABLE_SANITIZER_LEAK "Enable leak sanitizer" OFF)
    option(session_time_cap_ENABLE_SANITIZER_UNDEFINED "Enable undefined sanitizer" ${SUPPORTS_UBSAN})
    option(session_time_cap_ENABLE_SANITIZER_THREAD "Enable thread sanitizer" OFF)
    option(session_time_cap_ENABLE_SANITIZER_MEMORY "Enable memory sanitizer" OFF)
    option(session_time_cap_ENABLE_UNITY_BUILD "Enable unity builds" OFF)
    option(session_time_cap_ENABLE_CLANG_TIDY "Enable clang-tidy" ON)
    option(session_time_cap_ENABLE_CPPCHECK "Enable cpp-check analysis" ON)
    option(session_time_cap_ENABLE_PCH "Enable precompiled headers" OFF)
    option(session_time_cap_ENABLE_CACHE "Enable ccache" ON)
  endif()

  if(NOT PROJECT_IS_TOP_LEVEL)
    mark_as_advanced(
      session_time_cap_ENABLE_IPO
      session_time_cap_WARNINGS_AS_ERRORS
      session_time_cap_ENABLE_USER_LINKER
      session_time_cap_ENABLE_SANITIZER_ADDRESS
      session_time_cap_ENABLE_SANITIZER_LEAK
      session_time_cap_ENABLE_SANITIZER_UNDEFINED
      session_time_cap_ENABLE_SANITIZER_THREAD
      session_time_cap_ENABLE_SANITIZER_MEMORY
      session_time_cap_ENABLE_UNITY_BUILD
      session_time_cap_ENABLE_CLANG_TIDY
      session_time_cap_ENABLE_CPPCHECK
      session_time_cap_ENABLE_COVERAGE
      session_time_cap_ENABLE_PCH
      session_time_cap_ENABLE_CACHE)
  endif()

  session_time_cap_check_libfuzzer_support(LIBFUZZER_SUPPORTED)
  if(LIBFUZZER_SUPPORTED AND (session_time_cap_ENABLE_SANITIZER_ADDRESS OR session_time_cap_ENABLE_SANITIZER_THREAD OR session_time_cap_ENABLE_SANITIZER_UNDEFINED))
    set(DEFAULT_FUZZER ON)
  else()
    set(DEFAULT_FUZZER OFF)
  endif()

  option(session_time_cap_BUILD_FUZZ_TESTS "Enable fuzz testing executable" ${DEFAULT_FUZZER})

endmacro()

macro(session_time_cap_global_options)
  if(session_time_cap_ENABLE_IPO)
    include(cmake/InterproceduralOptimization.cmake)
    session_time_cap_enable_ipo()
  endif()

  session_time_cap_supports_sanitizers()

  if(session_time_cap_ENABLE_HARDENING AND session_time_cap_ENABLE_GLOBAL_HARDENING)
    include(cmake/Hardening.cmake)
    if(NOT SUPPORTS_UBSAN 
       OR session_time_cap_ENABLE_SANITIZER_UNDEFINED
       OR session_time_cap_ENABLE_SANITIZER_ADDRESS
       OR session_time_cap_ENABLE_SANITIZER_THREAD
       OR session_time_cap_ENABLE_SANITIZER_LEAK)
      set(ENABLE_UBSAN_MINIMAL_RUNTIME FALSE)
    else()
      set(ENABLE_UBSAN_MINIMAL_RUNTIME TRUE)
    endif()
    message("${session_time_cap_ENABLE_HARDENING} ${ENABLE_UBSAN_MINIMAL_RUNTIME} ${session_time_cap_ENABLE_SANITIZER_UNDEFINED}")
    session_time_cap_enable_hardening(session_time_cap_options ON ${ENABLE_UBSAN_MINIMAL_RUNTIME})
  endif()
endmacro()

macro(session_time_cap_local_options)
  if(PROJECT_IS_TOP_LEVEL)
    include(cmake/StandardProjectSettings.cmake)
  endif()

  add_library(session_time_cap_warnings INTERFACE)
  add_library(session_time_cap_options INTERFACE)

  include(cmake/CompilerWarnings.cmake)
  session_time_cap_set_project_warnings(
    session_time_cap_warnings
    ${session_time_cap_WARNINGS_AS_ERRORS}
    ""
    ""
    ""
    "")

  if(session_time_cap_ENABLE_USER_LINKER)
    include(cmake/Linker.cmake)
    configure_linker(session_time_cap_options)
  endif()

  include(cmake/Sanitizers.cmake)
  session_time_cap_enable_sanitizers(
    session_time_cap_options
    ${session_time_cap_ENABLE_SANITIZER_ADDRESS}
    ${session_time_cap_ENABLE_SANITIZER_LEAK}
    ${session_time_cap_ENABLE_SANITIZER_UNDEFINED}
    ${session_time_cap_ENABLE_SANITIZER_THREAD}
    ${session_time_cap_ENABLE_SANITIZER_MEMORY})

  set_target_properties(session_time_cap_options PROPERTIES UNITY_BUILD ${session_time_cap_ENABLE_UNITY_BUILD})

  if(session_time_cap_ENABLE_PCH)
    target_precompile_headers(
      session_time_cap_options
      INTERFACE
      <vector>
      <string>
      <utility>)
  endif()

  if(session_time_cap_ENABLE_CACHE)
    include(cmake/Cache.cmake)
    session_time_cap_enable_cache()
  endif()

  include(cmake/StaticAnalyzers.cmake)
  if(session_time_cap_ENABLE_CLANG_TIDY)
    session_time_cap_enable_clang_tidy(session_time_cap_options ${session_time_cap_WARNINGS_AS_ERRORS})
  endif()

  if(session_time_cap_ENABLE_CPPCHECK)
    session_time_cap_enable_cppcheck(${session_time_cap_WARNINGS_AS_ERRORS} "" # override cppcheck options
    )
  endif()

  if(session_time_cap_ENABLE_COVERAGE)
    include(cmake/Tests.cmake)
    session_time_cap_enable_coverage(session_time_cap_options)
  endif()

  if(session_time_cap_WARNINGS_AS_ERRORS)
    check_cxx_compiler_flag("-Wl,--fatal-warnings" LINKER_FATAL_WARNINGS)
    if(LINKER_FATAL_WARNINGS)
      # This is not working consistently, so disabling for now
      # target_link_options(session_time_cap_options INTERFACE -Wl,--fatal-warnings)
    endif()
  endif()

  if(session_time_cap_ENABLE_HARDENING AND NOT session_time_cap_ENABLE_GLOBAL_HARDENING)
    include(cmake/Hardening.cmake)
    if(NOT SUPPORTS_UBSAN 
       OR session_time_cap_ENABLE_SANITIZER_UNDEFINED
       OR session_time_cap_ENABLE_SANITIZER_ADDRESS
       OR session_time_cap_ENABLE_SANITIZER_THREAD
       OR session_time_cap_ENABLE_SANITIZER_LEAK)
      set(ENABLE_UBSAN_MINIMAL_RUNTIME FALSE)
    else()
      set(ENABLE_UBSAN_MINIMAL_RUNTIME TRUE)
    endif()
    session_time_cap_enable_hardening(session_time_cap_options OFF ${ENABLE_UBSAN_MINIMAL_RUNTIME})
  endif()

endmacro()
