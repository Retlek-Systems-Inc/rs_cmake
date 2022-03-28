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

macro(setup_code_coverage_target)
    # Create a code coverage target.
    set(_coverageTarget code-coverage)
    string(TOLOWER ${CMAKE_BUILD_TYPE} _buildType)
    if ( ${_buildType} STREQUAL coverage AND NOT TARGET ${_coverageTarget} )
        include(CodeCoverage)
        APPEND_COVERAGE_COMPILER_FLAGS()

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
                --rc lcov_branch_coverage=1
            GENHTML_ARGS
                --rc genhtml_branch_coverage=1
                --demangle-cpp
                --prefix ${CMAKE_SOURCE_DIR}
        )
    endif()
endmacro()

if(BUILD_TEST)
	#set(INSTALL_GTEST OFF)
    include(FetchContent)
    FetchContent_Declare( googletest
      GIT_REPOSITORY    https://github.com/google/googletest.git
      GIT_TAG           release-1.11.0 #master - need latest
    )

    # Prevent overriding the parent project's compiler/linker
    # settings on Windows
    set(gtest_force_shared_crt ON CACHE BOOL "" FORCE) 


    FetchContent_MakeAvailable(googletest)
    # Add clang-tidy definition to include warnings/errors for googletest.
    # Clang-Tidy all file for build dir /_deps - anything third-party or grabbed from elsewhere don't do clang tidy on.
    configure_file( "${CMAKE_CURRENT_LIST_DIR}/StaticAnalysis/.clang-tidy.all.in"
                    "${CMAKE_BINARY_DIR}/_deps/.clang-tidy" COPYONLY )

    add_library(GTest::GTest ALIAS gtest)
    add_library(GTest::Main ALIAS gtest_main)
    add_library(GMock::GMock ALIAS gmock)
    add_library(GMock::Main ALIAS gmock_main)
    
    target_compile_options( gtest
      PUBLIC
        $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-Wno-covered-switch-default>
        $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-Wno-global-constructors>
        $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-Wno-gnu-zero-variadic-macro-arguments>
        $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-Wno-used-but-marked-unused>
        $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-Wno-weak-vtables>
    )

    target_compile_options( gmock
      PUBLIC
        $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-Wno-covered-switch-default>
        $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-Wno-global-constructors>
        $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-Wno-gnu-zero-variadic-macro-arguments>
        $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-Wno-used-but-marked-unused>
        $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-Wno-weak-vtables>
    )

    target_clang_tidy_definitions(TARGET gtest
      CHECKS
        -bugprone-exception-escape
        -bugprone-suspicious-include
        -cppcoreguidelines-pro-type-vararg
        -hicpp-deprecated-headers
        -hicpp-vararg
        -llvm-include-order
        -llvmlibc-callee-namespace
        -llvmlibc-implementation-in-namespace
        -llvmlibc-restrict-system-libc-headers
        -modernize-deprecated-headers
        -modernize-use-trailing-return-type
    )
    
    target_clang_tidy_definitions(TARGET gmock
      CHECKS
        -bugprone-exception-escape
        -bugprone-suspicious-include
        -cppcoreguidelines-pro-type-vararg
        -hicpp-deprecated-headers
        -hicpp-vararg
        -llvm-include-order
        -llvmlibc-callee-namespace
        -llvmlibc-implementation-in-namespace
        -llvmlibc-restrict-system-libc-headers
        -modernize-deprecated-headers
        -modernize-use-trailing-return-type
    )
    enable_testing()
    add_definitions(-DBUILD_TEST)
    
    include(ProcessorCount)
    ProcessorCount(PROCESSOR_COUNT)
    if(NOT PROCESSOR_COUNT EQUAL 0)
        set(CTEST_BUILD_FLAGS -j${_numProcessors} -V)
        set(ctest_test_args ${ctest_test_args} PARALLEL_LEVEL ${_numProcessors})
    endif()

    # Code analysis
    if (UNIX)
        string(TOLOWER ${CMAKE_BUILD_TYPE} _buildType)
        if ( ${_buildType} STREQUAL coverage )
            include(CodeCoverage)
            APPEND_COVERAGE_COMPILER_FLAGS()
        endif()

        include(${CMAKE_CURRENT_LIST_DIR}/Sanitizer.cmake)
        SETUP_FOR_SANITIZE(BUILD_TYPE ASAN)
        SETUP_FOR_SANITIZE(BUILD_TYPE TSAN)
        SETUP_FOR_SANITIZE(BUILD_TYPE MSAN)
        SETUP_FOR_SANITIZE(BUILD_TYPE UBSAN)
    endif(UNIX)
endif(BUILD_TEST)
