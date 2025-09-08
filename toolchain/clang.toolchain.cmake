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


find_program(CLANG_C 
    NAMES
        clang-20
        clang-19
        clang-18
        clang-17
        clang-16
        clang-15
        clang-14
        clang-13
        clang-12
        clang-11
        clang-10
        clang-9
        clang-8
        clang-7
        clang-6.0
        clang-5.0
        clang-4.0
        clang-3.9
        clang
)

find_program(CLANG_CXX
    NAMES
        clang++-20
        clang++-19
        clang++-18
        clang++-17
        clang++-16
        clang++-15
        clang++-14
        clang++-13
        clang++-12
        clang++-11
        clang++-10
        clang++-9
        clang++-8
        clang++-7
        clang++-6.0
        clang++-5.0
        clang++-4.0
        clang++-3.9
        clang++
)        

set(CMAKE_C_COMPILER ${CLANG_C} CACHE FILEPATH "C compiler")
set(CMAKE_CXX_COMPILER ${CLANG_CXX} CACHE FILEPATH "C++ compiler")
