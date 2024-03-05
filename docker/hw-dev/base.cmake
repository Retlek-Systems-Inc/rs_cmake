cmake_minimum_required(VERSION 3.22)
cmake_policy(SET CMP0048 NEW) # project version
cmake_policy(SET CMP0057 NEW) # Support if( IN_LIST ) operator
cmake_policy(SET CMP0065 NEW) # do not add rdynamic unless explicitly stated
cmake_policy(SET CMP0076 NEW) # full paths
cmake_policy(SET CMP0077 NEW) # options do nothing when defined as variable.
#cmake_policy(SET CMP0135 NEW) # fetchcontent url timestamp cmake 3.25

project(base-hw-deps VERSION 0.3.2 LANGUAGES C CXX)

include(FetchContent)

########################################################################
# Native Environment

option(BUILD_TEST      "Builds the tests"           ON)
option(BUILD_DOC       "Builds the documentation"   OFF)
option(STATIC_ANALYSIS "Use Static Analysis tools." ON)
option(BUILD_BENCHMARK "Benchmark libs"             ON)
option(VERILOG_TEST    "Support Verilog testing."   ON)

FetchContent_Declare( rs_cmake
    GIT_REPOSITORY https://github.com/Retlek-Systems-Inc/rs_cmake
    GIT_TAG        v0.3.2
)

FetchContent_GetProperties( rs_cmake )
if(NOT rs_cmake_POPULATED)
  FetchContent_Populate( rs_cmake )
  include(${rs_cmake_SOURCE_DIR}/Init.cmake)
endif()

# Now add the definitions of each
include(CodeCoverage)
include(Sanitizer)

########################################################################
# Requirements
set(CMAKE_C_STANDARD 90)
set(CMAKE_C_STANDARD_REQUIRED ON)

# For testing purposes
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
