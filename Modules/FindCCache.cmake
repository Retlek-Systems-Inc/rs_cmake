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

# Based on : https://crascit.com/2016/04/09/using-ccache-with-cmake/

find_program(CCACHE_PROGRAM NAMES ccache DOC "path to the ccache executable")
mark_as_advanced(CCACHE_PROGRAM)

if( CCACHE_PROGRAM )
  execute_process(
	COMMAND "${CCACHE_PROGRAM}" --version
	OUTPUT_VARIABLE CCACHE_VERSION
	OUTPUT_STRIP_TRAILING_WHITESPACE
	RESULT_VARIABLE _Ccache_version_result
  )
  string(REGEX REPLACE ".* version ([0-9]+.[0-9]+.[0-9]+[a-z]*).*" "\\1" CCACHE_VERSION "${CCACHE_VERSION}")
  
  if(_CCache_version_result)
	message(WARNING "Unable to determine CCache version: ${_CCache_version_result}")
  endif()
endif()

# Verify find results
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(
    CCache
    REQUIRED_VARS CCACHE_PROGRAM
    VERSION_VAR CCACHE_VERSION
)

if(CCache_FOUND)
    set(CMAKE_C_COMPILER_LAUNCHER "${CCACHE_PROGRAM}")
    set(CMAKE_CXX_COMPILER_LAUNCHER "${CCACHE_PROGRAM}")
endif()
