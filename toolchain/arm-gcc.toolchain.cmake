# @copyright 2021 Retlek Systems Inc.
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

set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR arm)

set(CMAKE_SYSTEM_VERSION 1)

if(WIN)
# Note - this is assuming the STM32CubeIDE installed tools are to be used for building.
# This may change if the version of STM32CubeIDE is updated.
set( TOOLCHAIN_LOCATION "C:\ST\STM32CubeIDE_1.0.2\STM32CubeIDE\plugins\com.st.stm32cube.ide.mcu.externaltools.gnu-tools-for-stm32.7-2018-q2-update.win32_1.0.0.201904181610\tools")
endif()

set(TOOLCHAIN_PREFIX arm-none-eabi-)
set(TOOCHAIN_PATH ${TOOLCHAIN_LOCATION} CACHE INTERNAL "Toolchain Location.")

find_program(TOOLCHAIN_C   NAMES ${TOOLCHAIN_PREFIX}gcc
	PATHS ${TOOLCHAIN_PATH}/bin
	DOC "arm-gcc Toolchain C compiler executable" )
find_program(TOOLCHAIN_CXX NAMES ${TOOLCHAIN_PREFIX}g++ 
	PATHS ${TOOLCHAIN_PATH}/bin
	DOC "arm-gcc Toolchain CXX compiler executable" )

get_filename_component(TOOLCHAIN_DIR ${TOOLCHAIN_C} DIRECTORY)
# Without that flag CMake is not able to pass test compilation check
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

set(CMAKE_C_COMPILER ${TOOLCHAIN_C})
set(CMAKE_ASM_COMPILER ${CMAKE_C_COMPILER})
set(CMAKE_CXX_COMPILER ${TOOLCHAIN_CXX})
set(CMAKE_LINKER ${TOOLCHAIN_C})


find_program(TOOLCHAIN_OBJCOPY   NAMES ${TOOLCHAIN_PREFIX}objcopy)
find_program(TOOLCHAIN_SIZE_TOOL NAMES ${TOOLCHAIN_PREFIX}size)

set(CMAKE_OBJCOPY   ${TOOLCHAIN_OBJCOPY}   CACHE INTERNAL "Toolchain Object Copy tool")
set(CMAKE_SIZE_TOOL ${TOOLCHAIN_SIZE_TOOL}      CACHE INTERNAL "Toolchain Size Tool")

set(CMAKE_FIND_ROOT_PATH ${TOOLCHAIN_PATH})
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

set(TOOLCHAIN_COMPILE_OPTIONS --specs=nosys.specs)

function( createBins )
    set( _options )
    set( _oneValueArgs TARGET )
    set( _multiValueArgs )
    include( CMakeParseArguments )
    cmake_parse_arguments( "_arg" "${_options}" "${_oneValueArgs}" "${_multiValueArgs}" ${ARGN} )

    if( _arg_UNPARSED_ARGUMENTS )
        message( FATAL_ERROR "Unknown argument(s) to createBins: ${_arg_UNPARSED_ARGUMENTS}" )
    endif()
    
    if( NOT _arg_TARGET )
        message( FATAL_ERROR "Must specify TARGET <target> to create a bin for" )
    endif()

    if( NOT TARGET ${_arg_TARGET})
        message( FATAL_ERROR "Unknown TARGET <target> to create a bin: ${_arg_TARGET}" )
    endif()
    
    add_custom_command(TARGET ${_arg_TARGET} POST_BUILD
        COMMAND ${CMAKE_OBJCOPY} -O ihex   ${_arg_TARGET} ${_arg_TARGET}.hex
        COMMAND ${CMAKE_OBJCOPY} -O binary ${_arg_TARGET} ${_arg_TARGET}.bin
        COMMAND ${CMAKE_OBJCOPY} -O srec ${_arg_TARGET} ${_arg_TARGET}.s37
        COMMAND ${CMAKE_SIZE_TOOL} ${_arg_TARGET}
        WORKING_DIRECTORY ${CMAKE_CURRENT_BUILD_DIR}
        COMMENT "Creating .bin , .hex, and srec files for ${_arg_TARGET}"
    )
endfunction()


