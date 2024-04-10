# @copyright 2022 Retlek Systems Inc.
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

#[=======================================================================[.rst:
AddConfiguration
----------------

Adds a CMake Configuration - used for checking linker and compiler settings
and adds the configuration derived from the base configuration

Examples:

.. code-block:: cmake

  # After project(... LANGUAGES <LANG>...)
  # or enable_language( <LANG> )
  # Perform
  AddConfiguration(
    CONFIG Coverage
    BASE_CONFIG Debug
    COMPILE_FLAGS
      --coverage
    LINKER_FLAGS
      --coverage
  )

For multiconfig - a warning will be issued if this config is not in the CMAKE_CONFIGURATION_TYPES

The following variables are defined by this module:
- where <LANG> is the set of languages used in compilation eg: C, CXX, etc.

.. variable:: CMAKE_<LANG>_FLAGS_<CONFIG>        flags for <LANG> compile with this configuration
.. variable:: CMAKE_EXE_LINKER_FLAGS_<CONFIG>    flags for linking exes for this configuration
.. variable:: CMAKE_SHARED_LINKER_FLAGS_<CONFIG> flags for linking shared libraries for this configuration
.. variable:: CMAKE_STATIC_LINKER_FLAGS_<CONFIG> flags for linking static libraries for this configuration
.. variable:: CMAKE_MODULE_LINKER_FLAGS_<CONFIG> flags for linking module libraries for this configuration
.. variable:: HAVE_<LANG>_FLAGS_<CONFIG>         have flags boolean for <LANG> compile with this configuration
.. variable:: <CONFIG>_SUPPORTED                 supported config boolean
#]=======================================================================]


function( AddConfiguration )
    set(options NONE)
    set(oneValueArgs CONFIG BASE_CONFIG)
    set(multiValueArgs COMPILE_FLAGS LINKER_FLAGS)
    cmake_parse_arguments(arg "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    # Check Config Is Defined
    get_property(isMultiConfig GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)
    if (isMultiConfig AND NOT ${arg_CONFIG} IN_LIST CMAKE_CONFIGURATION_TYPES)
        message( WARNING "The Configuration ${arg_CONFIG} is not defined in CMAKE_CONFIGURATION_TYPES")
        return()
    endif()

    # Check Base Config empty or defined
    if (isMultiCOnfig AND NOT ${arg_BASE_CONFIG} IN_LIST CMAKE_CONFIGURATION_TYPES)
        if (${arg_BASE_CONFIG} STREQUAL "")
            message( WARNING "Note no Base configuration for ${arg_CONFIG}")
        else()
            message( SEND_ERROR "The Base Configuration ${arg_BASE_CONFIG} is not in ${CMAKE_CONFIGURATION_TYPES}, and not empty")
            return()
        endif()
    endif()

    #message(STATUS "Running AddConfiguration with ${arg_CONFIG}, Base: ${arg_BASE_CONFIG}")
    # Check Base config is in the list

    string(TOUPPER ${arg_CONFIG} _configName)
    if (NOT "${arg_BASE_CONFIG}" STREQUAL "")
        string(TOUPPER ${arg_BASE_CONFIG} _baseConfigName)
    endif()

    get_property(_supportedLanguages GLOBAL PROPERTY ENABLED_LANGUAGES)
    include(CheckCompilerFlag OPTIONAL)
    foreach(_LANG IN LISTS _supportedLanguages)
        # Ignore ASM for now.
        if ("${_LANG}" MATCHES "^ASM")
            continue()
        endif()
        # Hack to get around checking linking in check_<LANG>_compiler_flag
        set(CMAKE_REQUIRED_LIBRARIES ${arg_LINKER_FLAGS})

        check_compiler_flag(${_LANG} "${arg_COMPILE_FLAGS}" ${_LANG}_${_configName}_SUPPORTED)

        if(${_LANG}_${_configName}_SUPPORTED)
            if (DEFINED _baseConfigName)
                string(JOIN " " _flags ${CMAKE_${_LANG}_FLAGS_${_baseConfigName}} ${arg_COMPILE_FLAGS})
            else()
                string(JOIN " " _flags ${arg_COMPILE_FLAGS})
            endif()
            #message(STATUS "Flags to be added to Lang ${_LANG}, ${_configName} = ${_flags}")

            set(CMAKE_${_LANG}_FLAGS_${_configName}
                ${_flags}
                CACHE STRING "Flags used by the ${_LANG} compiler during ${_configName} builds."
                FORCE
            )
            mark_as_advanced(CMAKE_${_LANG}_FLAGS_${_configName})
            set(${_configName}_SUPPORTED TRUE
                CACHE INTERNAL "Whether or not ${arg_CONFIG} is supported by at least one compiler."
            )
        else()
            message( WARNING "The ${_LANG} compiler does not support '${arg_COMPILE_FLAGS}' for ${_configName} build")
        endif()
    endforeach()

    if (${_configName}_SUPPORTED)
        set(linkerObjects EXE SHARED MODULE) #STATIC
        foreach(_OBJ IN LISTS linkerObjects)
            if (DEFINED _baseConfigName)
                string(JOIN " " _flags ${CMAKE_${_OBJ}_FLAGS_${_baseConfigName}} ${arg_LINKER_FLAGS})
            else()
                string(JOIN " " _flags ${arg_LINKER_FLAGS})
            endif()
            #message(STATUS "Flags to be added to Obj ${_OBJ}, ${_configName} = ${_flags}")

            set(CMAKE_${_OBJ}_LINKER_FLAGS_${_configName}
                ${_flags}
                CACHE STRING "Flags used for linking ${_OBJ} during ${_configName} builds."
                FORCE
            )
            mark_as_advanced(CMAKE_${_OBJ}_LINKER_FLAGS_${_configName})
        endforeach()
    endif()
endfunction() # AddConfiguration
