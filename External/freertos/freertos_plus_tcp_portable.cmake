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
# CMake Definition for FreeRTOS Plus-TCP target until supported in this repo

#------------------------------------------------------------------------------
add_library( freertos_plus_tcp_port STATIC )
add_library( FreeRTOS::PlusTCP::Port ALIAS freertos_plus_tcp_port )

target_sources( freertos_plus_tcp_port
  PRIVATE
    BufferManagement/BufferAllocation_${FREERTOS_PLUS_TCP_BUFFER_ALLOCATION}.c
    # TODO: There's NetworkInterface/pic32mzef that has it's own BufferAllocation_2.c
)

target_include_directories( freertos_plus_tcp_port
  PUBLIC
    $<$<C_COMPILER_ID:CCS>:${CMAKE_CURRENT_SOURCE_DIR}/Compiler/CCS>
    $<$<C_COMPILER_ID:GNU,Clang,ARMClang>:${CMAKE_CURRENT_SOURCE_DIR}/Compiler/GCC>
    $<$<C_COMPILER_ID:IAR>:${CMAKE_CURRENT_SOURCE_DIR}/Compiler/IAR>
    $<$<C_COMPILER_ID:ARMCC>:${CMAKE_CURRENT_SOURCE_DIR}/Compiler/Keil>
    $<$<C_COMPILER_ID:MSVC>:${CMAKE_CURRENT_SOURCE_DIR}/Compiler/MSVC>
    # $<$<C_COMPILER_ID:Renesas>:${CMAKE_CURRENT_SOURCE_DIR}/Compiler/Renesas>
)

target_compile_options( freertos_plus_tcp_port
  PRIVATE
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-cast-align>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-extra-semi>
    $<$<COMPILE_LANG_AND_ID:C,GNU>:-Wno-pedantic> # Strange definition for STATIC_ASSERT
)

target_link_libraries( freertos_plus_tcp_port
  PRIVATE
    freertos_kernel
    freertos_plus_tcp
    freertos_plus_tcp_network_if
)

#------------------------------------------------------------------------------
if (FREERTOS_PLUS_TCP_NETWORK_IF STREQUAL "A_CUSTOM_NETWORK_IF")
    message(STATUS "Using a custom FREERTOS_PLUS_TCP_NETWORK_IF.")
    return()
endif()

add_library( freertos_plus_tcp_network_if STATIC )
add_library( FreeRTOS::PlusTCP::NetworkIF ALIAS freertos_plus_tcp_network_if )

target_sources( freertos_plus_tcp_network_if
  PRIVATE
    NetworkInterface/Common/phyHandling.c
    NetworkInterface/include/phyHandling.h

    #$<$<STREQUAL:${FREERTOS_PLUS_TCP_NETWORK_IF},ATSAM4E>:> # TODO
    $<$<STREQUAL:${FREERTOS_PLUS_TCP_NETWORK_IF},ATSAME5x>:
        NetworkInterface/ATSAME5x/NetworkInterface.c>
    $<$<STREQUAL:${FREERTOS_PLUS_TCP_NETWORK_IF},DRIVER_SAM>:
        NetworkInterface/DriverSAM/gmac_SAM.c
        NetworkInterface/DriverSAM/gmac_SAM.h
        NetworkInterface/DriverSAM/NetworkInterface.c>
    $<$<STREQUAL:${FREERTOS_PLUS_TCP_NETWORK_IF},ESP32>:
        NetworkInterface/esp32/NetworkInterface.c>
    $<$<STREQUAL:${FREERTOS_PLUS_TCP_NETWORK_IF},KSZ8851SNL>:
        NetworkInterface/ksz8851snl/ksz8851snl_reg.h
        NetworkInterface/ksz8851snl/ksz8851snl.c
        NetworkInterface/ksz8851snl/ksz8851snl.h
        NetworkInterface/ksz8851snl/NetworkInterface.c>
    $<$<STREQUAL:${FREERTOS_PLUS_TCP_NETWORK_IF},POSIX>:
        NetworkInterface/linux/NetworkInterface.c>
    $<$<STREQUAL:${FREERTOS_PLUS_TCP_NETWORK_IF},LPC17xx>:
        NetworkInterface/LPC17xx/NetworkInterface.c>
    $<$<STREQUAL:${FREERTOS_PLUS_TCP_NETWORK_IF},LPC18xx>:
        NetworkInterface/LPC18xx/NetworkInterface.c>
    $<$<STREQUAL:${FREERTOS_PLUS_TCP_NETWORK_IF},LPC54018>:
        NetworkInterface/LPC54018/NetworkInterface.c>
    $<$<STREQUAL:${FREERTOS_PLUS_TCP_NETWORK_IF},M487>:
        NetworkInterface/M487/m480_eth.c
        NetworkInterface/M487/m480_eth.h
        NetworkInterface/M487/NetworkInterface.c>
    # $<$<STREQUAL:${FREERTOS_PLUS_TCP_NETWORK_IF},MPS2_AN385>:> # TODO
    $<$<STREQUAL:${FREERTOS_PLUS_TCP_NETWORK_IF},MW300_RD>:
        NetworkInterface/mw300_rd/NetworkInterface.c>
    # $<$<STREQUAL:${FREERTOS_PLUS_TCP_NETWORK_IF},PIC32MZEF_ETH>:> # TODO
    # $<$<STREQUAL:${FREERTOS_PLUS_TCP_NETWORK_IF},PIC32MZEF_WIFI>:> # TODO
    $<$<STREQUAL:${FREERTOS_PLUS_TCP_NETWORK_IF},RX>:
        NetworkInterface/RX/ether_callback.c
        NetworkInterface/RX/NetworkInterface.c>
    $<$<STREQUAL:${FREERTOS_PLUS_TCP_NETWORK_IF},SH2A>:
        NetworkInterface/SH2A/NetworkInterface.c>
    # $<$<STREQUAL:${FREERTOS_PLUS_TCP_NETWORK_IF},STM32FXX>:> # TODO
    # $<$<STREQUAL:${FREERTOS_PLUS_TCP_NETWORK_IF},STM32HXX>:> # TODO
    $<$<STREQUAL:${FREERTOS_PLUS_TCP_NETWORK_IF},MSP432>:
        NetworkInterface/ThirdParty/MSP432/NetworkInterface.c
        NetworkInterface/ThirdParty/MSP432/NetworkInterface.h
        NetworkInterface/ThirdParty/MSP432/NetworkMiddleware.c
        NetworkInterface/ThirdParty/MSP432/NetworkMiddleware.h>
    $<$<STREQUAL:${FREERTOS_PLUS_TCP_NETWORK_IF},TM4C>:
        NetworkInterface/TM4C/NetworkInterface.c>
    $<$<STREQUAL:${FREERTOS_PLUS_TCP_NETWORK_IF},WIN_PCAP>:
        NetworkInterface/WinPCAP/FaultInjection.c
        NetworkInterface/WinPCAP/NetworkInterface.c>
    $<$<STREQUAL:${FREERTOS_PLUS_TCP_NETWORK_IF},XILINX_ULTRASCALE>:
        NetworkInterface/xilinx_ultrascale/NetworkInterface.c
        NetworkInterface/xilinx_ultrascale/readme.md
        NetworkInterface/xilinx_ultrascale/uncached_memory.c
        NetworkInterface/xilinx_ultrascale/uncached_memory.h
        NetworkInterface/xilinx_ultrascale/x_emacpsif_dma.c
        NetworkInterface/xilinx_ultrascale/x_emacpsif_hw.c
        NetworkInterface/xilinx_ultrascale/x_emacpsif_hw.h
        NetworkInterface/xilinx_ultrascale/x_emacpsif_physpeed.c
        NetworkInterface/xilinx_ultrascale/x_emacpsif.h
        NetworkInterface/xilinx_ultrascale/x_topology.h>
    $<$<STREQUAL:${FREERTOS_PLUS_TCP_NETWORK_IF},ZYNQ>:
        NetworkInterface/Zynq/NetworkInterface.c
        NetworkInterface/Zynq/README.txt
        NetworkInterface/Zynq/uncached_memory.c
        NetworkInterface/Zynq/uncached_memory.h
        NetworkInterface/Zynq/x_emacpsif_dma.c
        NetworkInterface/Zynq/x_emacpsif_hw.c
        NetworkInterface/Zynq/x_emacpsif_hw.h
        NetworkInterface/Zynq/x_emacpsif_physpeed.c
        NetworkInterface/Zynq/x_emacpsif.h
        NetworkInterface/Zynq/x_topology.h>
)

if( FREERTOS_PLUS_TCP_NETWORK_IF STREQUAL "POSIX")
find_package(PCAP REQUIRED)
endif()


target_include_directories( freertos_plus_tcp_network_if
  PUBLIC
    freertos_plus_tcp_port # For compiler pragmas.
    NetworkInterface/include
  PRIVATE
    # $<$<STREQUAL:${FREERTOS_PLUS_TCP_NETWORK_IF},ATSAM4E:${CMAKE_CURRENT_SOURCE_DIR}/> #TODO
    $<$<STREQUAL:${FREERTOS_PLUS_TCP_NETWORK_IF},DRIVER_SAM>:${CMAKE_CURRENT_SOURCE_DIR}/NetworkInterface/DriverSAM>
    $<$<STREQUAL:${FREERTOS_PLUS_TCP_NETWORK_IF},KSZ8851SNL>:${CMAKE_CURRENT_SOURCE_DIR}/NetworkInterface/ksz8851snl>
    $<$<STREQUAL:${FREERTOS_PLUS_TCP_NETWORK_IF},M487>:${CMAKE_CURRENT_SOURCE_DIR}/NetworkInterface/M487>
    # $<$<STREQUAL:${FREERTOS_PLUS_TCP_NETWORK_IF},MPS2_AN385>:${CMAKE_CURRENT_SOURCE_DIR}/> #TODO
    $<$<STREQUAL:${FREERTOS_PLUS_TCP_NETWORK_IF},STM32FXX>:${CMAKE_CURRENT_SOURCE_DIR}/NetworkInterface/STM32Fxx>
    $<$<STREQUAL:${FREERTOS_PLUS_TCP_NETWORK_IF},STM32HXX>:${CMAKE_CURRENT_SOURCE_DIR}/NetworkInterface/STM32Hxx>
    $<$<STREQUAL:${FREERTOS_PLUS_TCP_NETWORK_IF},MSP432>:${CMAKE_CURRENT_SOURCE_DIR}/NetworkInterface/ThirdParty/MSP432>
    $<$<STREQUAL:${FREERTOS_PLUS_TCP_NETWORK_IF},XILINX_ULTRASCALE>:${CMAKE_CURRENT_SOURCE_DIR}/NetworkInterface/xilinx_ultrascale>
    $<$<STREQUAL:${FREERTOS_PLUS_TCP_NETWORK_IF},ZYNQ>:${CMAKE_CURRENT_SOURCE_DIR}/NetworkInterface/Zynq>
)

target_compile_options( freertos_plus_tcp_network_if
  PRIVATE
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-cast-align>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-conditional-uninitialized>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-documentation>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-empty-translation-unit>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-extra-semi-stmt>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-gnu-statement-expression>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-implicit-int-conversion>
    $<$<COMPILE_LANG_AND_ID:C,Clang,GNU>:-Wno-int-to-pointer-cast>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-missing-noreturn>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-missing-prototypes>
    $<$<COMPILE_LANG_AND_ID:C,Clang,GNU>:-Wno-pointer-to-int-cast>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-newline-eof>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-padded>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-shorten-64-to-32>
    $<$<COMPILE_LANG_AND_ID:C,GNU>:-Wno-type-limits>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-undef>
    $<$<COMPILE_LANG_AND_ID:C,Clang,GNU>:-Wno-uninitialized>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-unused-but-set-variable>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-unused-macros>
    $<$<COMPILE_LANG_AND_ID:C,Clang,GNU>:-Wno-unused-parameter>
)

target_link_libraries( freertos_plus_tcp_network_if
  PUBLIC
    freertos_plus_tcp_port
  PRIVATE
    freertos_kernel
    freertos_plus_tcp
    $<$<STREQUAL:${FREERTOS_PLUS_TCP_NETWORK_IF},POSIX>:${PCAP_LIBRARY}>
)
