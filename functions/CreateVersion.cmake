#######################################################################
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
# Function to create a Version File.

# CreateVersion
#   PROJECT project name to extract the version from.
#   TARGET the filename and variable name to generate - if not specified uses <PROJECT>Version as target.
#   OUTDIR output directory for resulting version information.
#
# Creates a structure containing all of the project version information for consumption.
# The newly created files are <PROJECT>Version.h and <PROJECT>Version.cpp in the OUTDIR.

# Used for CreateVersion relative directory.
set(_CreateVersion_DIR ${CMAKE_CURRENT_LIST_DIR} CACHE INTERNAL "")

function(CreateVersion)
    
    set( _options )
    set( _oneValueArgs PROJECT TARGET OUTDIR )
    set( _multiValueArgs )
    include( CMakeParseArguments )
    cmake_parse_arguments( "_arg" "${_options}" "${_oneValueArgs}" "${_multiValueArgs}" ${ARGN} )
    
    if( _arg_UNPARSED_ARGUMENTS )
        message( FATAL_ERROR "Unknown argument(s) to add_mock_target: ${_arg_UNPARSED_ARGUMENTS}" )
    endif()
    
    if( NOT _arg_PROJECT )
        message( FATAL_ERROR "Must specify PROJECT <project> to create the version info." )
    endif()

    if( NOT _arg_TARGET )
        message( WARNING "Setting TARGET to `${_arg_PROJECT}Version`.")
        set(_arg_TARGET ${_arg_PROJECT}Version)
    endif()
    
    if( NOT _arg_OUTDIR )
        message( FATAL_ERROR "Must specify OUTDIR <output directory> for version information files." )
    endif()
    
    set(_hdrs "${_arg_OUTDIR}/api/${_arg_TARGET}.h")
    set(_srcs "${_arg_OUTDIR}/src/${_arg_TARGET}.cpp")

    GitHash()    
    string(TIMESTAMP BUILD_TIMESTAMP "%s")
    configure_file("${_CreateVersion_DIR}/version.h.in"   "${_hdrs}" @ONLY )
    configure_file("${_CreateVersion_DIR}/version.cpp.in" "${_srcs}" @ONLY )

    add_library(${_arg_TARGET} STATIC ${_srcs} ${_hdrs} )
    target_include_directories(${_arg_TARGET}
        PUBLIC
            ${_arg_OUTDIR}/api
    )

endfunction()
