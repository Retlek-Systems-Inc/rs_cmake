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
# CMake Definition for getting mbedtls and compiling with cmake

FetchContent_Declare( mbedtls
  GIT_REPOSITORY https://github.com/Mbed-TLS/mbedtls.git
  GIT_TAG        v2.28.1
)

# Options for MbedTLS CMakeLists.txt

# option(USE_PKCS11_HELPER_LIBRARY "Build mbed TLS with the pkcs11-helper library." OFF)
# option(ENABLE_ZLIB_SUPPORT "Build mbed TLS with zlib library." OFF)
# option(ENABLE_PROGRAMS "Build mbed TLS programs." OFF)
# option(UNSAFE_BUILD "Allow unsafe builds. These builds ARE NOT SECURE." OFF)
# option(MBEDTLS_FATAL_WARNINGS "Compiler warnings treated as errors" ON)
# option(ENABLE_TESTING "Build mbed TLS tests." OFF)
# option(INSTALL_MBEDTLS_HEADERS "Install mbed TLS headers." OFF)
# option(USE_STATIC_MBEDTLS_LIBRARY "Build mbed TLS static library." ON)
# option(USE_SHARED_MBEDTLS_LIBRARY "Build mbed TLS shared library." OFF)
# option(LINK_WITH_PTHREAD "Explicitly link mbed TLS library to pthread." OFF)
# option(LINK_WITH_TRUSTED_STORAGE "Explicitly link mbed TLS library to trusted_storage." OFF)

# -----------------------------------------------------------------------------

FetchContent_GetProperties(mbedtls)
if(NOT mbedtls_POPULATED)
  # Fetch the content using previously declared details
  FetchContent_Populate(mbedtls)

  # Bring the populated content into the build
  add_subdirectory(${mbedtls_SOURCE_DIR} ${mbedtls_BINARY_DIR}) #EXCLUDE_FROM_ALL ?
endif()
#list(APPEND COVERAGE_LCOV_EXCLUDES "${mbedtls_SOURCE_DIR}/*")
target_ignore_static_analysis(TARGET mbedcrypto CLANG_TIDY)
target_ignore_static_analysis(TARGET mbedtls CLANG_TIDY)
target_ignore_static_analysis(TARGET mbedx509 CLANG_TIDY)

# -------------------------------------------------------------------
add_library(mbed::crypto ALIAS mbedcrypto)
target_compile_options( mbedcrypto
  PRIVATE
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-cast-align>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-cast-qual>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-conditional-uninitialized>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-covered-switch-default>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-documentation-unknown-command>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-documentation-deprecated-sync>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-extra-semi-stmt>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-implicit-int-conversion>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-padded>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-reserved-identifier>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-shorten-64-to-32>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-sign-conversion>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-switch-enum>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-unused-macros>
)
# Note Linking to the mbedtls port will ensure the use of the proper config file.
target_link_libraries( mbedcrypto
  PUBLIC
    FreeRTOS::Mbedtls::Port
    mbed::entropy::port     # for entropy definition
)

# -------------------------------------------------------------------
add_library(mbed::tls ALIAS mbedtls)
target_compile_options( mbedtls
  PRIVATE
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-cast-qual>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-covered-switch-default>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-documentation-unknown-command>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-extra-semi-stmt>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-implicit-int-conversion>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-padded>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-reserved-identifier>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-sign-conversion>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-switch-enum>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-unused-macros>
)
target_link_libraries( mbedtls
  PUBLIC
    FreeRTOS::Mbedtls::Port
)

# -------------------------------------------------------------------
add_library(mbed::x509 ALIAS mbedx509)

target_compile_options( mbedx509
  PRIVATE
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-cast-qual>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-documentation-unknown-command>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-extra-semi-stmt>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-implicit-int-conversion>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-padded>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-sign-conversion>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-switch-enum>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-unused-macros>
)
target_link_libraries( mbedx509
  PUBLIC
    FreeRTOS::Mbedtls::Port
)

# -----------------------------------------------------------------------------
if(TARGET mbedtls_test)
target_compile_options( mbedtls_test
  PRIVATE
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-cast-qual>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-documentation-deprecated-sync>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-documentation-unknown-command>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-extra-semi-stmt>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-implicit-int-conversion>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-missing-prototypes>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-padded>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-sign-conversion>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-string-conversion>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-switch-enum>
)
endif()
