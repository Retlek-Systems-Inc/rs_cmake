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
#   Linux-Slang-Verilog.cmake
#   Linux-Verilator-Verilog.cmake
#   Linux-Icarus-Verilog.cmake      - TODO
#   Linux-Cadence-Verilog.cmake     - TODO
#   Linux-Synopsys-Verilog.cmake    - TODO
#   Linux-Mentor-Verilog.cmake      - TODO
# 

# determine the compiler to use for Verilog modules
# NOTE, a generator may set CMAKE_Verilog_COMPILER before
# loading this file to force a compiler.
# use environment variable VC first if defined by user, next use
# the cmake variable CMAKE_GENERATOR_VC which can be defined by a generator
# as a default compiler

# Sets the following variables:
#   CMAKE_Verilog_COMPILER
#

include(${CMAKE_ROOT}/Modules/CMakeDetermineCompiler.cmake)
#include(Platform/${CMAKE_SYSTEM_NAME}-Determine-Verilog OPTIONAL)
#include(Platform/${CMAKE_SYSTEM_NAME}-Verilog OPTIONAL)

# Only support make and ninja generators
if( NOT ( ("${CMAKE_GENERATOR}" MATCHES "Make") OR
          ("${CMAKE_GENERATOR}" MATCHES "Ninja") ) )
  message(FATAL_ERROR "Verilog language not currently supported by \"${CMAKE_GENERATOR}\" generator")
endif()


if(NOT CMAKE_Verilog_COMPILER)
  # prefer the environment variable VC
  if(NOT $ENV{VC} STREQUAL "")
    get_filename_component(CMAKE_Verilog_COMPILER_INIT $ENV{VC} PROGRAM PROGRAM_ARGS CMAKE_Verilog_FLAGS_ENV_INIT)
    if(CMAKE_Verilog_FLAGS_ENV_INIT)
      set(CMAKE_Verilog_COMPILER_ARG1 "${CMAKE_Verilog_FLAGS_ENV_INIT}" CACHE STRING "Arguments to Verilog compiler")
    endif()
    if(EXISTS ${CMAKE_Verilog_COMPILER_INIT})
    else()
      message(FATAL_ERROR "Could not find compiler set in environment variable VC:\n$ENV{VC}.")
    endif()
  endif()

  # next try prefer the compiler specified by the generator
  if(CMAKE_GENERATOR_Verilog)
    if(NOT CMAKE_Verilog_COMPILER_INIT)
      set(CMAKE_Verilog_COMPILER_INIT ${CMAKE_GENERATOR_Verilog})
    endif()
  endif()


  # finally list compilers to try
  if(CMAKE_Verilog_COMPILER_INIT)
    set(_CMAKE_Verilog_COMPILER_LIST     ${CMAKE_Verilog_COMPILER_INIT})
    set(_CMAKE_Verilog_COMPILER_FALLBACK ${CMAKE_Verilog_COMPILER_INIT})
  elseif(NOT _CMAKE_Verilog_COMPILER_LIST)
    # Known compilers:
    #  Open Source
    #    slang     : https://sv-lang.com/
    #    verilator : https://www.veripool.org/projects/verilator
    #    iverilog  : http://iverilog.icarus.com/
    #  EDA paid tools
    #    irun, ncverilog    : https://www.cadence.com/
    #    vcs                : https://www.synopsys.com/
    #    modelsim           : https://www.mentor.com/products/fv/

    set(_CMAKE_Verilog_COMPILER_LIST slang verilator iverilog ncverilog vcs modelsim)

    set(_Verilog_COMPILER_NAMES_SVlang   slang)
    set(_Verilog_COMPILER_NAMES_Veripool verilator)
    set(_Verilog_COMPILER_NAMES_Icarus   iverilog)
    set(_Verilog_COMPILER_NAMES_Cadence  ncverilog) #irun ?
    set(_Verilog_COMPILER_NAMES_Synopsys vcs)
    set(_Verilog_COMPILER_NAMES_Mentor   modelsim)
  endif()

  # Find the compiler.
  find_program(CMAKE_Verilog_COMPILER NAMES ${_CMAKE_Verilog_COMPILER_LIST} DOC "Verilog compiler")
  if(_CMAKE_Verilog_COMPILER_FALLBACK AND NOT CMAKE_Verilog_COMPILER)
    set(CMAKE_Verilog_COMPILER "${_CMAKE_Verilog_COMPILER_FALLBACK}" CACHE FILEPATH "Verilog compiler" FORCE)
  endif()
  unset(_CMAKE_Verilog_COMPILER_FALLBACK)
  unset(_CMAKE_Verilo_COMPILER_LIST)
endif()

mark_as_advanced(CMAKE_Verilog_COMPILER)

get_filename_component(_CMAKE_Verilog_COMPILER_NAME_WE ${CMAKE_Verilog_COMPILER} NAME_WE)
if(_CMAKE_Verilog_COMPILER_NAME_WE IN_LIST _Verilog_COMPILER_NAMES_SVlang )
  set(CMAKE_Verilog_OUTPUT_EXTENSION )
  set(CMAKE_Verilog_COMPILER_ID SVLang )
elseif(_CMAKE_Verilog_COMPILER_NAME_WE IN_LIST _Verilog_COMPILER_NAMES_Veripool)
  set(CMAKE_Verilog_OUTPUT_EXTENSION .cpp)
  set(CMAKE_Verilog_COMPILER_ID Veripool )
elseif(_CMAKE_Verilog_COMPILER_NAME_WE IN_LIST _Verilog_COMPILER_NAMES_Icarus)
  set(CMAKE_Verilog_OUTPUT_EXTENSION .o)
  set(CMAKE_Verilog_COMPILER_ID Icarus )
elseif(_CMAKE_Verilog_COMPILER_NAME_WE IN_LIST _Verilog_COMPILER_NAMES_Cadence)
  set(CMAKE_Verilog_OUTPUT_EXTENSION .o)
  set(CMAKE_Verilog_COMPILER_ID Cadence )
elseif(_CMAKE_Verilog_COMPILER_NAME_WE IN_LIST _Verilog_COMPILER_NAMES_Synopsys)
  set(CMAKE_Verilog_OUTPUT_EXTENSION .o)
  set(CMAKE_Verilog_COMPILER_ID Synopsys )
elseif(_CMAKE_Verilog_COMPILER_NAME_WE IN_LIST _Verilog_COMPILER_NAMES_Mentor)
  set(CMAKE_Verilog_OUTPUT_EXTENSION .o)
  set(CMAKE_Verilog_COMPILER_ID Mentor )
endif()

# configure variables set in this file for fast reload later on
# configure_file(${CMAKE_ROOT}/Modules/CMakeVerilogCompiler.cmake.in
#   ${CMAKE_PLATFORM_INFO_DIR}/CMakeVerilogCompiler.cmake
#   )
configure_file(${CMAKE_CURRENT_LIST_DIR}/CMakeVerilogCompiler.cmake.in
  ${CMAKE_PLATFORM_INFO_DIR}/CMakeVerilogCompiler.cmake
  )

set(CMAKE_Verilog_COMPILER_ENV_VAR "VC")