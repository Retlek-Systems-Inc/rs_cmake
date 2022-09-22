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
# CMake Definition for mbedtls port for jitterentropy-library

# Don't bother fetching and configuring unless this is the port

FetchContent_Declare ( jitterentropy
  GIT_REPOSITORY https://github.com/smuellerDD/jitterentropy-library.git
  GIT_TAG        v3.4.1
)

FetchContent_GetProperties(jitterentropy)
if(NOT jitterentropy_POPULATED)
  # Fetch the content using previously declared details
  FetchContent_Populate(jitterentropy)

  # Bring the populated content into the build
  add_subdirectory(${jitterentropy_SOURCE_DIR} ${jitterentropy_BINARY_DIR})
endif()
#list(APPEND COVERAGE_LCOV_EXCLUDES "${mbedtls_SOURCE_DIR}/*")
target_ignore_static_analysis(TARGET jitterentropy CLANG_TIDY)

target_compile_options(jitterentropy
  PRIVATE
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-documentation-unknown-command>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-documentation>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-extra-semi-stmt>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-language-extension-token>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-padded>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-reserved-identifier>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-reserved-macro-identifier>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-unused-macros>
  )

target_compile_options( gcd
  PRIVATE
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-extra-semi-stmt>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-unused-macros>
)
