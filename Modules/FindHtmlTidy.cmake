# @copyright 2021 Retlek Systems Inc.
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
#  Example Use case
# find_package( HtmlTidy )
# 
# add_target_html_tidy(
#   TARGET html_checks
#   HTML_FILES
#      x.html
#      y.html
# )

find_program(HTMLTIDY_PROGRAM NAMES tidy DOC "path to the HTML tidy executable")
mark_as_advanced(HTMLTIDY_PROGRAM)

if( HTMLTIDY_PROGRAM )
  execute_process(
	COMMAND "${HTMLTIDY_PROGRAM}" --version
	OUTPUT_VARIABLE HTMLTIDY_VERSION
	OUTPUT_STRIP_TRAILING_WHITESPACE
	RESULT_VARIABLE _HtmlTidy_version_result
  )
  string(REGEX REPLACE ".* version ([0-9]+.[0-9]+.[0-9]+[a-z]*).*" "\\1" HTMLTIDY_VERSION "${HTMLTIDY_VERSION}")
  
  if(_HtmlTidy_version_result)
	message(WARNING "Unable to determine HTML Tidy version: ${_HtmlTidy_version_result}")
  endif()
endif()

# Verify find results
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(
    HtmlTidy
    REQUIRED_VARS HTMLTIDY_PROGRAM
    VERSION_VAR HTMLTIDY_VERSION
)

# Function for adding html tidy checks to a given set of html files.
# Note this is always generated regardless of compilation to ensure it is defined
# for all cases.
# add_target_html_tidy
#   TARGET the cmake target create with the html checks
#   CHECKS a list of checks to add to this specific target.
#   HTML_FILES a list of html files to perform HTML Tidy
function(add_target_html_tidy)  
    set( _options )
    set( _oneValueArgs TARGET )
    set( _multiValueArgs CHECKS HTML_FILES )
    cmake_parse_arguments( "_arg" "${_options}" "${_oneValueArgs}" "${_multiValueArgs}" ${ARGN} )
    
    if( _arg_UNPARSED_ARGUMENTS )
        message( FATAL_ERROR "Unknown argument(s) to add_target_html_tidy: ${_arg_UNPARSED_ARGUMENTS}" )
    endif()
    
    if( NOT _arg_TARGET )
        message( FATAL_ERROR "Must specify TARGET <target> to add html-tidy checks" )
    endif()

    if( TARGET ${_arg_TARGET})
        message( FATAL_ERROR "TARGET already exists: ${_arg_TARGET}" )
    endif()
    
    if( NOT _arg_HTML_FLIES )
        message( FATAL_ERROR "No HTML_FILES <...> specified ")
    endif()

    if( HtmlTidy_FOUND )
        # Grab all the html files
        foreach (_html ${_arg_HTML_FLIES})
            file(RELATIVE_PATH _out_file ${CMAKE_CURRENT_SOURCE_DIR} ${_html})
            set(_out_file ${_out_file}.log)
            #message(STATUS "HTML Lint of ${_html} , ${_out_file}")
            add_custom_command(
                OUTPUT  ${_out_file}
                COMMAND ${HTMLTIDY_PROGRAM} -o ${_out_file} -e -q -xml ${CHECKS} ${_html}
                DEPENDS ${_html}
            )
            # build a list of all the results
            list(APPEND _HtmlTidy_results ${_out_file})
        endforeach()

        add_custom_target( check_html ALL
            DEPENDS ${_HtmlTidy_results}
        )
    else()
        message(STATUS "No Html Tidy checks performed on ${_arg_TARGET}")
    endif()
endfunction()
