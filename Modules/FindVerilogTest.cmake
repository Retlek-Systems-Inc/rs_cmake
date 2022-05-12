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
# add a target to generate API documentation with Doxygen

# Currently using verilator for testing.
if (VERILOG_TEST)
    find_package(verilator 4.2.2 REQUIRED
        HINTS
        /usr/local
        $ENV{VERILATOR_ROOT}
        ${VERILATOR_ROOT}
    )

    if (NOT verilator_FOUND)
        message(FATAL_ERROR "Verilator was not found. Either install it, or set the VERILATOR_ROOT environment variable")
        # Install instructions here: https://verilator.org/guide/latest/install.html
    endif()

    option(VERILATOR_ENABLE_SC "Enable System C" OFF)
    option(VERILATOR_THREADS   "Number of Threads"  0)
    if (NOT TARGET Verilator::base)
        # -----------------------------------------------------------------------------
        add_library(verilator_base STATIC)
        add_library(Verilator::base ALIAS verilator_base)

        set (_inc_dir ${verilator_DIR}/include)
        target_sources( verilator_base
          PRIVATE
            $<$<NOT:$<BOOL:${VERILATOR_ENABLE_SC}>>:${_inc_dir}/verilated.cpp>
            $<$<NOT:$<BOOL:${VERILATOR_ENABLE_SC}>>:${_inc_dir}/verilated.h>
            #${_inc_dir}/verilated.v
            ${_inc_dir}/verilated_config.h
            #${_inc_dir}/verilated_config.h.in
            ${_inc_dir}/verilated_cov.cpp
            ${_inc_dir}/verilated_cov.h
            ${_inc_dir}/verilated_cov_key.h
            ${_inc_dir}/verilated_dpi.cpp
            ${_inc_dir}/verilated_dpi.h
            $<$<NOT:$<BOOL:${VERILATOR_ENABLE_SC}>>:${_inc_dir}/verilated_fst_c.cpp>
            $<$<NOT:$<BOOL:${VERILATOR_ENABLE_SC}>>:${_inc_dir}/verilated_fst_c.h>
            $<$<BOOL:${VERILATOR_ENABLE_SC}>:${_inc_dir}/verilated_fst_sc.cpp>
            $<$<BOOL:${VERILATOR_ENABLE_SC}>:${_inc_dir}/verilated_fst_sc.h>
            ${_inc_dir}/verilated_funcs.h
            ${_inc_dir}/verilated_heavy.h
            ${_inc_dir}/verilated_imp.h
            ${_inc_dir}/verilated_intrinsics.h
            #${_inc_dir}/verilated_profiler.cpp
            #${_inc_dir}/verilated_profiler.h
            ${_inc_dir}/verilated_save.cpp
            ${_inc_dir}/verilated_save.h
            $<$<BOOL:${VERILATOR_ENABLE_SC}>:${_inc_dir}/verilated_sc.h>
            ${_inc_dir}/verilated_sym_props.h
            ${_inc_dir}/verilated_syms.h
            $<$<BOOL:${VERILATOR_THREADS}>:${_inc_dir}/verilated_threads.cpp>
            $<$<BOOL:${VERILATOR_THREADS}>:${_inc_dir}/verilated_threads.h>
            ${_inc_dir}/verilated_trace.h
            ${_inc_dir}/verilated_trace_defs.h
            #${_inc_dir}/verilated_trace_imp.cpp
            ${_inc_dir}/verilated_types.h
            ${_inc_dir}/verilated_vcd_c.cpp
            ${_inc_dir}/verilated_vcd_c.h
            $<$<BOOL:${VERILATOR_ENABLE_SC}>:${_inc_dir}/verilated_vcd_sc.cpp>
            $<$<BOOL:${VERILATOR_ENABLE_SC}>:${_inc_dir}/verilated_vcd_sc.h>
            ${_inc_dir}/verilated_vpi.cpp
            ${_inc_dir}/verilated_vpi.h
            ${_inc_dir}/verilatedos.h
        )

        # Ignored for Verilated info at this point in time
        target_compile_definitions( verilator_base
          PUBLIC
            VL_THREADED=$<BOOL:${VERILATOR_THREADS}>
            VM_SC=$<BOOL:${VERILATOR_ENABLE_SC}>
            VM_TRACE=1
        )

        target_compile_options( verilator_base
          PUBLIC
            $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-Wno-padded>
            $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-Wno-sign-conversion>
            $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-Wno-reserved-identifier>
            $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-Wno-old-style-cast>
            $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-Wno-cast-qual>
            $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-Wno-shorten-64-to-32>
            $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-Wno-implicit-int-conversion>
            $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-Wno-implicit-fallthrough>
            $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-Wno-thread-safety-negative>
            $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-Wno-zero-as-null-pointer-constant>
            $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-Wno-shift-sign-overflow>
            $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-Wno-deprecated-copy-with-dtor>
            $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-Wno-undefined-reinterpret-cast>
            $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-Wno-float-equal>
            $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-Wno-non-virtual-dtor>
            $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-Wno-weak-vtables>
            # Note following are in both private and generated code - putting here to include.
            $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-Wno-exit-time-destructors>
            $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-Wno-suggest-destructor-override>
            $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-Wno-thread-safety-attributes>
            $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-Wno-thread-safety-analysis>
            $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-Wno-used-but-marked-unused>
            $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-Wno-unreachable-code>
            $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-Wno-missing-prototypes>
            $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-Wno-missing-noreturn>
            $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-Wno-format-nonliteral>
            $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-Wno-double-promotion>
            $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-Wno-format-pedantic>
            $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-Wno-switch-enum>
            $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-Wno-implicit-int-float-conversion>
            $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-Wno-global-constructors>
            $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-Wno-conditional-uninitialized>

            $<$<COMPILE_LANG_AND_ID:CXX,GNU>:-Wno-aligned-new>
            # Note following are in generated code - putting here to include.
            $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-Wno-over-aligned>
            $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-Wno-undefined-func-template>
          PRIVATE
            $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-Wno-unused-macros>
            $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-Wno-covered-switch-default>
            $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-Wno-cast-align>
            $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-Wno-extra-semi-stmt>
            $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-Wno-shadow>
        )

        target_include_directories( verilator_base
            PUBLIC
            ${_inc_dir}
            ${_inc_dir}/gtkwave
            ${_inc_dir}/vltstd
        )
        unset(_inc_dir)

        target_link_libraries( verilator_base
            PUBLIC
            atomic # For some reason missing __atomic_is_lock_free definition.
        )
        if( VERILATOR_ENABLE_SC )
            verilator_link_systemc(verilator_base)
        endif()
    endif()


#------------------------------------------------------------------------------
    include(CMakeParseArguments)

    # Check prereqs
    find_program(VERILATOR_COVERAGE
        NAMES verilator_coverage
        PATHS
        $ENV{PATH}
        $ENV{VERILATOR_ROOT}
        ${VERILATOR_ROOT}
    )

    find_program(LCOV_PATH
        NAMES lcov
            lcov.bat
            lcov.exe
            lcov.perl
        PATHS $ENV{PATH}
    )

    find_program(GENHTML_PATH NAMES genhtml genhtml.perl genhtml.bat)

# Other options later:
#    FetchContent_Declare(
#      icarus 
#      GIT_REPOSITORY   https://github.com/steveicarus/iverilog.git
#      GIT_TAG          TBD
#    )
#    FetchContent_MakeAvailable(verilatorSource)
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
function(SETUP_VERILOG_TARGET_FOR_COVERAGE_LCOV_HTML)

  set(options NONE)
  set(oneValueArgs NAME)
  set(multiValueArgs
      EXECUTABLE
      EXECUTABLE_ARGS
      DATA_FILES
      DEPENDENCIES
      LCOV_ARGS
      GENHTML_ARGS)
  cmake_parse_arguments(Coverage
                        "${options}"
                        "${oneValueArgs}"
                        "${multiValueArgs}"
                        ${ARGN})

  if(NOT VERILATOR_COVERAGE)
    message(FATAL_ERROR "verilator_coverage not found, Aborting...")
  endif()

  if(NOT LCOV_PATH)
    message(FATAL_ERROR "lcov not found! Aborting...")
  endif() # NOT LCOV_PATH

  if(NOT GENHTML_PATH)
    message(FATAL_ERROR "genhtml not found! Aborting...")
  endif() # NOT GENHTML_PATH

  set(_verilog_merged_info verilog_merged.info)
  # Setup target
  add_custom_target(
    ${Coverage_NAME}

    # Remove all coverage files.
    COMMAND ${CMAKE_COMMAND} -E rm ${Coverage_DATA_FILES}
    # Cleanup lcov
    COMMAND ${LCOV_PATH} ${Coverage_LCOV_ARGS}
        -directory .
        --zerocounters
    # Create baseline to make sure untouched files show up in the report
    COMMAND ${LCOV_PATH} ${Coverage_LCOV_ARGS}
        -c -i -d . -o ${Coverage_NAME}.base
    # Run tests
    COMMAND ${Coverage_EXECUTABLE} ${Coverage_EXECUTABLE_ARGS}
    # Capturing lcov counters and generating report
    COMMAND ${VERILATOR_COVERAGE}
        --rank
        --write-info ${Coverage_NAME}.info
        ${Coverage_DATA_FILES}
    # add baseline counters
    COMMAND ${LCOV_PATH} ${Coverage_LCOV_ARGS}
        -a ${Coverage_NAME}.info
        --output-file ${Coverage_NAME}.total
    COMMAND ${LCOV_PATH} ${Coverage_LCOV_ARGS}
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

endfunction() # SETUP_VERILOG_TARGET_FOR_COVERAGE_LCOV_HTML


macro(setup_verilog_code_coverage_target)
    # Create a code coverage target.
    set(_coverageTarget verilog-code-coverage)

    # Hard code the data files to test directories within the repo for now.
    set(_coverageDataFiles ${CMAKE_BINARY_DIR}/*/test/*.data)

#    string(TOLOWER ${CMAKE_BUILD_TYPE} _buildType)
#    if ( ${_buildType} STREQUAL coverage AND NOT TARGET ${_coverageTarget} )
    if ( NOT TARGET ${_coverageTarget} )
        SETUP_VERILOG_TARGET_FOR_COVERAGE_LCOV_HTML(
            NAME ${_coverageTarget}
            EXECUTABLE ctest
            EXECUTABLE_ARGS ${CTEST_BUILD_FLAGS}
            DATA_FILES
                ${_coverageDataFiles}
            LCOV_ARGS
                --strip 1
#                --rc lcov_branch_coverage=1
            GENHTML_ARGS
#                --rc genhtml_branch_coverage=1
#                --demangle-cpp
                --prefix ${CMAKE_SOURCE_DIR}
        )
    endif()
endmacro()
