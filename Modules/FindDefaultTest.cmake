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

# Adds the necessary information for testing environment with googletest.
# Note googletest/googlemock are down-loaded into the build dir and compiled as part
# of the test environment from there.
if(BUILD_TEST)

    include(CodeCoverage)

    macro(setup_code_coverage_target)
        # Create a code coverage target.
        set(_coverageTarget code-coverage)
        # Exclude standard and test framework environment builds.
        list(APPEND COVERAGE_LCOV_EXCLUDES
            '/usr/include/*'
            '${googletest_SOURCE_DIR}/*'
        )
        message(STATUS "Coverage Excludes: ${COVERAGE_LCOV_EXCLUDES}")

        SETUP_TARGET_FOR_COVERAGE_LCOV_HTML(
            NAME ${_coverageTarget}
            EXECUTABLE ctest
            EXECUTABLE_ARGS ${CTEST_BUILD_FLAGS}
            LCOV_ARGS
                --strip 1
                --branch-coverage
                --function-coverage
                --ignore-errors mismatch
                --ignore-errors unused
            GENHTML_ARGS
                --rc genhtml_branch_coverage=1
                --demangle-cpp
                --prefix ${CMAKE_SOURCE_DIR}
        )
    endmacro()

    # Prevent overriding the parent project's compiler/linker
    # settings on Windows
    set(gtest_force_shared_crt ON CACHE BOOL "" FORCE) 

    include(FetchContent)
    FetchContent_MakeAvailable(googletest)

    # Add clang-tidy definition to include warnings/errors for googletest.
    # Clang-Tidy all file for gtest/gmock related code
    configure_file( "${CMAKE_CURRENT_LIST_DIR}/StaticAnalysis/.clang-tidy.all.in"
                    "${gtest_SOURCE_DIR}/.clang-tidy" COPYONLY )
    configure_file( "${CMAKE_CURRENT_LIST_DIR}/StaticAnalysis/.clang-tidy.all.in"
                    "${gmock_SOURCE_DIR}/.clang-tidy" COPYONLY )

    add_library(GTest::GTest ALIAS gtest)
    add_library(GTest::Main ALIAS gtest_main)
    add_library(GMock::GMock ALIAS gmock)
    add_library(GMock::Main ALIAS gmock_main)
    
    target_compile_options( gtest
      PUBLIC
        $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-Wno-global-constructors>
        $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-Wno-switch-default>
        $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-Wno-unsafe-buffer-usage-in-libc-call> # Death tests
    )

    target_compile_options( gmock
      PUBLIC
        $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-Wno-global-constructors>
        $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-Wno-switch-default>
        $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-Wno-unsafe-buffer-usage-in-libc-call> # Death tests
    )

    target_ignore_static_analysis(TARGET gtest CLANG_TIDY CPPCHECK CPPLINT IWYU)
    target_ignore_static_analysis(TARGET gtest_main CLANG_TIDY CPPCHECK CPPLINT IWYU)
    target_ignore_static_analysis(TARGET gmock CLANG_TIDY CPPCHECK CPPLINT IWYU)
    target_ignore_static_analysis(TARGET gmock_main CLANG_TIDY CPPCHECK CPPLINT IWYU)


    enable_testing()
    add_definitions(-DBUILD_TEST)
    
    include(ProcessorCount)
    ProcessorCount(PROCESSOR_COUNT)
    if(NOT PROCESSOR_COUNT EQUAL 0)
        set(CTEST_BUILD_FLAGS -j${_numProcessors} -V)
        set(ctest_test_args ${ctest_test_args} PARALLEL_LEVEL ${_numProcessors})
    endif()
else()

    # Dummy coverage target
    macro(setup_code_coverage_target)
        # Create a code coverage target.
        set(_coverageTarget code-coverage)

        add_custom_target(
            ${_coverageTarget}
            COMMAND echo "No coverage when BUILD_TEST=OFF"
            WORKING_DIRECTORY ${PROJECT_BINARY_DIR}
            DEPENDS ${Coverage_DEPENDENCIES}
            COMMENT
              "No coverage performed when BUILD_TEST=OFF"
        )
    endmacro()

endif(BUILD_TEST)
