cmake_policy(SET CMP0048 NEW) # project version
cmake_policy(SET CMP0065 NEW) # do not add rdynamic unless explicitly stated
cmake_policy(SET CMP0076 NEW) # full paths
cmake_policy(SET CMP0077 NEW) # options do nothing when defined as variable.
#cmake_policy(SET CMP0135 NEW) # fetchcontent url timestamp cmake 3.25

project(base-sw-arm-none-eabi-deps VERSION 0.2.2 LANGUAGES C)

include(FetchContent)

########################################################################
# Native Environment
include(CMakeDependentOption)
cmake_dependent_option(BUILD_TEST      "Builds the tests"           ON  "NOT CMAKE_CROSSCOMPILING" OFF)
cmake_dependent_option(BUILD_DOC       "Builds the documentation"   OFF "NOT CMAKE_CROSSCOMPILING" OFF)
cmake_dependent_option(STATIC_ANALYSIS "Use Static Analysis tools." ON  "NOT CMAKE_CROSSCOMPILING" OFF)
cmake_dependent_option(BUILD_BENCHMARK "No Benchmark tests"         OFF "NOT CMAKE_CROSSCOMPILING" OFF)

FetchContent_Declare( cmake
    GIT_REPOSITORY https://rscmake_clone_access:h1SwGbFex6ScmtSWzzGJ@gitlab.com/retleksystems/env/cmake.git
    GIT_TAG        v0.2.3
)

FetchContent_GetProperties(cmake)
if(NOT cmake_POPULATED)
  FetchContent_Populate(cmake)
  include(${cmake_SOURCE_DIR}/Init.cmake)
endif()

# Now add the definitions of each
if(NOT CMAKE_CROSSCOMPILING)
  include(CodeCoverage)
  include(Sanitizer)
endif()

########################################################################
# Create the Version info
CreateVersion(
    PROJECT base-sw-arm-none-eabi-deps
    TARGET TBD_fw_version
    FILENAME TBD_fw_version
    VARIABLE TBDFwVersion
    OUTDIR ${CMAKE_CURRENT_LIST_DIR}/version )
add_library(TBD::fw_version ALIAS TBD_fw_version)


########################################################################
# Requirements
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)

# For testing purposes
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)


# -----------------------------------------------------------------------------
add_compile_options(
  $<$<COMPILE_LANG_AND_ID:C,GNU>:-fdiagnostics-color=always>
  $<$<COMPILE_LANG_AND_ID:C,Clang>:-fcolor-diagnostics>

  $<$<COMPILE_LANG_AND_ID:C,Clang,GNU>:-Wall>
  $<$<COMPILE_LANG_AND_ID:C,Clang,GNU>:-Wextra>
  $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wpedantic> # Note not used in GNU to allow C99 designated initializers.
  $<$<COMPILE_LANG_AND_ID:C,Clang,GNU>:-Werror>
  $<$<COMPILE_LANG_AND_ID:C,Clang>:-Weverything>

  # Documentation types
  $<$<COMPILE_LANG_AND_ID:C,Clang>:-fcomment-block-commands=retval> # Doesn't recongize doxygen retval
  $<$<COMPILE_LANG_AND_ID:C,Clang>:-fcomment-block-commands=copydetails> # Doesn't recongize doxygen copydetails
  $<$<COMPILE_LANG_AND_ID:C,Clang>:-fcomment-block-commands=startuml> # Doesn't recongize doxygen + plantuml staruml
  $<$<COMPILE_LANG_AND_ID:C,Clang>:-fcomment-block-commands=enduml> # Doesn't recongize doxygen + plantuml staruml

  # For Unit Tests.
  $<$<COMPILE_LANG_AND_ID:CXX,GNU>:-fdiagnostics-color=always>
  $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-fcolor-diagnostics>

  $<$<COMPILE_LANG_AND_ID:CXX,Clang,GNU>:-Wall>
  $<$<COMPILE_LANG_AND_ID:CXX,Clang,GNU>:-Wextra>
  $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-Weffc++> # Note GNU too many errors in verilator code.
  $<$<COMPILE_LANG_AND_ID:CXX,Clang,GNU>:-Werror>
  $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-Wpedantic> # Note not used in GNU to allow C99 designated initializers.
  $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-Weverything>

  $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-Wno-c++98-compat>
  $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-Wno-c++98-compat-pedantic>

  # Allow clang and gnu pramgmas.
  $<$<COMPILE_LANG_AND_ID:CXX,GNU>:-Wno-unknown-pragmas>

  # Documentation types
  $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-fcomment-block-commands=retval> # Doesn't recongize doxygen retval
  $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-fcomment-block-commands=copydetails> # Doesn't recongize doxygen copydetails
  $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-fcomment-block-commands=startuml> # Doesn't recongize doxygen startuml
  $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-fcomment-block-commands=enduml> # Doesn't recongize doxygen startuml
)
