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
Setup Python Venv
-----------------

Create the venv virtual environment for python locally for this repo.
Sets up default usage of the venv environment for python instead of the machine
installed version.

PythonSetupVenv(
    [VERSION <Python version>]
    [VENV_DIR <full .venv dir location>] - default is "${CMAKE_SOURCE_DIR}/.venv"
    REQUIREMENTS <pip requirements.txt file>
)

Examples:

.. code-block:: cmake

  PythonSetupVenv(
        REQUIREMENTS requirements.txt
  )

The following targets are created using this command:

.. variable:: PythonSetupVenv target

And the Python3 executable is retargeted to the venv directory
The default VENV_DIR was selected to support VSCode IDE

#]=======================================================================]

function(PythonSetupVenv)
  include( CMakeParseArguments )
  cmake_parse_arguments(_arg "" "VERSION;VENV_DIR;REQUIREMENTS" "" ${ARGN})

  if(NOT _arg_VENV_DIR )
    set(_arg_VENV_DIR ${CMAKE_SOURCE_DIR}/.venv )
  endif()

  if(NOT DEFINED Python3_EXECUTABLE)
      find_package (Python3 ${_arg_VERSION} REQUIRED COMPONENTS Interpreter)
  endif()

    if (NOT DEFINED Python3_EXECUTABLE)
        message(FATAL_ERROR "Python not defined, use `find_package(Python ... REQUIRED)")
    endif()

  add_custom_target (SetupPythonEnv
    DEPENDS
      ${_arg_REQUIREMENTS}
    COMMAND "${Python3_EXECUTABLE}" -m venv ${_arg_VENV_DIR}
    # Following are for PythonLint.cmake
    COMMAND ${_arg_VENV_DIR}/bin/pip install black isort flake8 pylint --upgrade
    COMMAND ${_arg_VENV_DIR}/bin/pip install -r ${_arg_REQUIREMENTS} --upgrade
    COMMENT "Building Python venv `${_arg_VENV_DIR}` from `${_arg_REQUIREMENTS}`."
  )

  # Retarget the Python3 executable.
  # Check if Python3_EXECUTABLE already points to .venv
  string(FIND "${_arg_VENV_DIR}" "${Python3_EXECUTABLE}" find_loc)
  if("${find_loc}" EQUAL 0)
    # Already pointing to venv so no need to re-target.
    return()
  endif()

  set(ENV{VIRTUAL_ENV} ${_arg_VENV_DIR})
  set(Python3_FIND_VIRTUALENV ONLY)
  unset (Python3_EXECUTABLE)
  find_package (Python3 COMPONENTS Interpreter Development)
endfunction(PythonSetupVenv)
