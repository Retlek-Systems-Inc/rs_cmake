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

if (FREERTOS_PLUS_FAT_PORT STREQUAL "A_CUSTOM_PORT")
    message(STATUS "Using a custom FREERTOS_PLUS_FAT_PORT.")
    return()
endif()

add_library( freertos_plus_fat_port STATIC )
add_library( FreeRTOS::PlusFAT::Port ALIAS freertos_plus_fat_port )

target_sources( freertos_plus_fat_port
  PRIVATE
    common/ff_ramdisk.c
    common/ff_ramdisk.h
    common/ff_sddisk.h

    $<$<STREQUAL:${FREERTOS_PLUS_FAT_PORT},ATSAM4E:
        ATSAM4E/ff_sddisk_r.c
        ATSAM4E/ff_sddisk.c>
    $<$<STREQUAL:${FREERTOS_PLUS_FAT_PORT},AVR32_UC3:
        avr32_uc3/ff_flush.c
        avr32_uc3/ff_flush.h
        avr32_uc3/ff_locking.c> # TODO
    $<$<STREQUAL:${FREERTOS_PLUS_FAT_PORT},LPC18XX:> # TODO
    $<$<STREQUAL:${FREERTOS_PLUS_FAT_PORT},STM32FXX:> # TODO
    $<$<STREQUAL:${FREERTOS_PLUS_FAT_PORT},STM32HXX:> # TODO
    $<$<STREQUAL:${FREERTOS_PLUS_FAT_PORT},ZYNQ:
        Zynq/ff_sddisk.c
        Zynq/xsdps_g.c
        Zynq/xsdps_hw.h
        Zynq/xsdps_info.c
        Zynq/xsdps_info.h
        Zynq/xsdps_options.c
        Zynq/xsdps_sinit.c
        Zynq/xsdps.c
        Zynq/xsdps.h>
    $<$<STREQUAL:${FREERTOS_PLUS_FAT_PORT},ZYNQ_2019_3:
        Zynq.2019.3/ff_sddisk.c
        Zynq.2019.3/xsdps_g.c
        Zynq.2019.3/xsdps_hw.h
        Zynq.2019.3/xsdps_info.c
        Zynq.2019.3/xsdps_info.h
        Zynq.2019.3/xsdps_options.c
        Zynq.2019.3/xsdps_sinit.c
        Zynq.2019.3/xsdps.c
        Zynq.2019.3/xsdps.h>
#    $<$<STREQUAL:${FREERTOS_PORT},GCC_POSIX>: linux/ff_sddisk.c>

)

target_include_directories( freertos_plus_fat_port
  PUBLIC
    common

    $<$<STREQUAL:${FREERTOS_PLUS_FAT_PORT},AVR32_UC3:avr32_uc3>
    $<$<STREQUAL:${FREERTOS_PLUS_FAT_PORT},LPC18XX:> # TODO
    $<$<STREQUAL:${FREERTOS_PLUS_FAT_PORT},STM32FXX:> # TODO
    $<$<STREQUAL:${FREERTOS_PLUS_FAT_PORT},STM32HXX:> # TODO
    $<$<STREQUAL:${FREERTOS_PLUS_FAT_PORT},ZYNQ:Zynq>
    $<$<STREQUAL:${FREERTOS_PLUS_FAT_PORT},ZYNQ_2019_3:Zynq.2019.3>
)

target_compile_options( freertos_plus_fat_port
  PRIVATE
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-gnu-statement-expression>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-missing-prototypes>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-reserved-macro-identifier>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-shorten-64-to-32>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-sign-conversion>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-unused-parameter>
)

target_link_libraries( freertos_plus_fat_port
  PRIVATE
    freertos_plus_fat
    freertos_kernel
)
