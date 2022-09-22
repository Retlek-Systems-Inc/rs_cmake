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
# CMake Definition for FreeRTOS components in FreeRTOS/FreeRTOS directory.
# Note: Not everything is currently compiled but adding in what is used
# by RS customers right now.
# Terms:
#  AP = Application Protocol

# Libs:
#  FreeRTOS::AP::socket_wrapper
#  FreeRTOS::AP::tls_wrapper - using mbedtls
#  FreeRTOS::Logging
#  FreeRTOS::Mbedtls::Port


# -------------------------------------------------------------------
# AP = Application Protocol
add_library(freertos_ap_socket_wrapper  STATIC EXCLUDE_FROM_ALL)
add_library(FreeRTOS::AP::socket_wrapper ALIAS freertos_ap_socket_wrapper )

set(_freertos_ap_socket_wrapper_DIR "FreeRTOS-Plus/Source/Application-Protocols/network_transport/sockets_wrapper/freertos_plus_tcp")
target_sources(freertos_ap_socket_wrapper
  PRIVATE
    ${_freertos_ap_socket_wrapper_DIR}/sockets_wrapper.c
    ${_freertos_ap_socket_wrapper_DIR}/sockets_wrapper.h
)

target_compile_options(freertos_ap_socket_wrapper
  PRIVATE
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-comma>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-documentation>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-implicit-function-declaration>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-unused-value>
)

target_include_directories(freertos_ap_socket_wrapper
  PUBLIC
    ${_freertos_ap_socket_wrapper_DIR}
)

target_link_libraries(freertos_ap_socket_wrapper
  PUBLIC
    FreeRTOS::PlusTCP
    FreeRTOS::Logging
  PRIVATE
    FreeRTOS::Kernel
)

# -------------------------------------------------------------------

add_library(freertos_ap_mbedtls_wrapper  STATIC EXCLUDE_FROM_ALL )
add_library(FreeRTOS::AP::tls_wrapper ALIAS freertos_ap_mbedtls_wrapper )

set(_freertos_ap_mbedtls_wrapper_DIR "FreeRTOS-Plus/Source/Application-Protocols/network_transport/using_mbedtls")

target_sources(freertos_ap_mbedtls_wrapper
  PRIVATE
    ${_freertos_ap_mbedtls_wrapper_DIR}/using_mbedtls.c
    ${_freertos_ap_mbedtls_wrapper_DIR}/using_mbedtls.h
)

target_compile_options(freertos_ap_mbedtls_wrapper
  PRIVATE
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-comma>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-documentation>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-implicit-function-declaration>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-shorten-64-to-32>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-unused-value>
)

target_include_directories(freertos_ap_mbedtls_wrapper
  PUBLIC
    ${_freertos_ap_mbedtls_wrapper_DIR}
)

target_link_libraries(freertos_ap_mbedtls_wrapper
  PUBLIC
    freertos_plus_tcp
    freertos_core_mqtt
    $<$<TARGET_EXISTS:mbedtls>:mbed::crypto>
    $<$<TARGET_EXISTS:mbedtls>:mbedtls>
    $<$<TARGET_EXISTS:mbedtls>:mbed::x509>
  PRIVATE
    FreeRTOS::Kernel
    FreeRTOS::AP::socket_wrapper
    FreeRTOS::Mbedtls::Port
)

# -------------------------------------------------------------------
add_library(freertos_logging INTERFACE)
add_library(FreeRTOS::Logging ALIAS freertos_logging )

set(_freertos_logging_DIR "FreeRTOS-Plus/Source/Utilities/logging")
target_include_directories(freertos_logging SYSTEM
  INTERFACE
    ${_freertos_logging_DIR}
)

# -------------------------------------------------------------------
add_library(freertos_mbedtls_port STATIC EXCLUDE_FROM_ALL)
add_library(FreeRTOS::Mbedtls::Port ALIAS freertos_mbedtls_port )

set(_freertos_mbedtls_port_DIR "FreeRTOS-Plus/Source/Utilities/mbedtls_freertos")

target_sources(freertos_mbedtls_port
  PRIVATE
    #${_freertos_mbedtls_port_DIR}/mbedtls_bio_freertos_cellular.c
    ${_freertos_mbedtls_port_DIR}/mbedtls_bio_freertos_plus_tcp.c
    ${_freertos_mbedtls_port_DIR}/mbedtls_freertos_port.c
    ${_freertos_mbedtls_port_DIR}/threading_alt.h
)

target_compile_options(freertos_mbedtls_port
  PRIVATE
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-documentation-pedantic>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-implicit-function-declaration>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-int-conversion>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-unused-macros>
)

target_include_directories(freertos_mbedtls_port
  PUBLIC
    ${_freertos_mbedtls_port_DIR}
)

target_link_libraries(freertos_mbedtls_port
  PUBLIC
    FreeRTOS::Config
    FreeRTOS::Kernel
  PRIVATE
    freertos_ap_socket_wrapper
    $<$<TARGET_EXISTS:mbedtls>:mbedtls>
)

