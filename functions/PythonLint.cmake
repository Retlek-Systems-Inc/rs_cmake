#######################################################################
# @copyright 2024 Retlek Systems Inc.
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
PythonLint
----------

Lints a list of code with isort, black, flake8, and pylint

PythonLint(
  TARGET  <target name to lint>
  SOURCES   <filename> [<filename> ...]
  [LINE_LENGTH <max line length>] - defaults to 200
  [FLAKE8_ARGS <args> [<args> ...]]
  [PYLINT_ARGS <args> [<args> ...]]
)

Examples:

.. code-block:: cmake

  # First setup virtual env.
  PythonSetupVenv(REQUIREMENTS requirements.txt)
  PythonLint(
     TARGET foo
     SOURCES
        foo.py
     LINE_LENGTH 200
  )

The following variables are defined by this module:

.. variable:: PythonLint_<target name>

Execution of PythonLint_<target name> will result in a
<target_name>_python_lint.rpt file in the associated build directory.
#]=======================================================================]

function(PythonLint)
    if(NOT DEFINED Python3_EXECUTABLE)
        message(AUTHOR_WARNING "PythonLint: Python3 not defined, use `find_package(Python3 ... REQUIRED)")
        return()
    endif()

    include( CMakeParseArguments )
    cmake_parse_arguments(_arg
                          ""
                          "TARGET;LINE_LENGTH"
                          "SOURCES;FLAKE8_ARGS;PYLINT_ARGS"
                          ${ARGN})

    if( NOT _arg_TARGET )
        message( FATAL_ERROR "Must specify TARGET <target> create the tests for" )
    endif()

    if(NOT _arg_SOURCES )
        message( FATAL_ERROR "Must specify SOURCES <sources....>" )
    endif()

    if(NOT _arg_LINE_LENGTH)
        set(_arg_LINE_LENGTH 200)
    endif()

    if(NOT _arg_FLAKE8_ARGS)
        set(_arg_FLAKE8_ARGS)
    endif()

    if(NOT _arg_PYLINT_ARGS)
        set(_arg_PYLINT_ARGS)
    endif()

    set(_rpt_file ${CMAKE_CURRENT_BINARY_DIR}/${_arg_TARGET}_python_lint.rpt)

    add_custom_command(
        OUTPUT
            ${_rpt_file}
        DEPENDS
            ${_arg_SOURCES}
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        COMMAND ${Python3_EXECUTABLE} -m black  --line-length     ${_arg_LINE_LENGTH} ${_arg_SOURCES} >  ${_rpt_file}
        COMMAND ${Python3_EXECUTABLE} -m isort  --line-length     ${_arg_LINE_LENGTH} ${_arg_SOURCES} >> ${_rpt_file}
        COMMAND ${Python3_EXECUTABLE} -m flake8 --max-line-length ${_arg_LINE_LENGTH} ${_arg_FLAKE8_ARGS} ${_arg_SOURCES} >> ${_rpt_file}
        COMMAND ${Python3_EXECUTABLE} -m pylint --max-line-length ${_arg_LINE_LENGTH} ${_arg_PYLINT_ARGS} ${_arg_SOURCES} >> ${_rpt_file}
    COMMENT "Linting for ${arg_TARGET} Python Files"
    )
    add_custom_target( PythonLint_${_arg_TARGET} DEPENDS ${_rpt_file})
endfunction(PythonLint)
