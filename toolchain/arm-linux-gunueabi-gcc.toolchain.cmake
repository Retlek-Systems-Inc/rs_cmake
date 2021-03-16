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

include(CMakeForceCompiler)

set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR ARM)
set(TOOLCHAIN_TRIPPLE arm-linux-gnueabi)

#find_program(TOOLCHAIN_C   NAMES ${TOOLCHAIN_PREFIX}-gcc )
#get_filename_component(TOOLCHAIN_DIR ${TOOLCHAIN_C} DIRECTORY)

set(CMAKE_C_COMPILER_TARGET ${TOOLCHAIN_TRIPPLE}-gcc)
set(CMAKE_CXX_COMPILER_TARGET ${TOOLCHAIN_TRIPPLE}-g++)


#set(CMAKE_C_FLAGS_INIT   "-B${TOOLCHAIN_DIR}")
#set(CMAKE_CXX_FLAGS_INIT "-B${TOOLCHAIN_DIR}")

# Assuming toolchain installed in /usr/
SET(CMAKE_FIND_ROOT_PATH "/usr/${TOOLCHAIN_TRIPPLE}" )
SET(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
SET(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
SET(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)