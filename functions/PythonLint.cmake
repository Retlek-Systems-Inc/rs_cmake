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

Lints and format-checks a list of Python files with ruff (``ruff check`` and
``ruff format --check``), which replaces isort, black, flake8, pylint and pyupgrade.
Configure the rules in the project's ``pyproject.toml`` / ``ruff.toml`` (``[tool.ruff]``).

.. code-block:: cmake

  PythonLint(
    TARGET  <target name to lint>
    SOURCES   <filename> [<filename> ...]
    [LINE_LENGTH <max line length>]         - defaults to 200
    [RUFF_VERSION <version>]                - ruff version when run through `uv tool run`
    [CHECK_ARGS <args> [<args> ...]]        - extra `ruff check` arguments
    [FORMAT_ARGS <args> [<args> ...]]       - extra `ruff format` arguments
  )

ruff is taken from the active virtual environment, then the ``PATH``, then ``uv tool run ruff``.
``FLAKE8_ARGS`` / ``PYLINT_ARGS`` are accepted for backward compatibility and ignored.

Examples:

.. code-block:: cmake

  UvSetupVenv(GROUPS dev)
  PythonLint(
     TARGET foo
     SOURCES
        foo.py
     LINE_LENGTH 200
  )

The following targets are defined by this module:

.. variable:: PythonLint_<target name>

Execution of PythonLint_<target name> will result in a
<target_name>_python_lint.rpt file in the associated build directory.
#]=======================================================================]

function(PythonLint)
    include( CMakeParseArguments )
    cmake_parse_arguments(_arg
                          ""
                          "TARGET;LINE_LENGTH;RUFF_VERSION"
                          "SOURCES;CHECK_ARGS;FORMAT_ARGS;FLAKE8_ARGS;PYLINT_ARGS"
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

    if(_arg_FLAKE8_ARGS OR _arg_PYLINT_ARGS)
        message(AUTHOR_WARNING "PythonLint: FLAKE8_ARGS/PYLINT_ARGS are ignored - ruff replaced flake8 and pylint, use CHECK_ARGS")
    endif()

    set(_ruff)
    set(_hints)
    if(DEFINED ENV{VIRTUAL_ENV})
        list(APPEND _hints "$ENV{VIRTUAL_ENV}/bin")
    endif()
    if(DEFINED Python3_EXECUTABLE)
        get_filename_component(_py_bin "${Python3_EXECUTABLE}" DIRECTORY)
        list(APPEND _hints "${_py_bin}")
    endif()
    find_program(RUFF_EXECUTABLE ruff HINTS ${_hints})
    if(RUFF_EXECUTABLE)
        set(_ruff "${RUFF_EXECUTABLE}")
    else()
        find_program(UV_EXECUTABLE uv)
        if(UV_EXECUTABLE)
            set(_ruff_spec ruff)
            if(_arg_RUFF_VERSION)
                set(_ruff_spec "ruff@${_arg_RUFF_VERSION}")
            endif()
            set(_ruff "${UV_EXECUTABLE}" tool run ${_ruff_spec})
        else()
            message(AUTHOR_WARNING "PythonLint: neither ruff nor uv found - PythonLint_${_arg_TARGET} not created")
            return()
        endif()
    endif()

    set(_rpt_file ${CMAKE_CURRENT_BINARY_DIR}/${_arg_TARGET}_python_lint.rpt)

    add_custom_command(
        OUTPUT
            ${_rpt_file}
        DEPENDS
            ${_arg_SOURCES}
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        COMMAND ${_ruff} check  --line-length ${_arg_LINE_LENGTH} --output-file ${_rpt_file} ${_arg_CHECK_ARGS} ${_arg_SOURCES}
        COMMAND ${_ruff} format --check --diff --line-length ${_arg_LINE_LENGTH} ${_arg_FORMAT_ARGS} ${_arg_SOURCES}
        COMMENT "Linting ${_arg_TARGET} Python files with ruff"
    )
    add_custom_target( PythonLint_${_arg_TARGET} DEPENDS ${_rpt_file})
endfunction(PythonLint)
