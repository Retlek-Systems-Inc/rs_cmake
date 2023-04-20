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

include(CMakeForceCompiler)

set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR ARM)
set(TOOLCHAIN_TRIPPLE arm-none-eabi)

# Assuming toolchain installed in /usr/local - search newest first.
set(TOOLCHAIN_LOCATION "/usr/local/arm-gnu-toolchain-12.2.mpacbti-rel1-x86_64-${TOOLCHAIN_TRIPPLE}")
set(TOOLCHAIN_PATH ${TOOLCHAIN_LOCATION} CACHE INTERNAL "Toolchain Location.")

set(TOOLCHAIN_BIN_DIR ${TOOLCHAIN_PATH}/bin)
# set(TOOLCHAIN_INC_DIR ${TOOLCHAIN_PATH}/${TOOLCHAIN_TRIPPLE}/include)
# set(TOOLCHAIN_LIB_DIR ${TOOLCHAIN_PATH}/${TOOLCHAIN_TRIPPLE}/lib)


find_program(TOOLCHAIN_C   NAMES ${TOOLCHAIN_TRIPPLE}-gcc
	PATHS ${TOOLCHAIN_BIN_DIR}
	DOC "arm-gcc Toolchain C compiler executable" )
find_program(TOOLCHAIN_CXX NAMES ${TOOLCHAIN_TRIPPLE}-g++
    PATHS ${TOOLCHAIN_BIN_DIR}
    DOC "arm-gcc Toolchain CXX compiler executable" )
find_program(TOOLCHAIN_OBJCOPY   NAMES ${TOOLCHAIN_TRIPPLE}-objcopy
    PATHS ${TOOLCHAIN_BIN_DIR}
    DOC "arm-gcc Toolchain Object copy executable" )
find_program(TOOLCHAIN_SIZE_TOOL NAMES ${TOOLCHAIN_TRIPPLE}-size
    PATHS ${TOOLCHAIN_BIN_DIR}
    DOC "arm-gcc Toolchain size tool executable" )

set(CMAKE_C_COMPILER ${TOOLCHAIN_C})
set(CMAKE_ASM_COMPILER ${TOOLCHAIN_C})
set(CMAKE_CXX_COMPILER ${TOOLCHAIN_CXX})

# set(CMAKE_C_COMPILER_TARGET ${TOOLCHAIN_C})
# set(CMAKE_CXX_COMPILER_TARGET ${TOOLCHAIN_CXX})

# Without that flag CMake is not able to pass test compilation check
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

set(CMAKE_LINKER    ${TOOLCHAIN_C})
set(CMAKE_OBJCOPY   ${TOOLCHAIN_OBJCOPY}   CACHE INTERNAL "Toolchain Object Copy tool")
set(CMAKE_SIZE_TOOL ${TOOLCHAIN_SIZE_TOOL} CACHE INTERNAL "Toolchain Size Tool")

SET(CMAKE_FIND_ROOT_PATH "${TOOLCHAIN_PATH}/${TOOLCHAIN_TRIPPLE}" )
SET(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
SET(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
SET(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
