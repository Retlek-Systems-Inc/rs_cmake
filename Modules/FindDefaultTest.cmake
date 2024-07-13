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
                --rc lcov_branch_coverage=1
            GENHTML_ARGS
                --rc genhtml_branch_coverage=1
                --demangle-cpp
                --prefix ${CMAKE_SOURCE_DIR}
        )
    endmacro()

    include(FetchContent)
    FetchContent_Declare( googletest
      GIT_REPOSITORY    https://github.com/google/googletest.git
      GIT_TAG           v1.14.0
    )

    # Prevent overriding the parent project's compiler/linker
    # settings on Windows
    set(gtest_force_shared_crt ON CACHE BOOL "" FORCE) 


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
        $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-Wno-used-but-marked-unused>
    )

    target_compile_options( gmock
      PUBLIC
        $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-Wno-global-constructors>
        $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-Wno-switch-default>
        $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-Wno-used-but-marked-unused>
    )

    target_clang_tidy_definitions(TARGET gtest
      CHECKS
        -*-avoid-c-arrays
        -*-braces-around-statements
        -*-deprecated-headers
        -*-else-after-return
        -*-explicit-constructor
        -*-magic-numbers
        -*-member-init
        -*-named-parameter
        -*-no-malloc
        -*-qualified-auto
        -*-uppercase-literal-suffix
        -*-use-auto
        -*-use-emplace
        -*-use-equals-default
        -*-use-equals-delete
        -altera-id-dependent-backward-branch
        -altera-struct-pack-align
        -altera-unroll-loops
        -android-cloexec-dup
        -android-cloexec-pipe
        -bugprone-branch-clone
        -bugprone-easily-swappable-parameters
        -bugprone-exception-escape
        -bugprone-macro-parentheses
        -bugprone-misplaced-widening-cast
        -bugprone-reserved-identifier
        -bugprone-signed-char-misuse
        -bugprone-sizeof-expression
        -bugprone-suspicious-include
        -cert-dcl21-cpp
        -cert-dcl37-c
        -cert-dcl50-cpp
        -cert-dcl51-cpp
        -cert-err33-c
        -cert-err58-cpp
        -cert-oop54-cpp
        -cert-str34-c
        -clang-analyzer-optin.performance.Padding
        -concurrency-mt-unsafe
        -cppcoreguidelines-avoid-non-const-global-variables
        -cppcoreguidelines-c-copy-assignment-signature
        -cppcoreguidelines-init-variables
        -cppcoreguidelines-macro-usage
        -cppcoreguidelines-owning-memory
        -cppcoreguidelines-prefer-member-initializer
        -cppcoreguidelines-pro-bounds-array-to-pointer-decay
        -cppcoreguidelines-pro-bounds-constant-array-index
        -cppcoreguidelines-pro-bounds-pointer-arithmetic
        -cppcoreguidelines-pro-type-const-cast
        -cppcoreguidelines-pro-type-cstyle-cast
        -cppcoreguidelines-pro-type-union-access
        -cppcoreguidelines-pro-type-vararg
        -cppcoreguidelines-virtual-class-destructor
        -fuchsia-multiple-inheritance
        -fuchsia-statically-constructed-objects
        -fuchsia-trailing-return
        -google-runtime-int
        -google-upgrade-googletest-case
        -hicpp-exception-baseclass
        -hicpp-explicit-conversions
        -hicpp-multiway-paths-covered
        -hicpp-noexcept-move
        -hicpp-no-array-decay
        -hicpp-no-assembler
        -hicpp-signed-bitwise
        -hicpp-vararg
        -llvm-include-order
        -llvm-namespace-comment
        -llvmlibc-callee-namespace
        -llvmlibc-implementation-in-namespace
        -llvmlibc-restrict-system-libc-headers
        -misc-include-cleaner
        -misc-no-recursion
        -misc-redundant-expression
        -misc-unconventional-assign-operator
        -modernize-loop-convert
        -modernize-make-unique
        -modernize-pass-by-value
        -modernize-raw-string-literal
        -modernize-return-braced-init-list
        -modernize-pass-by-value
        -modernize-use-default-member-init
        -modernize-use-trailing-return-type
        -modernize-use-transparent-functors
        -modernize-use-using
        -performance-no-automatic-move
        -performance-noexcept-move-constructor
        -performance-unnecessary-value-param
        -readability-container-data-pointer
        -readability-container-size-empty
        -readability-convert-member-functions-to-static
        -readability-function-cognitive-complexity
        -readability-identifier-length
        -readability-implicit-bool-conversion
        -readability-inconsistent-declaration-parameter-name
        -readability-isolate-declaration
        -readability-redundant-access-specifiers
        -readability-redundant-string-cstr
        -readability-redundant-string-init
        -readability-redundant-smartptr-get
        -readability-simplify-boolean-expr
        -readability-static-accessed-through-instance
    )

    target_cppcheck_definitions(TARGET gtest
      DEFINES
        -UGTEST_CHECK_
        -UGTEST_CUSTOM_GET_ARGVS_
        -UGTEST_CUSTOM_INIT_GOOGLE_TEST_FUNCTION_
        -UGTEST_CUSTOM_TEMPDIR_FUNCTION_
        -UGTEST_CUSTOM_TEST_EVENT_LISTENER_
        -UGTEST_DECLARE_bool_
        -UGTEST_DEV_EMAIL_
        -UGTEST_FLAG
        -UGTEST_GET_BOOL_FROM_ENV_
        -UGTEST_GET_INT32_FROM_ENV_
        -UGTEST_GET_STRING_FROM_ENV_
        -UGTEST_INIT_GOOGLE_TEST_NAME_
        -UGTEST_INTERNAL_DEPRECATED
        -UGTEST_LOG_
        -UGTEST_OS_STACK_TRACE_GETTER_
        -UPATH_MAX
        -U_XOPEN_PATH_MAX
        --suppress=missingInclude
    )

    target_clang_tidy_definitions(TARGET gtest_main
      CHECKS
        -cppcoreguidelines-pro-type-vararg
        -hicpp-vararg
        -llvm-include-order
        -llvmlibc-callee-namespace
        -llvmlibc-implementation-in-namespace
        -llvmlibc-restrict-system-libc-headers
        -modernize-use-trailing-return-type
    )
    
    target_cppcheck_definitions(TARGET gtest
      DEFINES
        --suppress=missingInclude
    )

    target_clang_tidy_definitions(TARGET gmock
      CHECKS
        -*-avoid-c-arrays
        -*-braces-around-statements
        -*-else-after-return
        -*-explicit-constructor
        -*-magic-numbers
        -*-member-init
        -*-named-parameter
        -*-narrowing-conversions
        -*-qualified-auto
        -*-use-auto
        -*-use-equals-default
        -altera-id-dependent-backward-branch
        -altera-struct-pack-align
        -altera-unroll-loops
        -bugprone-easily-swappable-parameters
        -bugprone-exception-escape
        -bugprone-forwarding-reference-overload
        -bugprone-macro-parentheses
        -bugprone-suspicious-include
        -cert-err09-cpp
        -cert-err58-cpp
        -cert-err61-cpp
        -cert-oop54-cpp
        -cppcoreguidelines-avoid-non-const-global-variables
        -cppcoreguidelines-c-copy-assignment-signature
        -cppcoreguidelines-init-variables
        -cppcoreguidelines-macro-usage
        -cppcoreguidelines-owning-memory
        -cppcoreguidelines-pro-bounds-array-to-pointer-decay
        -cppcoreguidelines-pro-bounds-pointer-arithmetic
        -cppcoreguidelines-pro-type-const-cast
        -cppcoreguidelines-pro-type-vararg
        -fuchsia-trailing-return
        -fuchsia-statically-constructed-objects
        -google-readability-casting
        -hicpp-explicit-conversions
        -hicpp-deprecated-headers
        -hicpp-no-array-decay
        -hicpp-signed-bitwise
        -hicpp-vararg
        -llvm-include-order
        -llvmlibc-callee-namespace
        -llvmlibc-implementation-in-namespace
        -llvmlibc-restrict-system-libc-headers
        -misc-include-cleaner
        -misc-no-recursion
        -misc-throw-by-value-catch-by-reference
        -misc-unconventional-assign-operator
        -modernize-deprecated-headers
        -modernize-loop-convert
        -modernize-pass-by-value
        -modernize-return-braced-init-list
        -modernize-use-default-member-init
        -modernize-use-trailing-return-type
        -modernize-use-using
        -readability-container-size-empty
        -readability-const-return-type
        -readability-convert-member-functions-to-static
        -readability-function-cognitive-complexity
        -readability-identifier-length
        -readability-implicit-bool-conversion
        -readability-isolate-declaration
        -readability-simplify-boolean-expr
    )

    target_cppcheck_definitions(TARGET gmock
      DEFINES
        -UGMOCK_DECLARE_bool_
        --suppress=missingInclude
    )

    target_clang_tidy_definitions(TARGET gmock_main
      CHECKS
        -cppcoreguidelines-pro-type-vararg
        -hicpp-vararg
        -llvm-include-order
        -llvmlibc-callee-namespace
        -llvmlibc-implementation-in-namespace
        -llvmlibc-restrict-system-libc-headers
        -modernize-use-trailing-return-type
    )

    #--------------------------------------------------------------------
    # Simpler way of writing GMock instances for C headers.
    get_property(_languages GLOBAL PROPERTY ENABLED_LANGUAGES)
    if ("C" IN_LIST _languages)
        FetchContent_Declare( gmock_c
            GIT_REPOSITORY    https://github.com/Retlek-Systems-Inc/C-Mock.git
            GIT_TAG           v0.1.1
        )
        FetchContent_MakeAvailable(gmock_c)
        list(APPEND COVERAGE_LCOV_EXCLUDES '${gmock_c_SOURCE_DIR}/*' )
    endif()

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
