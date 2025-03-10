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

# Adds the necessary information for testing environment with googletest.
# Note googletest/googlemock are down-loaded into the build dir and compiled as part
# of the test environment from there.

if( BUILD_BENCHMARK )
    set(isRelBuild "$<BOOL:$<CONFIG:Release,RelWithDebInfo,MinSizeRel>>")
    if( BUILD_BENCHMARK_RELEASE_ONLY AND NOT isRelBuild )
        message(STATUS "Not building benchmark with CMAKE_BUILD_TYPE = ${CMAKE_BUILD_TYPE}")
        return()
    endif()

    include(FetchContent)
    FetchContent_Declare( benchmark
      GIT_REPOSITORY    https://github.com/google/benchmark.git
      GIT_TAG           v1.9.1
    )

    # Prevent downloading gtest - use FindDefaultTest.
    set(BENCHMARK_DOWNLOAD_DEPENDENCIES OFF CACHE BOOL "" FORCE)
    set(BENCHMARK_ENABLE_TESTING OFF CACHE BOOL "" FORCE) # Disable testing of the benchmark library
    set(BENCHMARK_ENABLE_GTEST_TESTS OFF CACHE BOOL "" FORCE) # Disable building the unit tests which depend on gtest
    set(BENCHMARK_USE_BUNDLED_GTEST ON CACHE BOOL "" FORCE) # Use bundled GTEST within the gtest.
    
    FetchContent_MakeAvailable(benchmark)

    target_clang_tidy_definitions( TARGET benchmark
      CHECKS
        -performance-avoid-endl
        -performance-enum-size
        -clang-analyzer-deadcode.DeadStores
    )

    target_clang_tidy_definitions( TARGET benchmark_main
      CHECKS
          -performance-enum-size
    )

    list(APPEND COVERAGE_LCOV_EXCLUDES '${benchmark_SOURCE_DIR}/*' )

endif(BUILD_BENCHMARK)
