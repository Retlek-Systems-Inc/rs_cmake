# @copyright 2022-2024 Retlek Systems Inc.
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

# Add the Coverage configuration type
# TODO(phelter): Add coverage setup for clang as well - not there yet.
if (CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    AddConfiguration( CONFIG Coverage
        BASE_CONFIG Debug
        COMPILE_FLAGS
            -fprofile-arcs
            -ftest-coverage
            -fprofile-update=atomic
            --coverage
        LINKER_FLAGS
            -fprofile-arcs
            -ftest-coverage
            -fprofile-update=atomic
            --coverage
    )
# elseif(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    # AddConfiguration( CONFIG Coverage
    #     BASE_CONFIG Debug
    #     COMPILE_FLAGS
    #         -fprofile-instr-generate
    #         -fcoverage-mapping
    #         -fprofile-update=atomic
    #         --coverage
    #     LINKER_FLAGS
    #         -fprofile-instr-generate
    #         -fcoverage-mapping
    #         -fprofile-update=atomic
    #         --coverage
    # )
else()
    message(STATUS "Coverage configuration not supported with compiler: ${CMAKE_CXX_COMPILER_ID}")
endif()

get_property(isMultiConfig GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)
if(isMultiConfig)
    if (NOT "Coverage" IN_LIST CMAKE_CONFIGURATION_TYPES)
        message(WARNING "Coverage configuration not defined in configuration types. Use AddConfiguration.")
        return()
    endif()
else()
    set(isCoverageBuild "$<BOOL:$<CONFIG:Coverage>")
    if (NOT isCoverageBuild)
        # Not a multi-config and not a coverage build so don't bother adding these.
        return()
    endif()
endif()


# Define the custom command to delete profiling data files
if (NOT TARGET CoverageClean)
    add_custom_command(
        OUTPUT ${CMAKE_BINARY_DIR}/coverage_clean_stamp
        COMMAND ${CMAKE_COMMAND} -E echo "Deleting profiling data files..."
        COMMAND find ${CMAKE_BINARY_DIR} -type f -name '*.gcda' -delete
        COMMAND find ${CMAKE_BINARY_DIR} -type f -name '*.gcno' -delete
        COMMAND ${CMAKE_COMMAND} -E touch ${CMAKE_BINARY_DIR}/coverage_clean_stamp
        COMMENT "Cleaning up profiling data files"
    )

    # Define the custom target that depends on the custom command
    add_custom_target( CoverageClean
        DEPENDS ${CMAKE_BINARY_DIR}/coverage_clean_stamp
        COMMENT "Custom target to clean coverage profiling data files"
    )
endif()

# TODO(phelter): Figure out how to do the code-coverage target just for the Coverage build.

# Detect the coverage version to use:
execute_process(
    COMMAND ${CMAKE_CXX_COMPILER} -dumpversion
    OUTPUT_VARIABLE GNU_VER
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

# Check prereqs
find_program(GCOV_PATH
             NAMES gcov-${GNU_VER}
                   ${CMAKE_SOURCE_DIR}/tests/llvm-gcov.sh 
                   gcov
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
    message(WARNING "gcov not found! No Coverage targets generated...")
    # return()
endif() # NOT GCOV_PATH

if("${CMAKE_CXX_COMPILER_ID}" MATCHES "(Apple)?[Cc]lang")
  if("${CMAKE_CXX_COMPILER_VERSION}" VERSION_LESS 3)
    message(FATAL_ERROR "Clang version must be 3.0.0 or greater! Aborting...")
  endif()
elseif(NOT ${CMAKE_CXX_COMPILER_ID} MATCHES "GNU")
  message(STATUS "CMAKE_CXX_COMPILER_ID = ${CMAKE_CXX_COMPILER_ID}")
  message(FATAL_ERROR "Compiler is not GNU gcc! Aborting...")
endif()


link_libraries(
    $<$<AND:$<C_COMPILER_ID:GNU>,$<CONFIG:Coverage>>:gcov>
)

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
    message(WARNING "lcov not found! No Coverage targets generated...")
    return()
  endif() # NOT LCOV_PATH

  if(NOT GENHTML_PATH)
    message(WARNING "genhtml not found! No Coverage targets generated...")
    return()
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

  # Show where to find the lcov info report and web reports
  add_custom_command(
    TARGET ${Coverage_NAME} POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E echo "Lcov code coverage info report saved in ${Coverage_NAME}.info.cleaned"
    COMMAND ${CMAKE_COMMAND} -E echo "Open ./${Coverage_NAME}/index.html in your browser to view the coverage report."
    COMMENT
      "Lcov code coverage report: ${Coverage_NAME}.info.cleaned, web: ./${Coverage_NAME}/index.html ")

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
    message(WARNING "lcov not found! No Coverage targets generated...")
    return()
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
    message(WARNING "python not found! No Coverage targets generated...")
    return()
  endif() # NOT SIMPLE_PYTHON_EXECUTABLE

  if(NOT GCOVR_PATH)
    message(WARNING "gcovr not found! No Coverage targets generated...")
    return()
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
    message(WARNING "python not found! No Coverage targets generated...")
    return()
  endif() # NOT SIMPLE_PYTHON_EXECUTABLE

  if(NOT GCOVR_PATH)
    message(WARNING "gcovr not found! No Coverage targets generated...")
    return()
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
