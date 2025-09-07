#######################################################################
# @copyright 2025 Retlek Systems Inc.
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


# -----------------------------------------------------------------------------
# Software Bill of Materials (SBOM) definition
# List of all of the local and third-party repos that were used in the creation
# of the code associated with this application

include(FetchContent)

#options from front-end build environment: BUILD_TEST, STATIC_ANALYSIS, BUILD_DOC, VERILOG_TEST
#set(FETCHCONTENT_UPDATES_DISCONNECTED ON)
FetchContent_Declare(rs_cmake
    GIT_REPOSITORY git@github.com:Retlek-Systems-Inc/rs_cmake.git
    GIT_TAG        v0.5.6 
)

FetchContent_Declare(gmock_c # Alternative version - see fork details.
    GIT_REPOSITORY git@github.com:Retlek-Systems-Inc/C-Mock.git
    GIT_TAG        v0.1.2
    EXCLUDE_FROM_ALL
)

FetchContent_Declare(googletest
    GIT_REPOSITORY    https://github.com/google/googletest.git
    GIT_TAG           v1.17.0
    EXCLUDE_FROM_ALL
)

FetchContent_Declare( benchmark
    GIT_REPOSITORY    https://github.com/google/benchmark.git
    GIT_TAG           v1.9.4
    EXCLUDE_FROM_ALL
)

# For BUILD_DOC
FetchContent_Declare(
    wavedrom
    GIT_REPOSITORY    https://github.com/wavedrom/wavedrom.git
    GIT_TAG           v2.1.2
)

FetchContent_Declare(
    doxygenVerilog
    GIT_REPOSITORY https://github.com/avelure/doxygen-verilog.git
    GIT_TAG        master
)


#--------------------------------------------------------------------
# Note this MUST be the first one for everything to work properly
FetchContent_GetProperties(rs_cmake)
if(NOT rs_cmake_POPULATED)
  FetchContent_MakeAvailable(rs_cmake)
  include(${rs_cmake_SOURCE_DIR}/Init.cmake)
endif()

#--------------------------------------------------------------------
# Simpler way of writing GMock instances for C headers.
if(BUILD_TEST) 
    FetchContent_MakeAvailable(googletest)

    if ("C" IN_LIST _languages)
        FetchContent_MakeAvailable(gmock_c)
        list(APPEND COVERAGE_LCOV_EXCLUDES '${gmock_c_SOURCE_DIR}/*' )
    endif()
endif()

if( BUILD_BENCHMARK )
    # Prevent downloading gtest - use FindDefaultTest.
    set(BENCHMARK_DOWNLOAD_DEPENDENCIES OFF CACHE BOOL "" FORCE)
    set(BENCHMARK_ENABLE_TESTING OFF CACHE BOOL "" FORCE) # Disable testing of the benchmark library
    set(BENCHMARK_ENABLE_GTEST_TESTS OFF CACHE BOOL "" FORCE) # Disable building the unit tests which depend on gtest
    set(BENCHMARK_USE_BUNDLED_GTEST ON CACHE BOOL "" FORCE) # Use bundled GTEST within the gtest.
    
    FetchContent_MakeAvailable(benchmark)

    target_compile_options( benchmark
        PRIVATE
            $<$<COMPILE_LANG_AND_ID:CXX,GNU>:-Wno-maybe-uninitialized>
    )
    target_ignore_static_analysis(TARGET benchmark CLANG_TIDY CPPCHECK CPPLINT IWYU)
    target_ignore_static_analysis(TARGET benchmark_main CLANG_TIDY CPPCHECK CPPLINT IWYU)
    list(APPEND COVERAGE_LCOV_EXCLUDES '${benchmark_SOURCE_DIR}/*' )
endif(BUILD_BENCHMARK)
