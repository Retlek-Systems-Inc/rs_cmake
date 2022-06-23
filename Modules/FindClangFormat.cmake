# @copyright 2017 Retlek Systems Inc.
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

find_program(CLANG_FORMAT
    NAMES
        clang-format
        clang-format-14
        clang-format-13
        clang-format-11
        clang-format-10
        clang-format-9
        clang-format-8
        clang-format-7
        clang-format-6.0
)

if(NOT CLANG_FORMAT)
  message(WARNING "Could not find clang-format, must be installed to update with format.")
  return()
endif()

set(CLANG_FORMAT_CXX_FILE_EXTENSIONS ${CLANG_FORMAT_CXX_FILE_EXTENSIONS} *.cpp *.h *.cxx *.hxx *.hpp *.cc *.ipp)

file(GLOB_RECURSE ALL_SOURCE_FILES ${CLANG_FORMAT_CXX_FILE_EXTENSIONS})
add_custom_target(format
  COMMENT "Reformat source files to match clang-format standard definition"
  COMMAND ${CLANG_FORMAT}
	      -style=file
	      -i
	      ${ALL_SOURCE_FILES}
)