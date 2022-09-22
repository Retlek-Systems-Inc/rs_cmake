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
# CMake Definition for FreeRTOS Plus-TCP until supported in this repo

if (NOT FREERTOS_PLUS_TCP_BUFFER_ALLOCATION)
    message(STATUS "Using default FREERTOS_PLUS_TCP_BUFFER_ALLOCATION = 1")
    set(FREERTOS_PLUS_TCP_BUFFER_ALLOCATION "1" CACHE STRING "FreeRTOS buffer allocation model number. 1 .. 2.")
endif()

if(NOT FREERTOS_PLUS_TCP_NETWORK_IF)
    message(FATAL_ERROR " FREERTOS_PLUS_TCP_NETWORK_IF is not set. Please specify it from top-level CMake file (example):\n"
        "  set(FREERTOS_PLUS_TCP_NETWORK_IF POSIX CACHE STRING \"\")\n"
        " or from CMake command line option:\n"
        "  -DFREERTOS_PLUS_TCP_NETWORK_IF=POSIX\n"
        " \n"
        " Available port options:\n"
        " A_CUSTOM_NETWORK_IF    Target: User Defined\n"
        " ATSAM4E                Target: ATSAM4E - TODO\n"
        " ATSAME5x               Target: ATSAME5x - TODO\n"
        " DRIVER_SAM             Target: Driver SAM - TODO\n"
        " ESP32                  Target: ESP-32 - TODO\n"
        " KSZ8851SNL             Target: ksz8851snl  - TODO\n"
        " POSIX                  Target: linux/Posix\n"
        " LPC17xx                Target: LPC17xx - TODO\n"
        " LPC18xx                Target: LPC18xx  - TODO\n"
        " LPC54018               Target: LPC54018  - TODO\n"
        " M487                   Target: M487- TODO\n"
        " MPS2_AN385             Target: MPS2_AN385  - TODO\n"
        " MW300_RD               Target: mw300_rd - TODO\n"
        " PIC32MZEF_ETH          Target: pic32mzef ethernet- TODO\n"
        " PIC32MZEF_WIFI         Target: pic32mzef Wifi- TODO\n"
        " RX                     Target: RX- TODO\n"
        " SH2A                   Target: SH2A- TODO\n"
        " STM32FXX               Target: STM32Fxx   - TODO\n"
        " STM32HXX               Target: STM32Hxx - TODO\n"
        " MSP432                 Target: MSP432   - TODO\n"
        " TM4C                   Target: TM4C- TODO\n"
        " WIN_PCAP               Target: Windows  - TODO\n"
        " XILINX_ULTRASCALE      Target: Xilinx Ultrascale - TODO\n"
        " ZYNQ                   Target: Xilinx Zynq")
elseif((FREERTOS_PORT STREQUAL "A_CUSTOM_PORT") AND (NOT TARGET freertos_kernel_port) )
    message(FATAL_ERROR " FREERTOS_PLUS_TCP_NETWORK_IF is set to A_CUSTOM_NETWORK_IF. Please specify the custom network interface target with\n"
    " all necessary files. For example, assuming a directory of:\n"
    "  FreeRTOSCustomNetworkInterface/\n"
    "    CMakeLists.txt\n"
    "    NetworkInterface.c\n\n"
    " Where FreeRTOSCustomNetworkInterface/CMakeLists.txt is a modified version of:\n"
    "   add_library(freertos_plus_tcp_network_if STATIC)\n\n"
    "   target_sources(freertos_plus_tcp_network_if\n"
    "     PRIVATE\n"
    "       NetworkInterface.c)\n\n"
    "   target_include_directories(freertos_plus_tcp_network_if\n"
    "     PUBLIC\n"
    "      .)\n\n"
    "   taget_link_libraries(freertos_plus_tcp_network_if\n"
    "     PRIVATE\n"
    "       freertos_kernel)")
endif()

add_library( freertos_plus_tcp STATIC )
add_library( FreeRTOS::PlusTCP ALIAS freertos_plus_tcp )

target_sources( freertos_plus_tcp
  PRIVATE
      include/FreeRTOS_ARP.h
      include/FreeRTOS_DHCP.h
      include/FreeRTOS_DNS_Cache.h
      include/FreeRTOS_DNS_Callback.h
      include/FreeRTOS_DNS_Globals.h
      include/FreeRTOS_DNS_Networking.h
      include/FreeRTOS_DNS_Parser.h
      include/FreeRTOS_DNS.h
      include/FreeRTOS_errno_TCP.h
      include/FreeRTOS_ICMP.h
      include/FreeRTOS_IP_Private.h
      include/FreeRTOS_IP_Timers.h
      include/FreeRTOS_IP_Utils.h
      include/FreeRTOS_IP.h
      include/FreeRTOS_Sockets.h
      include/FreeRTOS_Stream_Buffer.h
      include/FreeRTOS_TCP_IP.h
      include/FreeRTOS_TCP_Reception.h
      include/FreeRTOS_TCP_State_Handling.h
      include/FreeRTOS_TCP_Transmission.h
      include/FreeRTOS_TCP_Utils.h
      include/FreeRTOS_TCP_WIN.h
      include/FreeRTOS_UDP_IP.h
      include/FreeRTOSIPConfigDefaults.h
      include/IPTraceMacroDefaults.h
      include/NetworkBufferManagement.h
      include/NetworkInterface.h

      FreeRTOS_ARP.c
      FreeRTOS_DHCP.c
      FreeRTOS_DNS_Cache.c
      FreeRTOS_DNS_Callback.c
      FreeRTOS_DNS_Networking.c
      FreeRTOS_DNS_Parser.c
      FreeRTOS_DNS.c
      FreeRTOS_ICMP.c
      FreeRTOS_IP_Timers.c
      FreeRTOS_IP_Utils.c
      FreeRTOS_IP.c
      FreeRTOS_Sockets.c
      FreeRTOS_Stream_Buffer.c
      FreeRTOS_TCP_IP.c
      FreeRTOS_TCP_Reception.c
      FreeRTOS_TCP_State_Handling.c
      FreeRTOS_TCP_Transmission.c
      FreeRTOS_TCP_Utils.c
      FreeRTOS_TCP_WIN.c
      FreeRTOS_Tiny_TCP.c
      FreeRTOS_UDP_IP.c
)

# Note: Have to make system due to compiler warnings in header files.
target_include_directories( freertos_plus_tcp SYSTEM
  PUBLIC
    include
)

#TODO(phelter): Investigate and fix in freertos_plus_tcp if not already fixed.
target_compile_options( freertos_plus_tcp
  PRIVATE
    $<$<COMPILE_LANG_AND_ID:C,Clang,GNU>:-Wno-address-of-packed-member>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-bad-function-cast>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-documentation>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-cast-qual>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-conditional-uninitialized>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-covered-switch-default>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-extra-semi-stmt>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-format-nonliteral>
    $<$<COMPILE_LANG_AND_ID:C,Clang,GNU>:-Wno-format>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-gnu-statement-expression>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-implicit-int-conversion>
    $<$<COMPILE_LANG_AND_ID:C,Clang,GNU>:-Wno-int-to-pointer-cast>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-macro-redefined>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-missing-noreturn>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-missing-variable-declarations>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-packed>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-padded>
    $<$<COMPILE_LANG_AND_ID:C,GNU>:-Wno-pointer-to-int-cast>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-reserved-identifier>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-reserved-macro-identifier>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-shorten-64-to-32>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-sign-conversion>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-tautological-constant-out-of-range-compare>
    $<$<COMPILE_LANG_AND_ID:C,GNU>:-Wno-type-limits>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-undef>
    $<$<COMPILE_LANG_AND_ID:C,GNU>:-Wno-uninitialized>
    $<$<COMPILE_LANG_AND_ID:C,Clang,GNU>:-Wno-unused-but-set-variable>
    $<$<COMPILE_LANG_AND_ID:C,Clang,GNU>:-Wno-unused-function>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-unused-macros>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-unused-parameter>
    $<$<COMPILE_LANG_AND_ID:C,Clang,GNU>:-Wno-unused-variable>
)

#TODO(phelter): should separate out portable portion into separate lib.

target_link_libraries( freertos_plus_tcp
  PUBLIC
    FreeRTOS::Config
    freertos_plus_tcp_port # for pack_struct_start.h
  PRIVATE
    freertos_kernel
    freertos_plus_tcp_network_if
    freertos_plus_tcp_tools
)

add_subdirectory(portable)
