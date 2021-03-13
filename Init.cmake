# Copyright (c) 2020 Retlek Systems Inc.
# See accompanying file Copyright.txt or https://tbd for details.

###################
# Options
# Note need to place after project to ensure the CROSSCOMPILING is used.

# Makes BUILD_TEST available as option for all builds except when cross compiling.
option(BUILD_TEST "Build all tests." ON)

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
