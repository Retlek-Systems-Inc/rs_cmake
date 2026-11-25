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

Create a Python virtual environment locally for this repo from a pip requirements file, and
retarget ``Python3_EXECUTABLE`` to it. For a uv project (``pyproject.toml`` + ``uv.lock``) use
``UvSetupVenv`` instead.

.. code-block:: cmake

  PythonSetupVenv(
      [EXCLUDE_FROM_ALL]
      [VERSION <Python version>]
      [VENV_DIR <full .venv dir location>] - default is "${CMAKE_SOURCE_DIR}/.venv"
      [MANAGER <uv|venv>]                  - default is RS_PYTHON_ENV_MANAGER
      REQUIREMENTS <pip requirements.txt file>
  )

``MANAGER``:

- ``uv`` (default): ``uv venv --seed`` creates the environment and ``uv pip install -r`` installs
  the requirements. When ``uv`` is not installed this falls back to ``venv`` with a warning.
- ``venv`` (backward compatibility): ``python3 -m venv`` and ``pip install -r``; ``ruff`` is
  installed alongside for ``PythonLint``.

The default comes from the cache variable ``RS_PYTHON_ENV_MANAGER`` (``uv``), e.g.
``-DRS_PYTHON_ENV_MANAGER=venv`` selects ``venv`` for every call.

Examples:

.. code-block:: cmake

  PythonSetupVenv(
        REQUIREMENTS requirements.txt
  )

The following targets are created using this command:

.. variable:: SetupPythonEnv

The Python3 executable is retargeted to the venv directory at configure time.
The default VENV_DIR was selected to support the VSCode IDE.
#]=======================================================================]

set(RS_PYTHON_ENV_MANAGER "uv" CACHE STRING "Python environment manager of PythonSetupVenv: uv or venv")
set_property(CACHE RS_PYTHON_ENV_MANAGER PROPERTY STRINGS uv venv)

function(PythonSetupVenv)
  include( CMakeParseArguments )
  cmake_parse_arguments(_arg "EXCLUDE_FROM_ALL" "VERSION;VENV_DIR;REQUIREMENTS;MANAGER" "" ${ARGN})

  if(NOT _arg_VENV_DIR )
    set(_arg_VENV_DIR ${CMAKE_SOURCE_DIR}/.venv )
  endif()
  if(NOT _arg_MANAGER)
    set(_arg_MANAGER "${RS_PYTHON_ENV_MANAGER}")
  endif()
  if(NOT _arg_MANAGER MATCHES "^(uv|venv)$")
    message(FATAL_ERROR "PythonSetupVenv: MANAGER must be uv or venv, not ${_arg_MANAGER}")
  endif()
  if(_arg_MANAGER STREQUAL "uv")
    find_program(UV_EXECUTABLE uv)
    if(NOT UV_EXECUTABLE)
      message(WARNING "PythonSetupVenv: uv not found, falling back to python3 -m venv")
      set(_arg_MANAGER venv)
    endif()
  endif()

  set(stamp_file ${_arg_VENV_DIR}/venv.stamp)

  if(EXISTS "${_arg_VENV_DIR}")
    message(STATUS "PythonSetupVenv: Using existing ${_arg_VENV_DIR}")
  elseif(_arg_MANAGER STREQUAL "uv")
    message(STATUS "PythonSetupVenv: Creating a new ${_arg_VENV_DIR} with uv")
    set(_python_arg)
    if(_arg_VERSION)
      set(_python_arg --python ${_arg_VERSION})
    endif()
    # --seed: pip in the environment, as with python3 -m venv.
    execute_process(
      COMMAND "${UV_EXECUTABLE}" venv --seed ${_python_arg} ${_arg_VENV_DIR}
      RESULT_VARIABLE _rc
    )
    if(NOT _rc EQUAL 0)
      message(FATAL_ERROR "PythonSetupVenv: uv venv failed (${_rc})")
    endif()
  else()
    message(STATUS "PythonSetupVenv: Creating a new ${_arg_VENV_DIR}")
    set(ENV{VIRTUAL_ENV} "")
    set(Python3_FIND_VIRTUALENV STANDARD)
    find_package (Python3 ${_arg_VERSION} REQUIRED COMPONENTS Interpreter)

    if (NOT DEFINED Python3_EXECUTABLE)
      message(FATAL_ERROR "Python not defined, use `find_package(Python ... REQUIRED)")
    endif()
    execute_process(
      COMMAND ${CMAKE_COMMAND} -E echo "Creating python virtual environment in ${_arg_VENV_DIR}"
      COMMAND "${Python3_EXECUTABLE}" -m venv ${_arg_VENV_DIR}
    )
  endif()

  if(_arg_MANAGER STREQUAL "uv")
    set(_install_cmds
      COMMAND "${UV_EXECUTABLE}" pip install --python ${_arg_VENV_DIR}/bin/python -r ${_arg_REQUIREMENTS} --upgrade
    )
  else()
    set(_install_cmds
      COMMAND ${_arg_VENV_DIR}/bin/pip install ruff --upgrade
      COMMAND ${_arg_VENV_DIR}/bin/pip install -r ${_arg_REQUIREMENTS} --upgrade
    )
  endif()

  add_custom_command(
    OUTPUT ${stamp_file}
    DEPENDS ${_arg_REQUIREMENTS}
    ${_install_cmds}
    COMMAND ${CMAKE_COMMAND} -E touch ${stamp_file}
    COMMENT "Installing Python requirements in `${_arg_VENV_DIR}` from `${_arg_REQUIREMENTS}` (${_arg_MANAGER})."
  )

  set(target_opts)
  if(_arg_EXCLUDE_FROM_ALL)
    list(APPEND target_opts EXCLUDE_FROM_ALL)
  endif()

  add_custom_target (SetupPythonEnv
    ${target_opts}
    DEPENDS ${stamp_file}
  )

  # Retarget the Python3 executable.
  # Check if Python3_EXECUTABLE already points to .venv
  string(FIND "${Python3_EXECUTABLE}" "${_arg_VENV_DIR}" find_loc)
  if("${find_loc}" EQUAL 0)
    # Already pointing to venv so no need to re-target.
    return()
  endif()

  _rs_python_use_venv("${_arg_VENV_DIR}")
  set(Python3_EXECUTABLE "${Python3_EXECUTABLE}" PARENT_SCOPE)

endfunction(PythonSetupVenv)
