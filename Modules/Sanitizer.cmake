# Copyright (c) 2017 Paul Helter
#
#
# Loseley Based on FindAsan.cmake 
# The MIT License (MIT)
# Copyright (c) 2013 Matthew Arsenault

#
# This module tests if a particular sanitizer is supported by the compiler,
# and creates a build type based on the sanitizer used
#  (i.e. set CMAKE_BUILD_TYPE=ASan to use it). This sets the following variables:
#
# CMAKE_C_FLAGS_<ASAN|TSAN|MSAN|UBSAN>    - Flags to use for C with sanitizer
# CMAKE_CXX_FLAGS_<ASAN|TSAN|MSAN|UBSAN>  - Flags to use for C++ with sanitizer
# HAVE_<ADDRESS|THREAD|MEMORY|UNDEFINED>_SANITIZER - True or false if the sanitizer build type is available

# Defines the cmake flags necessary for particular builds.
#
# SETUP_FOR_SANITIZE(
#     BUILD_TYPE <ASAN|TSAN|MSAN|UBSAN>
# )
#
# Outputs:
# CMAKE_C_FLAGS_<ASAN|TSAN|MSAN|UBSAN>    - Flags to use for C with sanitizer
# CMAKE_CXX_FLAGS_<ASAN|TSAN|MSAN|UBSAN>  - Flags to use for C++ with sanitizer
# HAVE_<ADDRESS|THREAD|MEMORY|UNDEFINED>_SANITIZER - True or false if the sanitizer build type is available


function(SETUP_FOR_SANITIZE)
    set(options NONE)
    set(oneValueArgs BUILD_TYPE)
    set(multiValueArgs)
    cmake_parse_arguments(San "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    include(CheckCCompilerFlag)

    string(TOUPPER ${San_BUILD_TYPE} _buildName)

    if ( ${_buildName} STREQUAL ASAN)
        set(_sanType address)
        set(_sanExtraFlags "-fno-omit-frame-pointer -fno-optimize-sibling-calls")
    elseif(${_buildName} STREQUAL TSAN)
        set(_sanType thread)
        set(_sanExtraFlags "")
    elseif(${_buildName} STREQUAL MSAN)
        set(_sanType memory)
        set(_sanExtraFlags "-fsanitize-memory-track-origins")
        # Need to build libc++ and libc++abi as per:
        # https://github.com/google/sanitizers/wiki/MemorySanitizerLibcxxHowTo
    elseif(${_buildName} STREQUAL UBSAN)
        set(_sanType undefined)
        set(_sanExtraFlags "-fno-omit-frame-pointer -fno-optimize-sibling-calls")
    endif()

#    get_property(isMultiConfig GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)
#    if(isMultiConfig)
#        if(NOT "${_buildName} IN_LIST CMAKE_CONFIGURATION_TYPES)
#            list(APPEND CMAKE_CONFIGURATION_TYPES ${_buildName})
#        endif()
#    endif()

    set(_sanFlag "-fsanitize=${_sanType}")
    string(TOUPPER ${_sanType} _sanTypeU)
    set(_sanFlags "${_sanFlag} ${_sanExtraFlags}")
    
    # Set -Werror to catch "argument unused during compilation" warnings
    set(CMAKE_REQUIRED_FLAGS "-Werror ${_sanFlags}")
    check_c_compiler_flag(${_sanFlag} _haveFlagForSan)
    unset(CMAKE_REQUIRED_FLAGS)

    if(NOT _haveFlagForSan)
        set( HAVE_${_sanTypeU}_SANITIZER FALSE PARENT_SCOPE)
        message( WARNING "The compiler must support '${_sanFlag}' in order to configure a ${_buildName} build")
        return()
    else()
        set( HAVE_${_sanTypeU}_SANITIZER TRUE PARENT_SCOPE)
        set( ${_sanTypeU}_SANITIZER_FLAG ${_sanFlags} PARENT_SCOPE)
    endif()
    
    #Valgrind specific options
    # TODO: Investigate :
    # CTEST_MEMORYCHECK_COMMAND
    # CTEST_MEMORYCHECK_COMMAND_OPTIONS
    # CTEST_MEMORYCHECK_SANITIZER_OPTIONS
    # CTEST_MEMORYCHECK_SUPPRESSIONS_FILE
    # CTEST_MEMORYCHECK_TYPE
    # set(VALGRIND_OPTIONS "-q --tool=memcheck --leak-check=yes -leak-check=full --num-callers=20 --track-origins=yes --trace-children=yes")
    # set(MEMORYCHECK_SUPPRESSIONS_FILE ${CMAKE_CURRENT_LIST_DIR}/memorycheck.suppressions CACHE STRING "Suppressions file for Memory Checks")
    
    #Otherwise continue and set up everything.
    set(CMAKE_C_FLAGS_${_buildName} "-O1 -g ${_sanFlags}"
        CACHE STRING "Flags used by the C compiler during ${_buildName} builds."
        FORCE)
    set(CMAKE_CXX_FLAGS_${_buildName} "-O1 -g ${_sanFlags}"
        CACHE STRING "Flags used by the C++ compiler during ${_buildName} builds."
        FORCE)
    set(CMAKE_EXE_LINKER_FLAGS_${_buildName} "${_sanFlag}"
        CACHE STRING "Flags used for linking binaries during ${_buildName} builds."
        FORCE)
    set(CMAKE_SHARED_LINKER_FLAGS_${_buildName} "${_sanFlag}"
        CACHE STRING "Flags used by the shared libraries linker during ${_buildName} builds."
        FORCE)
    set(CMAKE_STATIC_LINKER_FLAGS_${_buildName} ""
        CACHE STRING "Flags used by the static libraries linker during ${_buildName} builds."
        FORCE)
    set(CMAKE_MODULE_LINKER_FLAGS_${_buildName} "${_sanFlag}"
        CACHE STRING "Flags used by the module libraries linker during ${_buildName} builds."
        FORCE)
    mark_as_advanced(CMAKE_C_FLAGS_${_buildName}
                     CMAKE_CXX_FLAGS_${_buildName}
                     CMAKE_EXE_LINKER_FLAGS_${_buildName}
                     CMAKE_SHARED_LINKER_FLAGS_${_buildName}
                     CMAKE_STATIC_LINKER_FLAGS_${_buildName}
                     CMAKE_MODULE_LINKER_FLAGS_${_buildName})
endfunction() # SETUP_FOR_SANITIZER