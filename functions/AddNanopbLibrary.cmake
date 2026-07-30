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
AddNanopbLibrary
----------------

Generates C sources/headers from ``.proto`` files using nanopb's generator,
and wraps them (plus the nanopb runtime, pb_common/pb_encode/pb_decode) into
a static library target. Also provides ``add_python_proto_library`` for
generating the matching Python ``_pb2.py`` modules for a controller-side
consumer, from the *same* PROTOS/INCLUDE_DIRS arguments.

Nanopb code generation is a two-stage pipeline, not a choice between
"python" or "protobuf":

1. ``nanopb_generator.py`` (a Python script, distributed via the ``nanopb``
   PyPI package or a source checkout's ``generator/`` folder) shells out to
   ``protoc`` (the standard protobuf compiler - needs to be installed
   locally) to turn your ``.proto`` into a ``FileDescriptorSet``.
2. It then walks that descriptor in Python to emit ``<name>.pb.c`` /
   ``<name>.pb.h`` in nanopb's own lightweight format.

``protoc``'s built-in C++/Python generators instead emit full libprotobuf
code, which is a different, much heavier runtime and is NOT compatible with
nanopb's ``pb_encode.c`` / ``pb_decode.c``. So both protoc and Python3 are
required dependencies here - install protoc via your package manager, and
the generator via ``pip install nanopb``.

This module depends on ``find_python_module`` from FindPythonModule.cmake.

Requires (call before using):

.. code-block:: cmake

  cmake_minimum_required(VERSION 3.23) # FILE_SET requires 3.23+
  find_package(Python3 REQUIRED COMPONENTS Interpreter)
  find_python_module(nanopb REQUIRED)      # for add_nanopb_library
  find_python_module(grpc_tools REQUIRED)  # for add_python_proto_library

Both functions take the same ``PROTOS``/``INCLUDE_DIRS`` shape.
``INCLUDE_DIRS`` is the proto-path root (matching protoc's ``--proto_path``);
``PROTOS`` entries are paths *relative to one of those roots*. Every proto
file is resolved by searching ``INCLUDE_DIRS`` in order, and all
``INCLUDE_DIRS`` are passed as ``-I``/``--proto_path`` so that cross-file
``import "..."`` statements between your protos resolve correctly. Output
layout mirrors the proto's path relative to its include root, e.g.
``common/v1/common.proto`` -> ``<OUT_DIR>/common/v1/common.pb.c`` (and the
equivalent ``_pb2.py``), so generated ``#include``/``import`` statements
between your own generated files line up automatically.

Example - device (nanopb) and controller (python) from the same protos:

.. code-block:: cmake

  add_nanopb_library(ctrl_fw_nanopb
    PROTOS
      common/v1/common.proto
      services/v1/services.proto
      settings/v1/settings.proto
    INCLUDE_DIRS
      ${CMAKE_CURRENT_SOURCE_DIR}/proto
  )
  target_link_libraries(ctrl_fw PRIVATE ctrl_fw_nanopb)

  add_python_proto_library(ctrl_fw_python_proto
    PROTOS
      common/v1/common.proto
      services/v1/services.proto
      settings/v1/settings.proto
    INCLUDE_DIRS
      ${CMAKE_CURRENT_SOURCE_DIR}/proto
    OUT_DIR
      ${CMAKE_CURRENT_SOURCE_DIR}/python_proto
  )

Notes:

- Drop an optional ``foo.options`` file next to ``foo.proto`` (same base
  name) for nanopb field customization; the generator picks it up
  automatically, no need to reference it explicitly.
- Set ``NANOPB_SRC_ROOT_FOLDER`` to a local nanopb checkout to use that
  instead of the pip-installed package (e.g. for a pinned/vendored version).
- The nanopb runtime (pb.h/pb_common/pb_encode/pb_decode) is built exactly
  once as a shared static library target, no matter how many times
  ``add_nanopb_library`` is called. Every generated proto library links
  against it publicly, so consumers only need to link their proto library -
  the runtime comes along transitively.
- Override the shared runtime target's name with ``NANOPB_CORE_LIBRARY_TARGET``
  if ``nanopb`` collides with something else in your tree.
- ``add_python_proto_library`` generates ALL of its PROTOS in a single
  ``protoc`` invocation (one custom command, one target) rather than one
  call per file - it either regenerates the whole set or none of it, which
  matches running the equivalent hand-typed protoc commands together.
- ``add_python_proto_library`` also drops empty ``__init__.py`` files into
  every generated package directory so the output is importable as a
  regular package even on toolchains that don't honor PEP 420 implicit
  namespace packages.
- ``add_python_proto_library`` generates via ``python -m grpc_tools.protoc``
  (from the ``grpcio-tools`` pip package) rather than the system ``protoc``
  used by ``add_nanopb_library``. ``grpcio-tools`` bundles its own protoc
  build matched to whatever ``protobuf`` runtime version pip installs
  alongside it, so as long as the controller's venv installs
  ``grpcio-tools``/``protobuf`` together (e.g. both pinned in the same
  requirements file), generated code and runtime stay in lockstep
  automatically - no separate system protoc version to track for this half.

#]=======================================================================]

# Resolves `proto` (a path relative to one of `include_dirs`) against each
# include dir in turn and returns the matching include dir (not the full
# path) in `out_var`, or an empty string if none match. Mirrors how protoc
# itself resolves --proto_path entries. Not intended to be called directly.
function(_proto_resolve_include_dir out_var proto)
	foreach(_inc ${ARGN})
		get_filename_component(_inc_abs "${_inc}" ABSOLUTE)
		if(EXISTS "${_inc_abs}/${proto}")
			set(${out_var} "${_inc_abs}" PARENT_SCOPE)
			return()
		endif()
	endforeach()
	set(${out_var} "" PARENT_SCOPE)
endfunction(_proto_resolve_include_dir)

function(add_nanopb_library target)

	if(NOT DEFINED Python3_EXECUTABLE)
		message(FATAL_ERROR "Python not defined, use `find_package(Python3 ... REQUIRED COMPONENTS Interpreter)")
	endif()

	set(_options "")
	set(_one_value_args OUT_DIR)
	set(_multi_value_args PROTOS INCLUDE_DIRS)
	cmake_parse_arguments(_args
	                      "${_options}"
	                      "${_one_value_args}"
	                      "${_multi_value_args}"
	                      ${ARGN})

	if(NOT _args_PROTOS)
		message(FATAL_ERROR "add_nanopb_library(${target}): PROTOS requires at least one .proto file")
	endif()
	if(NOT _args_INCLUDE_DIRS)
		message(FATAL_ERROR "add_nanopb_library(${target}): INCLUDE_DIRS (proto-path root(s)) is required")
	endif()

	# protoc is required by the nanopb generator itself (step 1 of codegen).
	if(NOT Protobuf_PROTOC_EXECUTABLE)
		find_program(Protobuf_PROTOC_EXECUTABLE NAMES protoc)
	endif()
	if(NOT Protobuf_PROTOC_EXECUTABLE)
		message(FATAL_ERROR "add_nanopb_library(${target}): protoc not found - install a protobuf compiler "
		                     "or set Protobuf_PROTOC_EXECUTABLE")
	endif()

	# Locate the nanopb generator: prefer the pip-installed `nanopb` package,
	# fall back to a local checkout via NANOPB_SRC_ROOT_FOLDER.
	execute_process(
		COMMAND "${Python3_EXECUTABLE}" "-c"
		        "import nanopb, os; print(os.path.dirname(nanopb.__file__))"
		RESULT_VARIABLE _nanopb_pkg_status
		OUTPUT_VARIABLE _nanopb_pkg_dir
		ERROR_QUIET
		OUTPUT_STRIP_TRAILING_WHITESPACE
	)

	if(NOT _nanopb_pkg_status AND _nanopb_pkg_dir)
		set(_nanopb_generator "${_nanopb_pkg_dir}/generator/nanopb_generator.py")
		set(_nanopb_core_dir "${_nanopb_pkg_dir}")
	elseif(NANOPB_SRC_ROOT_FOLDER)
		set(_nanopb_generator "${NANOPB_SRC_ROOT_FOLDER}/generator/nanopb_generator.py")
		set(_nanopb_core_dir "${NANOPB_SRC_ROOT_FOLDER}")
	else()
		message(FATAL_ERROR "add_nanopb_library(${target}): could not locate the nanopb python package. "
		                     "Run `pip install nanopb`, or set NANOPB_SRC_ROOT_FOLDER to a nanopb checkout.")
	endif()

	if(NOT EXISTS "${_nanopb_generator}")
		message(FATAL_ERROR "add_nanopb_library(${target}): generator script not found at ${_nanopb_generator}")
	endif()

  if(NOT NANOPB_CORE_LIBRARY_TARGET)
    set(NANOPB_CORE_LIBRARY_TARGET protobuf-nanopb-static)
  endif()
  if(NOT TARGET ${NANOPB_CORE_LIBRARY_TARGET})
    message(FATAL_ERROR "add_nanopb_library(${target}): could not locate nanopb library '${NANOPB_CORE_LIBRARY_TARGET}'. "
                        "Ensure a the CMakeLists.txt contains some form of:\n"
                        "\tFetchContent_Declare( nanopb \n"
                        "\t  GIT_REPOSITORY https://github.com/nanopb/nanopb.git) \n"
                        "\tFetchContent_MakeAvailable(nanopb)")
  endif()

	if(NOT _args_OUT_DIR)
		set(_args_OUT_DIR "${CMAKE_CURRENT_BINARY_DIR}/nanopb/${target}")
	endif()
	file(MAKE_DIRECTORY "${_args_OUT_DIR}")

	set(_generated_sources "")
	set(_generated_headers "")

	# All include dirs must be passed to the generator as -I, not just the
	# individual proto's own directory - otherwise a proto that imports
	# another (e.g. settings.proto importing common/v1/common.proto) will
	# fail to resolve that import.
	set(_proto_include_flags "")
	foreach(_inc ${_args_INCLUDE_DIRS})
		get_filename_component(_inc_abs "${_inc}" ABSOLUTE)
		list(APPEND _proto_include_flags "-I${_inc_abs}")
	endforeach()

	foreach(_proto ${_args_PROTOS})
		_proto_resolve_include_dir(_proto_incdir "${_proto}" ${_args_INCLUDE_DIRS})
		if(NOT _proto_incdir)
			message(FATAL_ERROR "add_nanopb_library(${target}): could not find '${_proto}' under any INCLUDE_DIRS")
		endif()
		set(_proto_abs "${_proto_incdir}/${_proto}")

		get_filename_component(_rel_dir "${_proto}" DIRECTORY)
		get_filename_component(_proto_we "${_proto}" NAME_WE)

		set(_out_subdir "${_args_OUT_DIR}")
		if(_rel_dir)
			set(_out_subdir "${_args_OUT_DIR}/${_rel_dir}")
		endif()
		file(MAKE_DIRECTORY "${_out_subdir}")

		set(_out_c "${_out_subdir}/${_proto_we}.pb.c")
		set(_out_h "${_out_subdir}/${_proto_we}.pb.h")

		add_custom_command(
			OUTPUT "${_out_c}" "${_out_h}"
			COMMAND "${Python3_EXECUTABLE}" "${_nanopb_generator}"
			        ${_proto_include_flags}
			        "-D${_args_OUT_DIR}"
			        "${_proto_abs}"
			DEPENDS "${_proto_abs}" "${_nanopb_generator}"
			WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
			COMMENT "Generating nanopb sources for ${_proto}"
			VERBATIM
		)

		list(APPEND _generated_sources "${_out_c}")
		list(APPEND _generated_headers "${_out_h}")
	endforeach()

	add_custom_target(${target}_generate DEPENDS ${_generated_sources} ${_generated_headers})

	add_library(${target} STATIC)

	target_sources(${target}
		PUBLIC
			FILE_SET HEADERS
			BASE_DIRS
				"${_args_OUT_DIR}"
				${_args_INCLUDE_DIRS}
			FILES
				${_generated_headers}
		PRIVATE
			${_generated_sources}
	)

	# Runtime (pb_common/pb_encode/pb_decode) is shared across all
	# add_nanopb_library() targets - see _nanopb_add_core_library().
	target_link_libraries(${target} PUBLIC ${NANOPB_CORE_LIBRARY_TARGET})

  target_compile_options(${target}
    PUBLIC
      $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-padded>
      $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-missing-variable-declarations>
      $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-reserved-identifier>
  )


endfunction(add_nanopb_library)

# Generates Python protobuf modules (`<name>_pb2.py`) for the same set of
# .proto files, for a controller/host-side Python consumer. Unlike
# add_nanopb_library, this creates no C library - just a custom target that
# produces the generated .py tree, built as part of ALL.
function(add_python_proto_library target)

	if(NOT DEFINED Python3_EXECUTABLE)
		message(FATAL_ERROR "Python not defined, use `find_package(Python3 ... REQUIRED COMPONENTS Interpreter)")
	endif()

	set(_options "")
	set(_one_value_args OUT_DIR)
	set(_multi_value_args PROTOS INCLUDE_DIRS)
	cmake_parse_arguments(_args
	                      "${_options}"
	                      "${_one_value_args}"
	                      "${_multi_value_args}"
	                      ${ARGN})

	if(NOT _args_PROTOS)
		message(FATAL_ERROR "add_python_proto_library(${target}): PROTOS requires at least one .proto file")
	endif()
	if(NOT _args_INCLUDE_DIRS)
		message(FATAL_ERROR "add_python_proto_library(${target}): INCLUDE_DIRS (proto-path root(s)) is required")
	endif()

	# grpc_tools.protoc bundles its own protoc build matched to whatever
	# protobuf runtime pip installed alongside grpcio-tools, so gencode and
	# runtime stay in lockstep without tracking a separate system protoc.
	execute_process(
		COMMAND "${Python3_EXECUTABLE}" "-c" "import grpc_tools.protoc"
		RESULT_VARIABLE _grpc_tools_status
		OUTPUT_QUIET
		ERROR_QUIET
	)
	if(_grpc_tools_status)
		message(FATAL_ERROR "add_python_proto_library(${target}): grpc_tools.protoc not importable - "
		                     "run `pip install grpcio-tools`")
	endif()

	if(NOT _args_OUT_DIR)
		set(_args_OUT_DIR "${CMAKE_CURRENT_SOURCE_DIR}/python_proto")
	endif()
	file(MAKE_DIRECTORY "${_args_OUT_DIR}")

	set(_proto_include_flags "")
	foreach(_inc ${_args_INCLUDE_DIRS})
		get_filename_component(_inc_abs "${_inc}" ABSOLUTE)
		list(APPEND _proto_include_flags "--proto_path=${_inc_abs}")
	endforeach()

	set(_proto_abs_list "")
	set(_generated_py "")
	set(_package_dirs "")

	foreach(_proto ${_args_PROTOS})
		_proto_resolve_include_dir(_proto_incdir "${_proto}" ${_args_INCLUDE_DIRS})
		if(NOT _proto_incdir)
			message(FATAL_ERROR "add_python_proto_library(${target}): could not find '${_proto}' under any INCLUDE_DIRS")
		endif()
		set(_proto_abs "${_proto_incdir}/${_proto}")
		list(APPEND _proto_abs_list "${_proto_abs}")

		get_filename_component(_rel_dir "${_proto}" DIRECTORY)
		get_filename_component(_proto_we "${_proto}" NAME_WE)

		set(_out_subdir "${_args_OUT_DIR}")
		if(_rel_dir)
			# Accumulate every intermediate package dir (common, common/v1, ...)
			# so __init__.py can be dropped at each level below, not just the leaf.
			string(REPLACE "/" ";" _rel_parts "${_rel_dir}")
			foreach(_part ${_rel_parts})
				set(_out_subdir "${_out_subdir}/${_part}")
				list(APPEND _package_dirs "${_out_subdir}")
			endforeach()
		endif()
		file(MAKE_DIRECTORY "${_out_subdir}")

		list(APPEND _generated_py "${_out_subdir}/${_proto_we}_pb2.py")
	endforeach()

	# One invocation for the whole set - either regenerates everything
	# together or nothing, same as running the equivalent hand-typed
	# protoc commands as a batch.
	add_custom_command(
		OUTPUT ${_generated_py}
		COMMAND "${Python3_EXECUTABLE}" -m grpc_tools.protoc
		        ${_proto_include_flags}
		        "--python_out=${_args_OUT_DIR}"
		        ${_proto_abs_list}
		DEPENDS ${_proto_abs_list}
		WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
		COMMENT "Generating python protobuf modules for ${target}"
		VERBATIM
	)

	list(REMOVE_DUPLICATES _package_dirs)
	foreach(_dir ${_package_dirs} "${_args_OUT_DIR}")
		if(NOT EXISTS "${_dir}/__init__.py")
			file(WRITE "${_dir}/__init__.py" "")
		endif()
	endforeach()

	add_custom_target(${target} ALL DEPENDS ${_generated_py})

endfunction(add_python_proto_library)
