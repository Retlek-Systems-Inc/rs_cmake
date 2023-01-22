#######################################################################
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
#[=======================================================================[.rst:
GitHash
----------------

Creates the output variable GIT_HASH based on the current hash of the git repo.
Adds '-dirty' if the git repo is dirty.
Returns "Unknown" if can't find GIT.

Examples:

.. code-block:: cmake

  GitHash()
  message(STATUS "Git Hash: ${GIT_HASH}")

The following variables are defined by this module:

.. variable:: GIT_HASH  value of the git hash and `-dirty` if not up to date.
.. variable:: GIT_HASH_ONLY value of the git hash.

#]=======================================================================]


function( GitHash )
    set(_git_hash "unknown")
    find_package(Git)
    if (GIT_FOUND)
        execute_process(
            COMMAND ${GIT_EXECUTABLE} rev-parse --short HEAD
            WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
            OUTPUT_VARIABLE _git_hash
            ERROR_QUIET
            OUTPUT_STRIP_TRAILING_WHITESPACE
        )
        execute_process(
            COMMAND ${GIT_EXECUTABLE} diff --quiet HEAD --
            WORKING_DIRECOTRY "${CMAKE_CURRENT_SOURCE_DIR}"
            RESULT_VARIABLE _git_dirty
            OUTPUT_VARIABLE _git_dirty_out
            ERROR_QUIET
            OUTPUT_STRIP_TRAILING_WHITESPACE
        )
        set( GIT_HASH_ONLY "${_git_hash}" PARENT_SCOPE )
        if (_git_dirty EQUAL 0 )
            set( GIT_HASH "${_git_hash}" PARENT_SCOPE )
        else()
            set( GIT_HASH "${_git_hash}-dirty" PARENT_SCOPE )
        endif()
#        message( STATUS "Git Hash: ${_git_hash}")
    else()
        message( STATUS "Git not found")
    endif()
endfunction()
