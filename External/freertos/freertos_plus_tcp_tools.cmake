#######################################################################
# @copyright 2022 Retlek Systems Inc.

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
# CMake Definition for FreeRTOS Plus-TCP tools until supported in this repo

add_library( freertos_plus_tcp_tools STATIC )
add_library( FreeRTOS::PlusTCP::Tools ALIAS freertos_plus_tcp_tools )

target_sources( freertos_plus_tcp_tools
  PRIVATE
    tcp_utilities/include/tcp_dump_packets.h
    tcp_utilities/include/tcp_mem_stats.h
    tcp_utilities/include/tcp_netstat.h

    tcp_utilities/tcp_dump_packets.c
    tcp_utilities/tcp_mem_stats.c
    tcp_utilities/tcp_netstat.c
)

# Note: Have to make system due to compiler warnings in header files.
target_include_directories( freertos_plus_tcp_tools SYSTEM
  PUBLIC
    tcp_utilities/include
)

#TODO(phelter): Investigate and fix in freertos_plus_tcp if not already fixed.
target_compile_options( freertos_plus_tcp_tools
  PRIVATE
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-extra-semi-stmt>
    $<$<COMPILE_LANG_AND_ID:C,Clang,GNU>:-Wno-format>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-missing-variable-declarations>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-padded>
    $<$<COMPILE_LANG_AND_ID:C,Clang,GNU>:-Wno-unused-but-set-variable>
    $<$<COMPILE_LANG_AND_ID:C,Clang,GNU>:-Wno-unused-function>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-unused-macros>
    $<$<COMPILE_LANG_AND_ID:C,Clang,GNU>:-Wno-unused-variable>
)

target_link_libraries( freertos_plus_tcp_tools
  PRIVATE
    freertos_kernel
    freertos_plus_tcp
)
