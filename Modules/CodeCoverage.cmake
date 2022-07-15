# @copyright 2022 Retlek Systems Inc.
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
#
# Based on:
# https://github.com/navarrothiago/test-ci/blob/3618332452374401b29c49f80ddddf059ddcdc1f/cmake/Coverage.cmake
# https://github.com/lugt/algorithms-tester/blob/6fb0ae34584695486f98604790a5fc5b26e12eb7/cmake/CodeCoverage.cmake

#
# CMake module that detects if the compilers support coverage
#
# If this is the case, the build type Coverage is set up for coverage, and COVERAGE_SUPPORTED is set to true.
# By default the Coverage build type is added to CMAKE_CONFIGURATION_TYPES on multi-config generators.
# This can be controlled through the COVERAGE_IN_CONFIGURATION_TYPES option.
#
# USAGE:
#
# 1. Copy this file into your cmake modules path.
#
# 1. Add the following line to your CMakeLists.txt: include(CodeCoverage)
#
# 1. If you need to exclude additional directories from the report, specify them
#   using the COVERAGE_LCOV_EXCLUDES variable before calling
#   SETUP_TARGET_FOR_COVERAGE_LCOV. Example: set(COVERAGE_LCOV_EXCLUDES 'dir1/*'
#   'dir2/*')
#
# 1. Use the functions described below to create a custom make target which runs
#   your test executable and produces a code coverage report.
#
# 1. Build a Debug build: cmake -DCMAKE_BUILD_TYPE=Debug .. make make
#   my_coverage_target
#

include(CMakeParseArguments)
include(CMakeDependentOption)

set(COVERAGE_COMPILER_FLAGS  "-g -O0 --coverage" CACHE INTERNAL "")
set(COVERAGE_LINKER_FLAGS    "--coverage"        CACHE INTERNAL "")

get_property(enabledLanguages GLOBAL PROPERTY ENABLED_LANGUAGES)

foreach(_LANG IN LISTS enabledLanguages)
	include(Check${_LANG}CompilerFlag OPTIONAL)
	set(CMAKE_REQUIRED_LIBRARIES ${COVERAGE_LINKER_FLAGS}) # This is ugly, but better than rewriting/fixing check_<LANG>_compiler_flag

	if(_LANG STREQUAL "C")
		check_c_compiler_flag("--coverage" ${_LANG}_COVERAGE_SUPPORTED)
	elseif(_LANG STREQUAL "CXX")
		check_cxx_compiler_flag("--coverage" ${_LANG}_COVERAGE_SUPPORTED)
	else()
		if(DEFINED ${_LANG}_COVERAGE_SUPPORTED)
			message(STATUS "Skipping ${_LANG}, not supported by Coverage.cmake script")
		endif()
		set(${_LANG}_COVERAGE_SUPPORTED FALSE)
		continue()
	endif()
	if(${_LANG}_COVERAGE_SUPPORTED)
		set(CMAKE_${_LANG}_FLAGS_COVERAGE
			${COVERAGE_COMPILER_FLAGS}
			CACHE STRING "Flags used by the ${_LANG} compiler during coverage builds."
		)
		mark_as_advanced(CMAKE_${_LANG}_FLAGS_COVERAGE)
		set(COVERAGE_SUPPORTED TRUE CACHE INTERNAL "Whether or not coverage is supported by at least one compiler.")
	endif()
endforeach()

if(COVERAGE_SUPPORTED)
	set(CMAKE_EXE_LINKER_FLAGS_COVERAGE
		"${COVERAGE_LINKER_FLAGS}"
		CACHE STRING "Flags used for linking binaries during coverage builds."
	)
	set(CMAKE_SHARED_LINKER_FLAGS_COVERAGE
		"${COVERAGE_LINKER_FLAGS}"
		CACHE STRING "Flags used by the shared libraries linker during coverage builds."
	)
	mark_as_advanced(
		CMAKE_EXE_LINKER_FLAGS_COVERAGE
		CMAKE_SHARED_LINKER_FLAGS_COVERAGE
	)
endif()


get_property(isMultiConfig GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)
if (isMultiConfig)
    if (NOT "Coverage" IN_LIST CMAKE_CONFIGURATION_TYPES)
        list(APPEND CMAKE_CONFIGURATION_TYPES Coverage)
    endif()
endif()

if(isMultiConfig)
	# Modify this only if using a multi-config generator, some modules rely on this variable to detect those generators.
    if (COVERAGE_SUPPORTED AND NOT "Coverage" IN_LIST CMAKE_CONFIGURATION_TYPES)
        list(APPEND CMAKE_CONFIGURATION_TYPES Coverage)
    elseif( NOT COVERAGE_SUPPORTED AND "Coverage" IN_LIST CMAKE_CONFIGURATION_TYPES)
        list(REMOVE_DUPLICATES CMAKE_CONFIGURATION_TYPES)
        list(REMOVE_ITEM CMAKE_CONFIGURATION_TYPES Coverage)
    endif()
endif()

# Check prereqs
find_program(GCOV_PATH
             NAMES ${CMAKE_SOURCE_DIR}/tests/llvm-gcov.sh gcov
             PATHS ENV PATH)
find_program(LCOV_PATH
             NAMES lcov
                   lcov.bat
                   lcov.exe
                   lcov.perl
             PATHS ENV PATH)
find_program(LLVM_COV_PATH
             NAMES
                   llvm-cov110
                   llvm-cov-11
                   llvm-cov100
                   llvm-cov-10
                   llvm-cov90
                   llvm-cov-9
                   llvm-cov80
                   llvm-cov-8
                   llvm-cov70
                   llvm-cov-7
                   llvm-cov
             PATHS ENV PATH)
find_program(LLVM_PROFDATA_PATH
             NAMES
                   llvm-profdata110
                   llvm-profdata-11
                   llvm-profdata100
                   llvm-profdata-10
                   llvm-profdata90
                   llvm-profdata-9
                   llvm-profdata80
                   llvm-profdata-8
                   llvm-profdata70
                   llvm-profdata-7
                   llvm-profdata
             PATHS ENV PATH)
find_program(GENHTML_PATH NAMES genhtml genhtml.perl genhtml.bat)
find_program(GCOVR_PATH gcovr PATHS ${CMAKE_SOURCE_DIR}/scripts/test)
find_program(SIMPLE_PYTHON_EXECUTABLE python)

if(NOT GCOV_PATH)
  message(FATAL_ERROR "gcov not found! Aborting...")
endif() # NOT GCOV_PATH

if("${CMAKE_CXX_COMPILER_ID}" MATCHES "(Apple)?[Cc]lang")
  if("${CMAKE_CXX_COMPILER_VERSION}" VERSION_LESS 3)
    message(FATAL_ERROR "Clang version must be 3.0.0 or greater! Aborting...")
  endif()
elseif(NOT ${CMAKE_CXX_COMPILER_ID} MATCHES "GNU")
  message(STATUS "CMAKE_CXX_COMPILER_ID = ${CMAKE_CXX_COMPILER_ID}")
  message(FATAL_ERROR "Compiler is not GNU gcc! Aborting...")
endif()


if(CMAKE_C_COMPILER_ID STREQUAL "GNU")
  link_libraries(gcov)
# else()
#   set(CMAKE_EXE_LINKER_FLAGS
#       "${CMAKE_EXE_LINKER_FLAGS} -fprofile-instr-generate")
endif()

# Defines a target for running and collection code coverage information Builds
# dependencies, runs the given executable and outputs reports. NOTE! The
# executable should always have a ZERO as exit code otherwise the coverage
# generation will not complete.
#
# SETUP_TARGET_FOR_COVERAGE_LCOV_HTML( NAME testrunner_coverage # New target
# name EXECUTABLE testrunner -j ${PROCESSOR_COUNT} # Executable in
# PROJECT_BINARY_DIR DEPENDENCIES testrunner                     # Dependencies
# to build first )
function(SETUP_TARGET_FOR_COVERAGE_LCOV_HTML)

  set(options NONE)
  set(oneValueArgs NAME)
  set(multiValueArgs
      EXECUTABLE
      EXECUTABLE_ARGS
      DEPENDENCIES
      LCOV_ARGS
      GENHTML_ARGS)
  cmake_parse_arguments(Coverage
                        "${options}"
                        "${oneValueArgs}"
                        "${multiValueArgs}"
                        ${ARGN})

  if(NOT LCOV_PATH)
    message(FATAL_ERROR "lcov not found! Aborting...")
  endif() # NOT LCOV_PATH

  if(NOT GENHTML_PATH)
    message(FATAL_ERROR "genhtml not found! Aborting...")
  endif() # NOT GENHTML_PATH

  # Setup target
  add_custom_target(
    ${Coverage_NAME}
    # Cleanup lcov
    COMMAND ${LCOV_PATH} ${Coverage_LCOV_ARGS}
            --gcov-tool ${GCOV_PATH} -directory .
            --zerocounters # Create baseline to make sure untouched files show
                           # up in the report
    COMMAND ${LCOV_PATH} ${Coverage_LCOV_ARGS}
            --gcov-tool ${GCOV_PATH} -c -i -d . -o ${Coverage_NAME}.base
                        # Run tests
    COMMAND ${Coverage_EXECUTABLE} ${Coverage_EXECUTABLE_ARGS}
            # Capturing lcov counters and generating report
    COMMAND ${LCOV_PATH} ${Coverage_LCOV_ARGS}
            --gcov-tool ${GCOV_PATH}
            --directory .
            --capture
            --output-file ${Coverage_NAME}.info
                          # add baseline counters
    COMMAND ${LCOV_PATH} ${Coverage_LCOV_ARGS}
            --gcov-tool ${GCOV_PATH} -a ${Coverage_NAME}.base -a
                        ${Coverage_NAME}.info
            --output-file ${Coverage_NAME}.total
    COMMAND ${LCOV_PATH} ${Coverage_LCOV_ARGS}
            --gcov-tool ${GCOV_PATH}
            --remove ${Coverage_NAME}.total ${COVERAGE_LCOV_EXCLUDES}
            --output-file ${PROJECT_BINARY_DIR}/${Coverage_NAME}.info.cleaned
                          # Generate HTML
    COMMAND ${GENHTML_PATH} ${Coverage_GENHTML_ARGS} -o ${Coverage_NAME}
            ${PROJECT_BINARY_DIR}/${Coverage_NAME}.info.cleaned
            # Clean up
    COMMAND ${CMAKE_COMMAND} -E remove ${Coverage_NAME}.base
            ${Coverage_NAME}.total ${PROJECT_BINARY_DIR}/${Coverage_NAME}.info
    WORKING_DIRECTORY ${PROJECT_BINARY_DIR}
    DEPENDS ${Coverage_DEPENDENCIES}
    COMMENT
      "Resetting code coverage counters to zero.\nProcessing code coverage counters and generating report."
    )

  # Show where to find the lcov info report
  add_custom_command(
    TARGET ${Coverage_NAME} POST_BUILD
    COMMAND ;
    COMMENT
      "Lcov code coverage info report saved in ${Coverage_NAME}.info.cleaned")

  # Show info where to find the report
  add_custom_command(
    TARGET ${Coverage_NAME} POST_BUILD
    COMMAND ;
    COMMENT
      "Open ./${Coverage_NAME}/index.html in your browser to view the coverage report."
    )

endfunction() # SETUP_TARGET_FOR_COVERAGE_LCOV_HTML

# Defines a target for running and collection code coverage information Builds
# dependencies, runs the given executable and outputs reports. NOTE! The
# executable should always have a ZERO as exit code otherwise the coverage
# generation will not complete.
#
# SETUP_TARGET_FOR_COVERAGE_LCOV_TXT( NAME testrunner_coverage # New target name
# EXECUTABLE testrunner -j ${PROCESSOR_COUNT} # Executable in PROJECT_BINARY_DIR
# DEPENDENCIES testrunner                     # Dependencies to build first )
function(SETUP_TARGET_FOR_COVERAGE_LCOV_TXT)

  set(options NONE)
  set(oneValueArgs NAME)
  set(multiValueArgs
      EXECUTABLE
      EXECUTABLE_ARGS
      DEPENDENCIES
      LCOV_ARGS
      GENHTML_ARGS)
  cmake_parse_arguments(Coverage
                        "${options}"
                        "${oneValueArgs}"
                        "${multiValueArgs}"
                        ${ARGN})

  if(NOT LCOV_PATH)
    message(FATAL_ERROR "lcov not found! Aborting...")
  endif() # NOT LCOV_PATH

  # Setup target
  add_custom_target(
    ${Coverage_NAME}
    # Run tests
    COMMAND ${Coverage_EXECUTABLE} ${Coverage_EXECUTABLE_ARGS}
            # Generate coverage.txt for sonar
    COMMAND ${LLVM_PROFDATA_PATH} merge default.profraw -output
            ${Coverage_NAME}.profdata
    COMMAND ${LLVM_COV_PATH} show -instr-profile=${Coverage_NAME}.profdata
            ${CMAKE_CURRENT_BINARY_DIR}/${Coverage_EXECUTABLE} >
            ${Coverage_NAME}.txt
            # Generate HTML
            # Clean up
    COMMAND ${CMAKE_COMMAND} -E remove ${Coverage_NAME}.profdata default.profraw
    WORKING_DIRECTORY ${PROJECT_BINARY_DIR}
    DEPENDS ${Coverage_DEPENDENCIES}
    COMMENT
      "Resetting code coverage counters to zero.\nProcessing code coverage counters and generating report."
    )

  # Show where to find the lcov info report
  add_custom_command(
    TARGET ${Coverage_NAME} POST_BUILD
    COMMAND ;
    COMMENT "Lcov code coverage info report saved in ${Coverage_NAME}.txt.")

endfunction() # SETUP_TARGET_FOR_COVERAGE_LCOV_TXT

# Defines a target for running and collection code coverage information Builds
# dependencies, runs the given executable and outputs reports. NOTE! The
# executable should always have a ZERO as exit code otherwise the coverage
# generation will not complete.
#
# SETUP_TARGET_FOR_COVERAGE_GCOVR_XML( NAME ctest_coverage                    #
# New target name EXECUTABLE ctest -j ${PROCESSOR_COUNT} # Executable in
# PROJECT_BINARY_DIR DEPENDENCIES executable_target         # Dependencies to
# build first )
function(SETUP_TARGET_FOR_COVERAGE_GCOVR_XML)

  set(options NONE)
  set(oneValueArgs NAME)
  set(multiValueArgs EXECUTABLE EXECUTABLE_ARGS DEPENDENCIES)
  cmake_parse_arguments(Coverage
                        "${options}"
                        "${oneValueArgs}"
                        "${multiValueArgs}"
                        ${ARGN})

  if(NOT SIMPLE_PYTHON_EXECUTABLE)
    message(FATAL_ERROR "python not found! Aborting...")
  endif() # NOT SIMPLE_PYTHON_EXECUTABLE

  if(NOT GCOVR_PATH)
    message(FATAL_ERROR "gcovr not found! Aborting...")
  endif() # NOT GCOVR_PATH

  # Combine excludes to several -e arguments
  set(GCOVR_EXCLUDES "")
  foreach(EXCLUDE ${COVERAGE_GCOVR_EXCLUDES})
    list(APPEND GCOVR_EXCLUDES "-e")
    list(APPEND GCOVR_EXCLUDES "${EXCLUDE}")
  endforeach()

  add_custom_target(
    ${Coverage_NAME}
    # Run tests
    ${Coverage_EXECUTABLE} ${Coverage_EXECUTABLE_ARGS}
    # Running gcovr
    COMMAND ${GCOVR_PATH}
            --xml -r ${PROJECT_SOURCE_DIR} ${GCOVR_EXCLUDES}
            --object-directory=${PROJECT_BINARY_DIR} -o ${Coverage_NAME}.xml
    WORKING_DIRECTORY ${PROJECT_BINARY_DIR}
    DEPENDS ${Coverage_DEPENDENCIES}
    COMMENT "Running gcovr to produce Cobertura code coverage report.")

  # Show info where to find the report
  add_custom_command(
    TARGET ${Coverage_NAME} POST_BUILD
    COMMAND ;
    COMMENT "Cobertura code coverage report saved in ${Coverage_NAME}.xml.")

endfunction() # SETUP_TARGET_FOR_COVERAGE_GCOVR_XML

# Defines a target for running and collection code coverage information Builds
# dependencies, runs the given executable and outputs reports. NOTE! The
# executable should always have a ZERO as exit code otherwise the coverage
# generation will not complete.
#
# SETUP_TARGET_FOR_COVERAGE_GCOVR_HTML( NAME ctest_coverage                    #
# New target name EXECUTABLE ctest -j ${PROCESSOR_COUNT} # Executable in
# PROJECT_BINARY_DIR DEPENDENCIES executable_target         # Dependencies to
# build first )
function(SETUP_TARGET_FOR_COVERAGE_GCOVR_HTML)

  set(options NONE)
  set(oneValueArgs NAME)
  set(multiValueArgs EXECUTABLE EXECUTABLE_ARGS DEPENDENCIES)
  cmake_parse_arguments(Coverage
                        "${options}"
                        "${oneValueArgs}"
                        "${multiValueArgs}"
                        ${ARGN})

  if(NOT SIMPLE_PYTHON_EXECUTABLE)
    message(FATAL_ERROR "python not found! Aborting...")
  endif() # NOT SIMPLE_PYTHON_EXECUTABLE

  if(NOT GCOVR_PATH)
    message(FATAL_ERROR "gcovr not found! Aborting...")
  endif() # NOT GCOVR_PATH

  # Combine excludes to several -e arguments
  set(GCOVR_EXCLUDES "")
  foreach(EXCLUDE ${COVERAGE_GCOVR_EXCLUDES})
    list(APPEND GCOVR_EXCLUDES "-e")
    list(APPEND GCOVR_EXCLUDES "${EXCLUDE}")
  endforeach()

  add_custom_target(
    ${Coverage_NAME}
    # Run tests
    ${Coverage_EXECUTABLE} ${Coverage_EXECUTABLE_ARGS}
    # Create folder
    COMMAND ${CMAKE_COMMAND} -E make_directory
            ${PROJECT_BINARY_DIR}/${Coverage_NAME}
            # Running gcovr
    COMMAND ${GCOVR_PATH}
            --html
            --html-details -r ${PROJECT_SOURCE_DIR} ${GCOVR_EXCLUDES}
            --object-directory=${PROJECT_BINARY_DIR} -o
                                                     ${Coverage_NAME}/index.html
    WORKING_DIRECTORY ${PROJECT_BINARY_DIR}
    DEPENDS ${Coverage_DEPENDENCIES}
    COMMENT "Running gcovr to produce HTML code coverage report.")

  # Show info where to find the report
  add_custom_command(
    TARGET ${Coverage_NAME} POST_BUILD
    COMMAND ;
    COMMENT
      "Open ${CMAKE_CURRENT_BINARY_DIR}/${Coverage_NAME}/index.html in your browser to view the coverage report."
    )

endfunction() # SETUP_TARGET_FOR_COVERAGE_GCOVR_HTML

