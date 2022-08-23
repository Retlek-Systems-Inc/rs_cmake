# @copyright 2017 Retlek Systems Inc.
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

# Platforms
#   Linux-Verilator-Verilog.cmake
#   Linux-Icarus-Verilog.cmake      - TODO
#   Linux-Cadence-Verilog.cmake     - TODO
#   Linux-Synopsys-Verilog.cmake    - TODO
#   Linux-Mentor-Verilog.cmake      - TODO
# 

# determine the compiler to use for Verilog modules
# NOTE, a generator may set CMAKE_Verilog_COMPILER before
# loading this file to force a compiler.
# use environment variable VERILOG_COMPILER first if defined by user, next use
# the cmake variable CMAKE_GENERATOR_VERILOG_COMPILER which can be defined by a generator
# as a default compiler

# Sets the following variables:
#   CMAKE_Verilog_COMPILER
#
# If not already set before, it also sets
#   _CMAKE_TOOLCHAIN_PREFIX
# This is based on: https://stackoverflow.com/questions/38293535/generic-rule-from-makefile-to-cmake

# Find the compiler
find_program(
    CMAKE_Verilog_COMPILER 
        NAMES "verilator" 
        HINTS "${CMAKE_SOURCE_DIR}"
        DOC "Verilog compiler" 
)
mark_as_advanced(CMAKE_FOO_COMPILER)

set(CMAKE_Verilog_COMPILER_ID     "Verilator")

set(CMAKE_Veriog_SOURCE_FILE_EXTENSIONS v;sv)
set(CMAKE_Verilog_OUTPUT_EXTENSION .o)
set(CMAKE_Verilog_COMPILER_ENV_VAR "VERILOG_COMPILER")

# Configure variables set in this file for fast reload later on
configure_file(${CMAKE_CURRENT_LIST_DIR}/CMakeVerilogCompiler.cmake.in
               ${CMAKE_PLATFORM_INFO_DIR}/CMakeVerilogCompiler.cmake)
               
# TODO: Debug this later.

#include(${CMAKE_ROOT}/Modules/CMakeDetermineCompiler.cmake)
#
#set(lang "Verilog")
#
# Only support make directives.
#if( NOT ( ("${CMAKE_GENERATOR}" MATCHES "Make") OR
#          ("${CMAKE_GENERATOR}" MATCHES "Ninja") )
#  message(FATAL_ERROR "${lang} language not currently supported by \"${CMAKE_GENERATOR}\" generator")
#endif()
#
#
#mark_as_advanced(CMAKE_${lang}_COMPILER)

# Load system-specific compiler preferences for this language.
#include(Platform/${CMAKE_SYSTEM_NAME}-Determine-${lang} OPTIONAL)
#include(Platform/${CMAKE_SYSTEM_NAME}-${lang} OPTIONAL)
#
#if(NOT CMAKE_${lang}_COMPILER_NAMES)
#  set(CMAKE_${lang}_COMPILER_NAMES "Verilator")
#endif()
#
#if(NOT CMAKE_${lang}_COMPILER)
#  set(CMAKE_VERILOG_COMPILER_INIT NOTFOUND)
#
  # prefer the environment variable VERILOG_COMPILER
#  if(NOT $ENV{VERILOG_COMPILER} STREQUAL "")
#    get_filename_component(CMAKE_${lang}_COMPILER_INIT $ENV{VERILOG_COMPILER} PROGRAM PROGRAM_ARGS CMAKE_${lang}_FLAGS_ENV_INIT)
#    if(CMAKE_${lang}_FLAGS_ENV_INIT)
#      set(CMAKE_${lang}_COMPILER_ARG1 "${CMAKE_${lang}_FLAGS_ENV_INIT}" CACHE STRING "First argument to ${lang} compiler")
#    endif()
#    if(NOT EXISTS ${CMAKE_${lang}_COMPILER_INIT})
#      message(FATAL_ERROR "Could not find compiler set in environment variable VERILOG_COMPILER:\n$ENV{VERILOG_COMPILER}.\n${CMAKE_${lang}_COMPILER_INIT}")
#    endif()
#  endif()
#
  # next try prefer the compiler specified by the generator
#  if(CMAKE_GENERATOR_${lang})
#    if(NOT CMAKE_${lang}_COMPILER_INIT)
#      set(CMAKE_${lang}_COMPILER_INIT ${CMAKE_GENERATOR_${lang}})
#    endif()
#  endif()
#
  # finally list compilers to try
#  if(NOT CMAKE_${lang}_COMPILER_INIT)
    # Known compilers:
    #  Open Source
    #    verilator : https://www.veripool.org/projects/verilator
    #    iverilog  : http://iverilog.icarus.com/
    #  EDA paid tools
    #    irun, ncverilog    : https://www.cadence.com/
    #    vcs                : https://www.synopsys.com/
    #    modelsim           : https://www.mentor.com/products/fv/
#    
#    set(CMAKE_${lang}_COMPILER_LIST 
#        verilator 
#        iverilog irun ncverilog vcs )
#    
#    set(_${lang}_COMPILER_NAMES_Veripool   verilator)
#    set(_${lang}_COMPILER_NAMES_Icarus     iverilog)
#    set(_${lang}_COMPILER_NAMES_Cadence    irun ncverilog)
#    set(_${lang}_COMPILER_NAMES_Synopsys   vcs)
#    set(_${lang}_COMPILER_NAMES_Mentor     modelsim)
#  endif()
#
#
#  _cmake_find_compiler(${lang})
#else()
#  _cmake_find_compiler_path(${lang})
#endif()
#
#
#mark_as_advanced(CMAKE_${lang}_COMPILER)
#
#
# Build a small source file to identify the compiler.
#if(NOT CMAKE_${lang}_COMPILER_ID_RUN)
#  set(CMAKE_${lang}_COMPILER_ID_RUN 1)
#
  # Try to identify the compiler.
#  set(CMAKE_${lang}_COMPILER_ID)
#  set(CMAKE_${lang}_PLATFORM_ID)
#  file(READ ${CMAKE_ROOT}/Modules/CMakePlatformId.h.in
#    CMAKE_${lang}_COMPILER_ID_PLATFORM_CONTENT)
#
  # The IAR compiler produces weird output.
  # See https://gitlab.kitware.com/cmake/cmake/issues/10176#note_153591
#  list(APPEND CMAKE_${lang}_COMPILER_ID_VENDORS IAR)
#  set(CMAKE_${lang}_COMPILER_ID_VENDOR_FLAGS_IAR )
#  set(CMAKE_${lang}_COMPILER_ID_VENDOR_REGEX_IAR "IAR .+ Compiler")
#
  # Match the link line from xcodebuild output of the form
  #  Ld ...
  #      ...
  #      /path/to/cc ...CompilerIdCXX/...
  # to extract the compiler front-end for the language.
#  set(CMAKE_${lang}_COMPILER_ID_TOOL_MATCH_REGEX "\nLd[^\n]*(\n[ \t]+[^\n]*)*\n[ \t]+([^ \t\r\n]+)[^\r\n]*-o[^\r\n]*CompilerIdCXX/(\\./)?(CompilerIdCXX.xctest/)?CompilerIdCXX[ \t\n\\\"]")
#  set(CMAKE_${lang}_COMPILER_ID_TOOL_MATCH_INDEX 2)
#
#  include(${CMAKE_ROOT}/Modules/CMakeDetermineCompilerId.cmake)
#  CMAKE_DETERMINE_COMPILER_ID(${lang} ${lang}FLAGS CMake${lang}CompilerId.cpp)
#  CMAKE_DIAGNOSE_UNSUPPORTED_CLANG(${lang} ${lang})
#
  # Set old compiler and platform id variables.
#  if(CMAKE_${lang}_COMPILER_ID STREQUAL "GNU")
#    set(CMAKE_COMPILER_IS_GNU${lang} 1)
#  endif()
#  if(CMAKE_${lang}_PLATFORM_ID MATCHES "MinGW")
#    set(CMAKE_COMPILER_IS_MINGW 1)
#  elseif(CMAKE_${lang}_PLATFORM_ID MATCHES "Cygwin")
#    set(CMAKE_COMPILER_IS_CYGWIN 1)
#  endif()
#endif()
#
#
#if (NOT _CMAKE_TOOLCHAIN_LOCATION)
#  get_filename_component(_CMAKE_TOOLCHAIN_LOCATION "${CMAKE_${lang}_COMPILER}" PATH)
#endif ()
#
#
#include(CMakeFindBinUtils)
#set(_CMAKE_PROCESSING_LANGUAGE "Verilog")
#include(Compiler/${CMAKE_${lang}_COMPILER_ID}-FindBinUtils OPTIONAL)
#unset(_CMAKE_PROCESSING_LANGUAGE)
#
#if(CMAKE_${lang}_COMPILER_ARCHITECTURE_ID)
#  set(_SET_CMAKE_${lang}_COMPILER_ARCHITECTURE_ID
#    "set(CMAKE_${lang}_COMPILER_ARCHITECTURE_ID ${CMAKE_${lang}_COMPILER_ARCHITECTURE_ID})")
#else()
#  set(_SET_CMAKE_${lang}_COMPILER_ARCHITECTURE_ID "")
#endif()
#
# configure all variables set in this file
#configure_file(${CMAKE_ROOT}/Modules/CMake${lang}Compiler.cmake.in
#  ${CMAKE_PLATFORM_INFO_DIR}/CMake${lang}Compiler.cmake
#  @ONLY
#  )
#
#unset(lang)

#set(CMAKE_VERILOG_COMPILER_ENV_VAR "VERILOG_COMPILER")