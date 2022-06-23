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

# https://blog.kitware.com/static-checks-with-cmake-cdash-iwyu-clang-tidy-lwyu-cpplint-and-cppcheck/

option(STATIC_ANALYSIS "Use Static Analysis tools." OFF)

if(STATIC_ANALYSIS)
    # This is used to add targets like third-party libraries that we want to bypass static analysis.
    add_custom_target(BypassStaticAnalysis)

    option(USE_CLANG_TIDY "Use Clang Tidy to view any inefficiencies or good practices." ON)

    if (USE_CLANG_TIDY)
        find_program(CLANG_TIDY 
          NAMES
            clang-tidy
            clang-tidy-14
            clang-tidy-13
            clang-tidy-11
            clang-tidy-10
            clang-tidy-9
            clang-tidy-8
            clang-tidy-7
            clang-tidy-6.0
            clang-tidy-5.0
            clang-tidy-4.0
            clang-tidy-3.9
        )
        message(STATUS "CLANG_TIDY = ${CLANG_TIDY}")
        if(NOT CLANG_TIDY)
            message(WARNING "Could not find clang-tidy, must be installed to perform static checks.")
        else()
            option(CLANG_TIDY_FIX "Perform fixes for Clang-Tidy" OFF)

            set(CMAKE_C_CLANG_TIDY ${CLANG_TIDY} "-format-style=file")
            set(CMAKE_CXX_CLANG_TIDY ${CLANG_TIDY} "-format-style=file")

            if (CLANG_TIDY_FIX)
                list(APPEND CMAKE_C_CLANG_TIDY   "-fix")
                list(APPEND CMAKE_CXX_CLANG_TIDY "-fix")
            endif()
        endif()
    endif()
    # Clang-Tidy None file for build dir /_deps - anything third-party or grabbed from elsewhere don't do clang tidy on.
    configure_file( "${CMAKE_CURRENT_LIST_DIR}/StaticAnalysis/.clang-tidy.none.in"
                    "${CMAKE_BINARY_DIR}/_deps/.clang-tidy" COPYONLY )
    
    # CppCheck - http://cppcheck.sourceforge.net/
    option(USE_CPPCHECK "Use CPP check to view any inefficiencies or good practices." OFF)
    if (USE_CPPCHECK)
        find_program(CPPCHECK
        NAMES
            cppcheck
            CppCheck
        )
        if(NOT CPPCHECK)
            message(WARNING "Could not find cppcheck, must be installed to perform static checks.")
        else()
            set(CMAKE_CXX_CPPCHECK ${CPPCHECK}
                --inline-suppr
                --inconclusive
                --enable=all
                --force
                --check-config
                --suppress=missingIncludeSystem
                "--template='{file}:{line} {severity} ({id}):{message}'")
        endif()
    endif(USE_CPPCHECK)
                
    #Google style checks:
    # https://github.com/cpplint/cpplint
    option(USE_CPPLINT "Use CPP Lint to view any inefficiencies or good practices." OFF)
    if (USE_CPPLINT)
        find_program(CPPLINT
          NAMES
            cpplint
        )
        if(NOT CPPLINT)
            message(WARNING "Could not find cpplint, must be installed to perform static checks.")
        else()
            set(CMAKE_CXX_CPPLINT ${CPPLINT} "--linelength=200")
        endif()
    endif(USE_CPPLINT)

    # Include what you use
    option(USE_IWYU "Use Include What You Use static analysis." OFF)
    if (USE_IWYU)
        find_program(INCLUDE_WHAT_YOU_USE 
          NAMES 
            iwyu
            include-what-you-use
        )
        if( NOT INCLUDE_WHAT_YOU_USE)
            message(WARNING "Could not find include-what-you-use iwyu, must be installed to perform static checks.")
        else()
             set(CMAKE_CXX_INCLUDE_WHAT_YOU_USE include-what-you-use -Xiwyu --verbose=3)
             set(CMAKE_C_INCLUDE_WHAT_YOU_USE include-what-you-use -Xiwyu --verbose=3)
        endif()
    endif(USE_IWYU)
endif(STATIC_ANALYSIS)


include( CMakeParseArguments )

# Function for adding clang_tidy specific checks to a given target.
# Note this is always generated regardless of compilation to ensure it is defined
# for all cases.
# target_clang_tidy_definitions
#   TARGET the cmake target to add the compilation clang tidy checks to.
#   CHECKS a list of checks to add to this specific target.
#
function(target_clang_tidy_definitions)
    set( _options )
    set( _oneValueArgs TARGET )
    set( _multiValueArgs CHECKS )
    cmake_parse_arguments( "_arg" "${_options}" "${_oneValueArgs}" "${_multiValueArgs}" ${ARGN} )

    if( _arg_UNPARSED_ARGUMENTS )
        message( FATAL_ERROR "Unknown argument(s) to target_clang_tidy_definitions: ${_arg_UNPARSED_ARGUMENTS}" )
    endif()

    if( NOT _arg_TARGET )
        message( FATAL_ERROR "Must specify TARGET <target> to add clang-tidy checks" )
    endif()

    if( NOT TARGET ${_arg_TARGET})
        message( FATAL_ERROR "Unknown TARGET <target> for clang-tidy checks: ${_arg_TARGET}" )
    endif()

    if( NOT _arg_CHECKS )
        message( FATAL_ERROR "No valid checks provided")
    endif()

    if(CMAKE_CXX_CLANG_TIDY)
        string( REPLACE ";" "," checks "${_arg_CHECKS}" )
        get_property( _curCLANG_TIDY TARGET ${_arg_TARGET} PROPERTY CXX_CLANG_TIDY)
        set( _curChecks "" )
        set( index 0 )
        foreach( option IN LISTS _curCLANG_TIDY)
            if (option MATCHES "^-checks=")
                # Append to this.
                set( _curChecks ${option} )
                break()
            endif()
        endforeach()
        if ( _curChecks MATCHES "^-checks=" )
            list( REMOVE_ITEM _curCLANG_TIDY ${_curChecks} )
            string( APPEND _curChecks "," "${checks}" )
            list( APPEND _curCLANG_TIDY ${_curChecks} )
        else()
            list( APPEND _curCLANG_TIDY "-checks=${checks}")
        endif()

        set_property( TARGET ${_arg_TARGET} PROPERTY CXX_CLANG_TIDY ${_curCLANG_TIDY} )
        #set_property( TARGET ${_arg_TARGET} APPEND PROPERTY C_CLANG_TIDY   -checks=${checks} )
        #set_property( TARGET ${_arg_TARGET} APPEND PROPERTY OBJCXX_CLANG_TIDY -checks=${checks} )
        #set_property( TARGET ${_arg_TARGET} APPEND PROPERTY OBJC_CLANG_TIDY   -checks=${checks} )
    endif()
endfunction()


# Function for adding cppcheck specific checks to a given target.
# Note this is always generated regardless of compilation to ensure it is defined
# for all cases.
# target_cppcheck_definitions
#   TARGET the cmake target to add the compilation cppcheck checks to.
#   DEFINES a list of defines to add to this specific target.
#
function(target_cppcheck_definitions)
    set( _options )
    set( _oneValueArgs TARGET )
    set( _multiValueArgs DEFINES )
    cmake_parse_arguments( "_arg" "${_options}" "${_oneValueArgs}" "${_multiValueArgs}" ${ARGN} )

    if( _arg_UNPARSED_ARGUMENTS )
        message( FATAL_ERROR "Unknown argument(s) to target_cppcheck_definitions: ${_arg_UNPARSED_ARGUMENTS}" )
    endif()

    if( NOT _arg_TARGET )
        message( FATAL_ERROR "Must specify TARGET <target> to add cppcheck checks" )
    endif()

    if( NOT TARGET ${_arg_TARGET})
        message( FATAL_ERROR "Unknown TARGET <target> for cppcheck definitions: ${_arg_TARGET}" )
    endif()

    if( NOT _arg_DEFINES )
        message( FATAL_ERROR "No valid defines provided")
    endif()

    if(USE_CPPCHECK)
      set_property( TARGET ${_arg_TARGET} APPEND PROPERTY CXX_CPPCHECK ${_arg_DEFINES} )
      #set_property( TARGET ${_arg_TARGET} APPEND PROPERTY C_CPPCHECK   -checks=${checks} )
    endif()
endfunction()


# Function for ignoring static analysis on a target
# Note this is used for  clang_tidy specific checks to a given target.
# Note this is always generated regardless of compilation to ensure it is defined
# for all cases.
# target_clang_tidy_definitions
#   TARGET the cmake target to add the compilation clang tidy checks to.
#   CLANG_TIDY when included will set all include directories to system.
#
function(target_ignore_static_analysis)
    set( _options CLANG_TIDY)
    set( _oneValueArgs TARGET )
    set( _multiValueArgs )
    cmake_parse_arguments( "_arg" "${_options}" "${_oneValueArgs}" "${_multiValueArgs}" ${ARGN} )

    if( _arg_UNPARSED_ARGUMENTS )
        message( FATAL_ERROR "Unknown argument(s) to target_ignore_static_analysis: ${_arg_UNPARSED_ARGUMENTS}" )
    endif()

    if( NOT _arg_TARGET )
        message( FATAL_ERROR "Must specify TARGET <target> to ignore_static_analysis" )
    endif()

    if( NOT TARGET ${_arg_TARGET})
        message( FATAL_ERROR "Unknown TARGET <target> for ignore_static_analysis : ${_arg_TARGET}" )
    endif()

    if( _arg_CLANG_TIDY )
        # don't perform any clang-tidy checks on this target
        get_target_property( _type ${_arg_TARGET} TYPE )
        if( NOT ${_type} STREQUAL "INTERFACE_LIBRARY" )
            set_target_properties( ${_arg_TARGET}
              PROPERTIES
                CXX_CLANG_TIDY ""
                C_CLANG_TIDY ""
                OBJC_CLANG_TIDY ""
                OBJCXX_CLANG_TIDY ""
                CXX_CPPCHECK ""
                C_CPPCHECK ""
            )
        endif()

        # When a target is marked as ignore static_analsysis CLANG_TIDY need to mark all include directories
        # as system so they are ignored
        get_target_property( interface_directories ${_arg_TARGET} INTERFACE_INCLUDE_DIRECTORIES )
        # Note cannot use target_include_directories and use this since some targets might use BUILD_INTERFACE and INSTALL_INTERFACe
        # When this is done even $<TARGET_GENEX_EVAL:${_arg_TARGET}, ${interface_directories}> doesn't resolve the names.
        set_target_properties(${_arg_TARGET}  PROPERTIES INTERFACE_SYSTEM_INCLUDE_DIRECTORIES "${interface_directories}" )

        message( STATUS "Converting ${_arg_TARGET} interface directories to system")
    endif()
endfunction()
