#######################################################################
# @copyright 2026 Retlek Systems Inc.
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
UvSetupVenv
-----------

Create and sync the Python virtual environment of a uv project (``pyproject.toml`` +
``uv.lock``) for this repo, and retarget ``Python3_EXECUTABLE`` to it. This is the default
way to set up Python; ``PythonSetupVenv`` remains for requirements-file projects.

.. code-block:: cmake

  UvSetupVenv(
      [EXCLUDE_FROM_ALL]
      [NO_DEFAULT_GROUPS]            - pass --no-default-groups (only GROUPS are installed)
      [ALL_PACKAGES]                 - install every uv workspace member (--all-packages)
      [VERSION <Python version>]     - passed to uv as --python
      [VENV_DIR <dir>]               - default "${CMAKE_SOURCE_DIR}/.venv"
      [PROJECT_DIR <dir>]            - directory holding pyproject.toml/uv.lock, default "${CMAKE_SOURCE_DIR}"
      [LOCK_MODE <LOCKED|FROZEN|UPDATE>] - default LOCKED (fail when uv.lock is out of date)
      [GROUPS <group> [<group> ...]] - dependency groups to install (--group)
      [EXTRAS <extra> [<extra> ...]] - optional dependencies to install (--extra)
      [DEPENDS <file> [<file> ...]]  - extra files that trigger a re-sync (e.g. workspace member pyproject.toml)
  )

LOCK_MODE:

- ``LOCKED`` (``uv sync --locked``): use ``uv.lock``, fail if it no longer matches ``pyproject.toml``.
  Run ``uv lock`` after changing dependencies.
- ``FROZEN`` (``uv sync --frozen``): use ``uv.lock`` as is, without checking it.
- ``UPDATE`` (``uv sync``): re-lock when needed, writing ``uv.lock``.

Examples:

.. code-block:: cmake

  UvSetupVenv(
      VERSION 3.12
      GROUPS ci
      NO_DEFAULT_GROUPS
  )

The environment is synced at configure time when it is missing or older than
``pyproject.toml`` / ``uv.lock`` / ``DEPENDS``, so ``Python3_EXECUTABLE`` and its packages are
usable during configuration, and again at build time (``SetupPythonEnv`` target,
``<VENV_DIR>/venv.stamp``) whenever those files change.

Requires ``uv`` on the ``PATH`` (or ``UV_EXECUTABLE`` set).

The following targets are created using this command:

.. variable:: SetupPythonEnv

The following variables are set by this command:

.. variable:: UV_EXECUTABLE

  The ``uv`` program (cache variable).

.. variable:: Python3_EXECUTABLE

  Retargeted to the virtual environment's interpreter.
#]=======================================================================]

# Retarget find_package(Python3) to the virtual environment in VENV_DIR (shared with PythonSetupVenv).
macro(_rs_python_use_venv _venv_dir)
  set(ENV{VIRTUAL_ENV} "${_venv_dir}")
  set(Python3_FIND_VIRTUALENV ONLY)
  unset(Python3_EXECUTABLE)
  unset(Python3_EXECUTABLE CACHE)
  unset(_Python3_EXECUTABLE CACHE)
  find_package(Python3 COMPONENTS Interpreter Development)
  if(NOT DEFINED Python3_EXECUTABLE)
    message(FATAL_ERROR "Python not found in ${_venv_dir}: delete it, then reconfigure and build SetupPythonEnv")
  endif()
endmacro()

function(UvSetupVenv)
  include(CMakeParseArguments)
  cmake_parse_arguments(_arg
    "EXCLUDE_FROM_ALL;NO_DEFAULT_GROUPS;ALL_PACKAGES"
    "VERSION;VENV_DIR;PROJECT_DIR;LOCK_MODE"
    "GROUPS;EXTRAS;DEPENDS"
    ${ARGN})

  if(NOT _arg_VENV_DIR)
    set(_arg_VENV_DIR "${CMAKE_SOURCE_DIR}/.venv")
  endif()
  if(NOT _arg_PROJECT_DIR)
    set(_arg_PROJECT_DIR "${CMAKE_SOURCE_DIR}")
  endif()
  if(NOT _arg_LOCK_MODE)
    set(_arg_LOCK_MODE LOCKED)
  endif()

  find_program(UV_EXECUTABLE uv)
  if(NOT UV_EXECUTABLE)
    message(FATAL_ERROR "UvSetupVenv: uv not found - install it (https://docs.astral.sh/uv/) "
                        "or use PythonSetupVenv(... MANAGER venv)")
  endif()

  set(_pyproject "${_arg_PROJECT_DIR}/pyproject.toml")
  set(_lock "${_arg_PROJECT_DIR}/uv.lock")
  if(NOT EXISTS "${_pyproject}")
    message(FATAL_ERROR "UvSetupVenv: no pyproject.toml in ${_arg_PROJECT_DIR}")
  endif()

  set(_sync_args sync --project "${_arg_PROJECT_DIR}")
  if(_arg_LOCK_MODE STREQUAL "LOCKED")
    list(APPEND _sync_args --locked)
  elseif(_arg_LOCK_MODE STREQUAL "FROZEN")
    list(APPEND _sync_args --frozen)
  elseif(NOT _arg_LOCK_MODE STREQUAL "UPDATE")
    message(FATAL_ERROR "UvSetupVenv: LOCK_MODE must be LOCKED, FROZEN or UPDATE, not ${_arg_LOCK_MODE}")
  endif()
  if(_arg_VERSION)
    list(APPEND _sync_args --python "${_arg_VERSION}")
  endif()
  if(_arg_NO_DEFAULT_GROUPS)
    list(APPEND _sync_args --no-default-groups)
  endif()
  if(_arg_ALL_PACKAGES)
    list(APPEND _sync_args --all-packages)
  endif()
  foreach(_g IN LISTS _arg_GROUPS)
    list(APPEND _sync_args --group "${_g}")
  endforeach()
  foreach(_e IN LISTS _arg_EXTRAS)
    list(APPEND _sync_args --extra "${_e}")
  endforeach()

  set(_deps "${_pyproject}" ${_arg_DEPENDS})
  if(EXISTS "${_lock}")
    list(APPEND _deps "${_lock}")
  endif()
  set(_uv_cmd ${CMAKE_COMMAND} -E env "UV_PROJECT_ENVIRONMENT=${_arg_VENV_DIR}" "${UV_EXECUTABLE}" ${_sync_args})
  set(stamp_file "${_arg_VENV_DIR}/venv.stamp")

  # Configure time: (re)sync when the environment is missing or out of date.
  set(_needs_sync FALSE)
  if(NOT EXISTS "${stamp_file}")
    set(_needs_sync TRUE)
  else()
    foreach(_d IN LISTS _deps)
      if("${_d}" IS_NEWER_THAN "${stamp_file}")
        set(_needs_sync TRUE)
      endif()
    endforeach()
  endif()
  if(_needs_sync)
    message(STATUS "UvSetupVenv: syncing ${_arg_VENV_DIR} from ${_pyproject}")
    execute_process(COMMAND ${_uv_cmd} RESULT_VARIABLE _rc)
    if(NOT _rc EQUAL 0)
      message(FATAL_ERROR "UvSetupVenv: `uv ${_sync_args}` failed (${_rc})")
    endif()
    file(TOUCH "${stamp_file}")
  else()
    message(STATUS "UvSetupVenv: Using existing ${_arg_VENV_DIR}")
  endif()

  # Build time: re-sync when the project or lock changes.
  add_custom_command(
    OUTPUT "${stamp_file}"
    DEPENDS ${_deps}
    COMMAND ${_uv_cmd}
    COMMAND ${CMAKE_COMMAND} -E touch "${stamp_file}"
    WORKING_DIRECTORY "${_arg_PROJECT_DIR}"
    COMMENT "Syncing Python environment `${_arg_VENV_DIR}` with uv from `${_pyproject}`."
  )

  set(target_opts)
  if(_arg_EXCLUDE_FROM_ALL)
    list(APPEND target_opts EXCLUDE_FROM_ALL)
  endif()
  add_custom_target(SetupPythonEnv ${target_opts} DEPENDS "${stamp_file}")

  _rs_python_use_venv("${_arg_VENV_DIR}")
  # The macro's find_package result lives in this function scope: export it.
  set(Python3_EXECUTABLE "${Python3_EXECUTABLE}" PARENT_SCOPE)
  set(Python3_FOUND "${Python3_FOUND}" PARENT_SCOPE)
  set(Python3_Interpreter_FOUND "${Python3_Interpreter_FOUND}" PARENT_SCOPE)
  set(Python3_VERSION "${Python3_VERSION}" PARENT_SCOPE)
endfunction(UvSetupVenv)
