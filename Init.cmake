# @copyright 2020-2024 Retlek Systems Inc.
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

# See accompanying file LICENSE for details.
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

# Common Functions and Macros
file( GLOB _functions ${CMAKE_CURRENT_LIST_DIR}/functions/*.cmake )
foreach( _f ${_functions} )
  include( ${_f} )
endforeach()

###################
# Multi-config and build type settings
# set(allowedBuildTypes Debug Release RelWithDebInfo MinSizeRel Asan Tsan Msan Ubsan Coverage)
get_property(isMultiConfig GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)

set(allowedBuildTypes Debug Release RelWithDebInfo MinSizeRel)
if (NOT CMAKE_CROSSCOMPILING)
  list(APPEND allowedBuildTypes Coverage Asan Tsan Ubsan Msan) #Cfisan
endif()

# To make case insensitive:
# Create a lowercase version of allowedBuildTypes
set(allowedBuildTypesLower)
foreach(type IN LISTS allowedBuildTypes)
  string(TOLOWER "${type}" typeLower)
  list(APPEND allowedBuildTypesLower "${typeLower}")
endforeach()

if(isMultiConfig)
    message(STATUS "CMAKE_CONFIGURATION_TYPES = ${CMAKE_CONFIGURATION_TYPES}")
    set(configTypes ${CMAKE_CONFIGURATION_TYPES})
    list(APPEND configTypes ${allowedBuildTypes})
    list(REMOVE_DUPLICATES configTypes)
    set(CMAKE_CONFIGURATION_TYPES ${configTypes} CACHE STRING "" FORCE)
else()
    set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "${allowedBuildTypes}")
    if(NOT DEFINED CMAKE_BUILD_TYPE)
        set(CMAKE_BUILD_TYPE Debug CACHE STRING "" FORCE)
    elseif(NOT CMAKE_BUILD_TYPE IN_LIST allowedBuildTypes)
        # Convert the provided CMAKE_BUILD_TYPE to lowercase
        string(TOLOWER "${CMAKE_BUILD_TYPE}" CMAKE_BUILD_TYPE_LOWER)
        message(STATUS "Unknown build type: ${CMAKE_BUILD_TYPE_LOWER}, allowed: ${allowedBuildTypesLower}")

        # Find the correct case-insensitive match from the allowedBuildTypes
        list(FIND allowedBuildTypesLower ${CMAKE_BUILD_TYPE_LOWER} index)
        if(index EQUAL -1)
            message(FATAL_ERROR "Unknown build type: ${CMAKE_BUILD_TYPE}")
        else()
            list(GET allowedBuildTypes ${index} CMAKE_BUILD_TYPE_CORRECT)
            set(CMAKE_BUILD_TYPE ${CMAKE_BUILD_TYPE_CORRECT} CACHE STRING "" FORCE)
        endif()
    endif()
endif()


###################
# Add in CCache if available.
find_package(CCache)

# Ensure Build dir isn't same as local dir.
if ( ${CMAKE_SOURCE_DIR} STREQUAL ${CMAKE_BINARY_DIR} )
    message( FATAL_ERROR "Do not perform build in source directory. Make a separate directory for build:\n\tmkdir build; cd build; cmake ..\n And ensure it is empty.")
endif()


###################
# Default Package includes

# Static Analysis - if STATIC_ANALYSIS is ON.
find_package(DefaultStaticAnalysis REQUIRED)

#Testing:
find_package(DefaultTest REQUIRED)

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
# Setup for CMake Presets in CMake etc..
if(NOT EXISTS ${CMAKE_SOURCE_DIR}/CMakePresets.json)
    configure_file(${CMAKE_CURRENT_LIST_DIR}/External/CMakePresets.json
        ${CMAKE_SOURCE_DIR}/CMakePresets.json COPYONLY)
endif()

###################
# Setup for default sbom.cmake
if(NOT EXISTS ${CMAKE_SOURCE_DIR}/sbom.cmake)
    configure_file(${CMAKE_CURRENT_LIST_DIR}/External/sbom.cmake
        ${CMAKE_SOURCE_DIR}/sbom.cmake COPYONLY)
endif()


###################
# Setup for gitlab ci
# if(NOT EXISTS ${CMAKE_SOURCE_DIR}/.gitlab-ci.yml)
#     configure_file(${CMAKE_CURRENT_LIST_DIR}/External/.gitlab-ci.yml.default
#         ${CMAKE_SOURCE_DIR}/.gitlab-ci.yml COPYONLY)
# endif()
