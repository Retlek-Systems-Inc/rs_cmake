# @copyright 2020 Retlek Systems Inc.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

# See accompanying file Copyright.txt or https://tbd for details.
include(CMakeDependentOption)

###################
# Options
# Note need to place after project to ensure the CROSSCOMPILING is used.

# Makes BUILD_TEST available as option for all builds except when cross compiling.
option(BUILD_TEST "Build all tests." ON)

# Make BUILD_BENCHMARK available as option for release builds.
cmake_dependent_option(BUILD_BENCHMARK "Build benchmark tests." ON "NOT BULD_TEST" OFF)
# Allow Building benchmark with release only, but allow explicit off to support debugging release builds.
option(BUILD_BENCHMARK_RELEASE_ONLY "Only Build benchmark for Release builds." ON)

#Makes STATIC_ANALYSIS available as option for all builds except when cross compiling.
option(STATIC_ANALYSIS "Performs static analysis on tests." OFF)

# Makes BUILD_DOC available as option for all builds.
option(BUILD_DOC  "Build all documentation." OFF)

option(VERILOG_TEST "Support Verilog testing." OFF)

###################
# Common Includes and paths.

# Create a common cmake path for identification of modules etc.
list( APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/Modules" )
include(CMakePrintHelpers)
cmake_print_variables(CMAKE_MODULE_PATH)

# Add in CCache if available.
find_package(CCache)

# Ensure Build dir isn't same as local dir.
if ( ${CMAKE_SOURCE_DIR} STREQUAL ${CMAKE_BINARY_DIR} )
    message( FATAL_ERROR "Do not perform build in source directory. Make a separate directory for build:\n\tmkdir build; cd build; cmake ..\n And ensure it is empty.")
endif()


#Limit it to Makefile or Ninja for now.
if ( NOT CMAKE_BUILD_TYPE AND ( (CMAKE_GENERATOR MATCHES ".*Makefile.*") OR (CMAKE_GENERATOR MATCHES ".*Ninja.*")))
    message( STATUS "Makefile generator detected and build type not defined. Defaulting to `release`.")
    set( CMAKE_BUILD_TYPE release CACHE STRING "Choose the type of build" FORCE )
endif()

# Common Functions and Macros
file( GLOB _functions ${CMAKE_CURRENT_LIST_DIR}/functions/*.cmake )
foreach( _f ${_functions} )
  include( ${_f} )
endforeach()

###################
# Default Package includes

# Static Analysis - if STATIC_ANALYSIS is ON.
find_package(DefaultStaticAnalysis REQUIRED)

#Testing:
find_package(DefaultTest REQUIRED)

find_package(DefaultBenchmark REQUIRED)

#Documentation:
set(DOC_EXCLUDE_PATTERNS  
  */build*/*) # Add your exclude patterns to documentation.
find_package(Doc REQUIRED)

#Use Current Verilog Test
find_package(VerilogTest REQUIRED 4.0)

###################
# FETCHCONTENT_BASE_DIR
# Ensure .clang-format not run on Fetched Content.
configure_file(${CMAKE_CURRENT_LIST_DIR}/External/.clang-format.none ${FETCHCONTENT_BASE_DIR}/.clang-format COPYONLY)

###################
# Setup for clang-format
if(NOT EXISTS ${CMAKE_SOURCE_DIR}/.clang-format)
    configure_file(${CMAKE_CURRENT_LIST_DIR}/External/.clang-format.default
        ${CMAKE_SOURCE_DIR}/.clang-format)
endif()

###################
# Setup for clang-format
if(NOT EXISTS ${CMAKE_SOURCE_DIR}/.clang-tidy)
    configure_file(${CMAKE_CURRENT_LIST_DIR}/External/.clang-tidy.default
        ${CMAKE_SOURCE_DIR}/.clang-tidy)
endif()

###################
# Setup for vscode.
if(NOT EXISTS ${CMAKE_SOURCE_DIR}/cmake-variants.yaml)
    configure_file(${CMAKE_CURRENT_LIST_DIR}/External/vscode.cmake-variants.yaml
        ${CMAKE_SOURCE_DIR}/cmake-variants.yaml)
endif()

###################
# Setup for gitlab ci
if(NOT EXISTS ${CMAKE_SOURCE_DIR}/.gitlab-ci.yml)
    configure_file(${CMAKE_CURRENT_LIST_DIR}/External/.gitlab-ci.yml.default
        ${CMAKE_SOURCE_DIR}/.gitlab-ci.yml)
endif()
