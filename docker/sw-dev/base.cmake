cmake_minimum_required(VERSION 3.22)
cmake_policy(SET CMP0048 NEW) # project version
cmake_policy(SET CMP0057 NEW) # Support if( IN_LIST ) operator
cmake_policy(SET CMP0065 NEW) # do not add rdynamic unless explicitly stated
cmake_policy(SET CMP0076 NEW) # full paths
cmake_policy(SET CMP0077 NEW) # options do nothing when defined as variable.
#cmake_policy(SET CMP0135 NEW) # fetchcontent url timestamp cmake 3.25

project(base-hw-deps VERSION 0.2.4 LANGUAGES C CXX)

include(FetchContent)

########################################################################
# Native Environment

option(BUILD_TEST      "Builds the tests"           ON)
option(BUILD_DOC       "Builds the documentation"   OFF)
option(STATIC_ANALYSIS "Use Static Analysis tools." ON)
option(BUILD_BENCHMARK "Benchmark libs"             ON)

FetchContent_Declare( cmake
    GIT_REPOSITORY https://github.com/Retlek-Systems-Inc/rs_cmake
    GIT_TAG        v0.2.4
)

FetchContent_GetProperties(cmake)
if(NOT cmake_POPULATED)
  FetchContent_Populate(cmake)
  include(${cmake_SOURCE_DIR}/Init.cmake)
endif()

# Now add the definitions of each
include(CodeCoverage)
include(Sanitizer)

########################################################################
# Create the Version info
CreateVersion(
    PROJECT base-sw-arm-none-eabi-deps
    TARGET TBD_sw_version
    FILENAME TBD_sw_version
    VARIABLE TBDSwVersion
    OUTDIR ${CMAKE_CURRENT_LIST_DIR}/version )
add_library(TBD::sw_version ALIAS TBD_sw_version)


########################################################################
# Requirements
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)

# For testing purposes
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
