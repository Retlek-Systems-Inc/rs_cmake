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
# CMake Definition for backoffalgorithm until supported in this repo

add_library(freertos_backoffalgorithm STATIC )
add_library(FreeRTOS::backoffAlgorithm ALIAS freertos_backoffalgorithm )

target_sources(freertos_backoffalgorithm
  PRIVATE
    source/include/backoff_algorithm.h
    source/backoff_algorithm.c
)

target_compile_options(freertos_backoffalgorithm
  PRIVATE
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-padded>
)

target_include_directories(freertos_backoffalgorithm
  PUBLIC
    source/include
)
