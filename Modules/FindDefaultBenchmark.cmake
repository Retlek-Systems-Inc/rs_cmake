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
      GIT_TAG           v1.7.1
    )

    # Prevent downloading gtest - use FindDefaultTest.
    set(BENCHMARK_DOWNLOAD_DEPENDENCIES OFF CACHE BOOL "" FORCE)
    set(BENCHMARK_ENABLE_TESTING OFF CACHE BOOL "" FORCE) # Disable testing of the benchmark library
    set(BENCHMARK_ENABLE_GTEST_TESTS OFF CACHE BOOL "" FORCE) # Disable building the unit tests which depend on gtest
    set(BENCHMARK_USE_BUNDLED_GTEST ON CACHE BOOL "" FORCE) # Use bundled GTEST within the gtest.
    
    FetchContent_MakeAvailable(benchmark)
    # Add clang-tidy definition to include warnings/errors for benchmark.
    # Clang-Tidy all file for benchmark source dir (override).
    configure_file( "${CMAKE_CURRENT_LIST_DIR}/StaticAnalysis/.clang-tidy.all.in"
                    "${benchmark_SOURCE_DIR}/.clang-tidy" COPYONLY )

    target_compile_options( benchmark
      PUBLIC
        $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-Wno-global-constructors>
        $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-Wno-padded>
        $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-Wno-shift-sign-overflow>
        $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-Wno-weak-vtables>
        $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-Wno-zero-as-null-pointer-constant>
    )

    target_clang_tidy_definitions( TARGET benchmark
      CHECKS
        -*-avoid-c-arrays
        -*-braces-around-statements
        -*-else-after-return
        -*-magic-numbers
        -*-member-init
        -*-narrowing-conversions
        -*-named-parameter
        -*-use-auto
        -*-use-emplace
        -*-use-equals-default
        -*-vararg
        -abseil-string-find-startswith
        -altera-id-dependent-backward-branch
        -altera-struct-pack-align
        -altera-unroll-loops
        -bugprone-easily-swappable-parameters
        -bugprone-implicit-widening-of-multiplication-result
        -cert-dcl50-cpp
        -cert-err33-c
        -cert-err58-cpp
        -concurrency-mt-unsafe
        -cppcoreguidelines-avoid-non-const-global-variables
        -cppcoreguidelines-init-variables
        -cppcoreguidelines-owning-memory
        -cppcoreguidelines-pro-bounds-array-to-pointer-decay
        -cppcoreguidelines-pro-bounds-pointer-arithmetic
        -fuchsia-default-arguments-calls
        -fuchsia-default-arguments-declarations
        -fuchsia-statically-constructed-objects
        -google-build-using-namespace
        -google-readability-casting
        -google-readability-todo
        -google-runtime-int
        -hicpp
        -hicpp-multiway-paths-covered
        -hicpp-no-array-decay
        -hicpp-signed-bitwise
        -llvm-namespace-comment
        -llvm-qualified-auto
        -llvmlibc-callee-namespace
        -llvmlibc-implementation-in-namespace
        -llvmlibc-restrict-system-libc-headers
        -modernize-pass-by-value
        -modernize-raw-string-literal
        -modernize-return-braced-init-list
        -modernize-use-nullptr
        -modernize-use-trailing-return-type
        -modernize-use-using
        -readability-container-size-empty
        -readability-duplicate-include
        -readability-function-cognitive-complexity
        -readability-identifier-length
        -readability-implicit-bool-conversion
        -readability-inconsistent-declaration-parameter-name
        -readability-qualified-auto
        -readability-simplify-boolean-expr
        -readability-static-accessed-through-instance
        -readability-static-definition-in-anonymous-namespace
        -readability-use-anyofallof
        -clang-analyzer-deadcode.DeadStores
    )

  target_clang_tidy_definitions( TARGET benchmark_main
    CHECKS
      -*-array-to-pointer-decay
      -*-avoid-c-arrays
      -*-named-parameter
      -fuchsia-default-arguments-calls
      -hicpp-no-array-decay
      -llvmlibc-callee-namespace
      -llvmlibc-implementation-in-namespace
      -modernize-use-trailing-return-type
  )

endif(BUILD_BENCHMARK)
