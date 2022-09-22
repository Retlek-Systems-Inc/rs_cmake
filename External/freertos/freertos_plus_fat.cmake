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
# CMake Definition for FreeRTOS Plus-FAT target until supported in this repo

# TODO: Figure out what this is.
option(FREERTOS_PLUS_FAT_CONFIG_DEV "TBD" OFF)

if(NOT FREERTOS_PLUS_FAT_PORT)
    message(FATAL_ERROR " FREERTOS_PLUS_FAT_PORT is not set. Please specify it from top-level CMake file (example):\n"
        "  set(FREERTOS_PLUS_FAT_PORT \"ZYNQ\" CACHE STRING \"\")\n"
        " or from CMake command line option:\n"
        "  -DFREERTOS_PLUS_FAT_PORT=POSIX\n"
        " \n"
        " Available port options:\n"
        " A_CUSTOM_PORT          Target: User Defined\n"
        " ATSAM4E                Target: ATSAM4E - TODO\n"
        " AVR32_UC3              Target: avr32_uc3 - TODO\n"
        " LPC18XX                Target: lpc18xx - TODO\n"
        " STM32FXX               Target: STM32Fxx   - TODO\n"
        " STM32HXX               Target: STM32Hxx - TODO\n"
        " ZYNQ                   Target: Xilinx Zynq - TODO\n"
        " ZYNQ_2019_3            Target: Xilinx Zynq 2019.3")
elseif((FREERTOS_PLUS_FAT_PORT STREQUAL "A_CUSTOM_PORT") AND (NOT TARGET freertos_plus_fat_port) )
    message(FATAL_ERROR " FREERTOS_PLUS_FAT_PORT is set to A_CUSTOM_PORT. Please specify the custom port target with\n"
    " all necessary files. For example, assuming a directory of:\n"
    "  FreeRTOSPlusFatPort/\n"
    "    CMakeLists.txt\n"
    "    ff_sddisk.c\n"
    " Where FreeRTOSPlusFatPort/CMakeLists.txt is a modified version of:\n"
    "   add_library(freertos_plus_fat_port STATIC)\n"
    "   target_sources(freertos_plus_fat_port\n"
    "     PRIVATE\n"
    "       ff_sddisk.c)\n"
    "   target_link_libraries(freertos_plus_fat_port\n"
    "     PRIVATE\n"
    "       freertos_kernel\n"
    "       freertos_plus_fat)")
endif()

add_library( freertos_plus_fat STATIC )
add_library( FreeRTOS::PlusFAT ALIAS freertos_plus_fat)

target_sources( freertos_plus_fat
  PRIVATE
    include/ff_crc.h
    include/ff_devices.h
    include/ff_dir.h
    include/ff_error.h
    include/ff_fat.h
    include/ff_fatdef.h
    include/ff_file.h
    include/ff_format.h
    include/ff_headers.h
    include/ff_ioman.h
    include/ff_locking.h
    include/ff_memory.h
    include/ff_old_config_defines.h
    include/ff_stdio.h
    include/ff_string.h
    include/ff_sys.h
    include/ff_time.h
    include/FreeRTOS_errno_FAT.h
    include/FreeRTOSFATConfigDefaults.h

    ff_crc.c
    $<$<BOOL:${FREERTOS_PLUS_FAT_CONFIG_DEV}>:ff_dev_support.c>
    ff_dir.c
    ff_error.c
    ff_fat.c
    ff_file.c
    ff_format.c
    ff_ioman.c
    ff_locking.c
    ff_memory.c
    ff_stdio.c
    ff_string.c
    ff_sys.c
    ff_time.c
)

target_include_directories( freertos_plus_fat SYSTEM
  PUBLIC
    include
    portable/common # for ff_sddisk.h (this shouldn't be here)
)

target_compile_options( freertos_plus_fat
  PRIVATE
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-cast-qual>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-constant-conversion>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-covered-switch-default>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-documentation-unknown-command>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-documentation>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-extra-semi-stmt>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-format>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-implicit-int-conversion>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-missing-variable-declarations>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-padded>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-reserved-macro-identifier>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-shorten-64-to-32>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-sign-conversion>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-tautological-constant-out-of-range-compare>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-undef>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-unused-macros>
)

target_link_libraries( freertos_plus_fat
  PUBLIC
    FreeRTOS::Config
  PRIVATE
    freertos_plus_fat_port
    freertos_kernel
)

add_subdirectory(portable)
