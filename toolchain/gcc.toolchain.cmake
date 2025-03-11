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

find_program(GCC_C 
    NAMES
        gcc-14
        gcc-13
        gcc-12
        gcc-11
        gcc-10
        gcc-9
        gcc-8
        gcc-7
        gcc-6
        gcc-5
        gcc-4
        gcc
)

find_program(GCC_CXX
    NAMES
        g++-14
        g++-13
        g++-12
        g++-11
        g++-10
        g++-9
        g++-8
        g++-7
        g++-6
        g++-5
        g++-4
        g++
)        

find_program(GCC_GCOV
    NAMES
        gcov-14
        gcov-13
        gcov-12
        gcov-11
        gcov-10
        gcov-9
        gcov-8
        gcov-7
        gcov-6
        gcov-5
        gcov-4
        gcov
)

set(CMAKE_C_COMPILER_ID GNU )
set(CMAKE_C_COMPILER ${GCC_C})
set(CMAKE_CXX_COMPILER_ID GNU )
set(CMAKE_CXX_COMPILER ${GCC_CXX})
set(GNU_COVERAGE_TOOL ${GCC_GCOV} CACHE FILEPATH "GNU Coverage tool location")
