# @copyright 2017-2025 Retlek Systems Inc.
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
Sanitizer
---------

Adds a Sanitizer Configurations

#]=======================================================================]

set(_supportedCompilers "GNU" "Clang")

if (CMAKE_CXX_COMPILER_ID IN_LIST _supportedCompilers)

    # Note leak and dynamic address sanitizers are a subset of address sanitizer so no need for separate run
    # Note integer sanitizer is a subset of undefined sanitizer so no need for a separate run
    # Note undefined could is added to any of the sanitizers, but left on it's own for now
    # The recommended (preferred) optimization level for sanitizers is O2 or RelWithDebInfo settings.
    set(_commonSanFlags -fno-omit-frame-pointer)

    AddConfiguration( CONFIG Asan
        BASE_CONFIG RelWithDebInfo
        COMPILE_FLAGS
            -fsanitize=address
            ${_commonSanFlags}
            -fno-optimize-sibling-calls
            -fsanitize-address-use-after-scope
        LINKER_FLAGS
            -fsanitize=address
    )

    AddConfiguration( CONFIG Tsan
        BASE_CONFIG RelWithDebInfo
        COMPILE_FLAGS
            -fsanitize=thread
            ${_commonSanFlags}
        LINKER_FLAGS
            -fsanitize=thread
    )

    set(_supportedMSanCompilers "Clang" "AppleClang")
    if(CMAKE_CXX_COMPILER_ID IN_LIST _supportedMSanCompilers)
        # Get Clang version
        execute_process(
            COMMAND ${CMAKE_CXX_COMPILER} --version
            OUTPUT_VARIABLE CLANG_VERSION_OUTPUT
        )
        string(REGEX MATCH "version ([0-9]+)" CLANG_VERSION_MATCH "${CLANG_VERSION_OUTPUT}")
        if(CLANG_VERSION_MATCH)
            set(CLANG_VERSION ${CMAKE_MATCH_1})
            
            # Get the system architecture
            execute_process(
                COMMAND uname -m
                OUTPUT_VARIABLE SYS_ARCH
                OUTPUT_STRIP_TRAILING_WHITESPACE
            )

            # Ask Clang for its resource directory
            set(MSAN_LIBRARY_PATHS
                "/usr/lib/llvm-${CLANG_VERSION}/lib/clang/${CLANG_VERSION}/lib/linux"
                "/usr/lib/clang/${CLANG_VERSION}/lib/linux"
                "/usr/lib64/clang/${CLANG_VERSION}/lib/linux"
                "/usr/lib/llvm/lib/clang/${CLANG_VERSION}/lib/linux"
            )
            execute_process(
                COMMAND ${CMAKE_CXX_COMPILER} -print-resource-dir
                OUTPUT_VARIABLE CLANG_RESOURCE_DIR
                OUTPUT_STRIP_TRAILING_WHITESPACE
            )
            if(CLANG_RESOURCE_DIR)
                list(APPEND MSAN_LIBRARY_PATHS "${CLANG_RESOURCE_DIR}/lib/linux")
            endif()

            # Check common paths for MSAN runtime library

            # Find MSAN runtime library
            find_library(MSAN_RUNTIME_LIBRARY
                NAMES "clang_rt.msan-${SYS_ARCH}"
                PATHS ${MSAN_LIBRARY_PATHS}
            )
            find_library(MSAN_CXX_RUNTIME_LIBRARY
                NAMES "clang_rt.msan_cxx-${SYS_ARCH}"
                PATHS ${MSAN_LIBRARY_PATHS}
            )

            if(MSAN_RUNTIME_LIBRARY)               
                get_filename_component(MSAN_RUNTIME_LIBRARY_PATH "${MSAN_RUNTIME_LIBRARY}" DIRECTORY)
                set(MSAN_RT_LIB "-lclang_rt.msan-${SYS_ARCH}")
            
                set(MSAN_CXX_RT_LIB)
                if(MSAN_CXX_RUNTIME_LIBRARY)
                    set(MSAN_CXX_RT_LIB "-lclang_rt.msan_cxx-${SYS_ARCH}")
                endif()
            
                message(STATUS "Found MSAN runtime Libraries Path: ${MSAN_RUNTIME_LIBRARY_PATH}")
                message(STATUS "  MSAN runtime library: ${MSAN_RT_LIB}")
                message(STATUS "  MSAN CXX runtime library: ${MSAN_CXX_RT_LIB}")

                AddConfiguration( CONFIG Msan
                    BASE_CONFIG RelWithDebInfo
                    COMPILE_FLAGS
                        -stdlib=libc++
                        -fsanitize=memory
                        ${_commonSanFlags}
                        -fno-optimize-sibling-calls
                        -fsanitize-memory-track-origins=2
                    LINKER_FLAGS
                        -stdlib=libc++
                        -fsanitize=memory
                        -L${MSAN_RUNTIME_LIBRARY_PATH}
                        "${MSAN_RT_LIB}"
                        "${MSAN_CXX_RT_LIB}"
                )
                set(MSAN_LINK_LIBRARIES 
                    "-L${MSAN_RUNTIME_LIBRARY_PATH} ${MSAN_RT_LIB} ${MSAN_CXX_RT_LIB}"
                    CACHE STRING "Link Libraries for MSAN builds."
                    FORCE
                )
            else()
                message(WARNING "MemorySanitizer runtime library not found. MSAN may not work correctly.")
            endif()
        endif()
    else()
        # No GCC Msan yet but try.
        AddConfiguration( CONFIG Msan
            BASE_CONFIG RelWithDebInfo
            COMPILE_FLAGS
                -fsanitize=memory
                ${_commonSanFlags}
                -fno-optimize-sibling-calls
                -fsanitize-memory-track-origins=2
            LINKER_FLAGS
                -fsanitize=memory
        )   
    endif()

    AddConfiguration( CONFIG Ubsan
        BASE_CONFIG RelWithDebInfo
        COMPILE_FLAGS
            -fsanitize=undefined
            ${_commonSanFlags}
            #-fsanitize-blacklist=BLACKLIST_FILE
        LINKER_FLAGS
            -fsanitize=undefined
    )

    # AddConfiguration( CONFIG Cfisan
    #     BASE_CONFIG RelWithDebInfo
    #     COMPILE_FLAGS
    #         -fsanitize=cfi
    #         ${_commonSanFlags}
    #     LINKER_FLAGS
    #         -fsanitize=cfi
    # )
else()
    message(STATUS "Sanitizers not supported for compiler: ${CMAKE_CXX_COMPILER_ID}")
endif()

#Valgrind specific options
# TODO: Investigate :
# CTEST_MEMORYCHECK_COMMAND
# CTEST_MEMORYCHECK_COMMAND_OPTIONS
# CTEST_MEMORYCHECK_SANITIZER_OPTIONS
# CTEST_MEMORYCHECK_SUPPRESSIONS_FILE
# CTEST_MEMORYCHECK_TYPE
# set(VALGRIND_OPTIONS "-q --tool=memcheck --leak-check=yes -leak-check=full --num-callers=20 --track-origins=yes --trace-children=yes")
# set(MEMORYCHECK_SUPPRESSIONS_FILE ${CMAKE_CURRENT_LIST_DIR}/memorycheck.suppressions CACHE STRING "Suppressions file for Memory Checks")
