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

#[=======================================================================[.rst:
Sanitizer
---------

Adds a Sanitizer Configurations

#]=======================================================================]

set(_commonSanFlags -fno-omit-frame-pointer)

AddConfiguration( CONFIG Asan
    BASE_CONFIG RelWithDebInfo
    COMPILE_FLAGS
        -fsanitize=address
        ${_commonSanFlags}
        -fno-optimize-sibling-calls
    LINKER_FLAGS
        -fsanitize=address
        ${_commonSanFlags}
        -fno-optimize-sibling-calls
)

AddConfiguration( CONFIG Tsan
    BASE_CONFIG RelWithDebInfo
    COMPILE_FLAGS
        -fsanitize=thread
        ${_commonSanFlags}
    LINKER_FLAGS
        -fsanitize=thread
        ${_commonSanFlags}
)

# AddConfiguration( CONFIG Msan
#     BASE_CONFIG RelWithDebInfo
#     COMPILE_FLAGS
#         -fsanitize=memory
# #        -fsanitize=leak
#         ${_commonSanFlags}
# #        --fsanitize-memory-track-origins
#     LINKER_FLAGS
#         -fsanitize=thread
# #        -fsanitize=leak
#         ${_commonSanFlags}
# #        --fsanitize-memory-track-origins
# )

AddConfiguration( CONFIG Ubsan
    BASE_CONFIG RelWithDebInfo
    COMPILE_FLAGS
        -fsanitize=undefined
        ${_commonSanFlags}
        #-fsanitize-blacklist=BLACKLIST_FILE
    LINKER_FLAGS
        -fsanitize=undefined
        ${_commonSanFlags}
        #-fsanitize-blacklist=BLACKLIST_FILE
)

# AddConfiguration( CONFIG Cfisan
#     BASE_CONFIG RelWithDebInfo
#     COMPILE_FLAGS
#         -fsanitize=cfi
#         ${_commonSanFlags}
#     LINKER_FLAGS
#         -fsanitize=cfi
#         ${_commonSanFlags}
# )

#Valgrind specific options
# TODO: Investigate :
# CTEST_MEMORYCHECK_COMMAND
# CTEST_MEMORYCHECK_COMMAND_OPTIONS
# CTEST_MEMORYCHECK_SANITIZER_OPTIONS
# CTEST_MEMORYCHECK_SUPPRESSIONS_FILE
# CTEST_MEMORYCHECK_TYPE
# set(VALGRIND_OPTIONS "-q --tool=memcheck --leak-check=yes -leak-check=full --num-callers=20 --track-origins=yes --trace-children=yes")
# set(MEMORYCHECK_SUPPRESSIONS_FILE ${CMAKE_CURRENT_LIST_DIR}/memorycheck.suppressions CACHE STRING "Suppressions file for Memory Checks")
