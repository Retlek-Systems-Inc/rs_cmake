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
# CMake Definition for generating FreeRTOS builds with necessary components
# Modify this as you see fit.

set(_freertos_cmake_dir ${cmake_SOURCE_DIR}/External/freertos )

FetchContent_Declare( freertos_base
  GIT_REPOSITORY https://github.com/FreeRTOS/FreeRTOS.git
  GIT_TAG        0a46f479b96a4bb3e0e56eb88e98a274f59c80f4 # main branch latest
#   GIT_TAG        202112.00 # Latest tag.
  GIT_SUBMODULES "" # Don't grab any submodules since not latest
  # TODO: Figure out whether it makes sense to extract just specific directories.
)

FetchContent_Declare( freertos_kernel
  GIT_REPOSITORY https://github.com/FreeRTOS/FreeRTOS-Kernel.git
  GIT_TAG        V10.5.0 # One from Vitis is 10.3.0
)

FetchContent_Declare( freertos_plus_tcp
  GIT_REPOSITORY https://github.com/FreeRTOS/FreeRTOS-Plus-TCP.git
  GIT_TAG        V3.0.0
)

FetchContent_Declare( freertos_plus_fat
  GIT_REPOSITORY https://github.com/FreeRTOS/Lab-Project-FreeRTOS-FAT.git
  GIT_TAG        ade8d8da69b8c9fc3e3521fb52b3277db8ee72f6 # master
)

FetchContent_Declare( freertos_coremqtt
  GIT_REPOSITORY https://github.com/FreeRTOS/coreMQTT.git
  GIT_TAG        v1.2.0
)

FetchContent_Declare( freertos_coresntp
  GIT_REPOSITORY https://github.com/FreeRTOS/coreSNTP
  GIT_TAG        v1.1.0
)

FetchContent_Declare( freertos_backoffAlgorithm
  GIT_REPOSITORY https://github.com/FreeRTOS/backoffAlgorithm.git
  GIT_TAG        v1.2.0
)

# -----------------------------------------------------------------------------
# FreeRTOS-Kernel assumes a library freertos_config - this is
# to include the config file dependency.  To minimize dependencies adding a 
# freertos_config target which will act as the common spot for all 
# configuration files that get pulled into each of the modules
add_library(freertos_config INTERFACE)
add_library(FreeRTOS::Config ALIAS freertos_config)

target_include_directories(freertos_config SYSTEM
  INTERFACE
    include
)
target_compile_definitions(freertos_config
  INTERFACE
    projCOVERAGE_TEST=0
)

target_link_libraries(freertos_config
  INTERFACE
    FreeRTOS::PlusTCP::Tools 
    # TODO: THis is a circular dependency required when ipconfigUSE_TCP_MEM_STATS=1 in FreeRTOSIPConfig.h
    # TODO: Why can't the tools be added in FreeRTOS_Sockets.c as a header instead of in the FreeRTOSIPConfig.h file.
)

# -----------------------------------------------------------------------------

# Note using modified cmake files off of 10.5.0 to allow FREERTOS_PORT = A_CUSTOM_PORT
FetchContent_GetProperties(freertos_base)
if(NOT freertos_base_POPULATED)
  # Fetch the content using previously declared details
  FetchContent_Populate(freertos_base)

  configure_file(${_freertos_cmake_dir}/freertos_base.cmake "${freertos_base_SOURCE_DIR}/CMakeLists.txt" COPYONLY)

  # Bring the populated content into the build
  add_subdirectory(${freertos_base_SOURCE_DIR} ${freertos_base_BINARY_DIR})
endif()
# Further modifications for RS CMake.
list(APPEND COVERAGE_LCOV_EXCLUDES "${freertos_base_SOURCE_DIR}/*")

# -----------------------------------------------------------------------------

# Note using modified cmake files off of 10.5.0 to allow FREERTOS_PORT = A_CUSTOM_PORT
FetchContent_GetProperties(freertos_kernel)
if(NOT freertos_kernel_POPULATED)
  # Fetch the content using previously declared details
  FetchContent_Populate(freertos_kernel)

  configure_file(${_freertos_cmake_dir}/freertos_kernel.cmake          "${freertos_kernel_SOURCE_DIR}/CMakeLists.txt" COPYONLY)
  configure_file(${_freertos_cmake_dir}/freertos_kernel_portable.cmake "${freertos_kernel_SOURCE_DIR}/portable/CMakeLists.txt" COPYONLY)

  # Bring the populated content into the build
  add_subdirectory(${freertos_kernel_SOURCE_DIR} ${freertos_kernel_BINARY_DIR})
endif()

# Further modifications for RS CMake.
list(APPEND COVERAGE_LCOV_EXCLUDES "${freertos_kernel_SOURCE_DIR}/*")
target_ignore_static_analysis(TARGET freertos_kernel CLANG_TIDY)
target_ignore_static_analysis(TARGET freertos_kernel_port CLANG_TIDY)

target_compile_options( freertos_kernel
  PRIVATE
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-cast-align>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-covered-switch-default>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-documentation>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-extra-semi-stmt>
    $<$<COMPILE_LANG_AND_ID:C,GNU>:-Wno-int-to-pointer-cast>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-missing-noreturn>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-missing-variable-declarations>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-padded>
    $<$<COMPILE_LANG_AND_ID:C,GNU>:-Wno-pointer-to-int-cast>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-shorten-64-to-32>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-sign-conversion>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-unused-macros>
)
target_compile_options( freertos_kernel_port
  PRIVATE
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-disabled-macro-expansion>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-documentation>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-missing-noreturn>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-missing-variable-declarations>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-padded>
    $<$<COMPILE_LANG_AND_ID:C,GNU>:-Wno-pointer-to-int-cast>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-reserved-macro-identifier>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-sign-conversion>
    $<$<COMPILE_LANG_AND_ID:C,GNU>:-Wno-type-limits>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-unused-macros>
)
add_library( FreeRTOS::Kernel       ALIAS freertos_kernel )
add_library( FreeRTOS::Kernel::Port ALIAS freertos_kernel_port)

# -----------------------------------------------------------------------------

# Use these instead.
FetchContent_GetProperties(freertos_plus_tcp)
if(NOT freertos_plus_tcp_POPULATED)
  # Fetch the content using previously declared details
  FetchContent_Populate(freertos_plus_tcp)
  # Note added level of source here - only compiling the source dir.
  configure_file(${_freertos_cmake_dir}/freertos_plus_tcp.cmake          "${freertos_plus_tcp_SOURCE_DIR}/source/CMakeLists.txt" COPYONLY)
  configure_file(${_freertos_cmake_dir}/freertos_plus_tcp_portable.cmake "${freertos_plus_tcp_SOURCE_DIR}/source/portable/CMakeLists.txt" COPYONLY)
  configure_file(${_freertos_cmake_dir}/freertos_plus_tcp_tools.cmake "${freertos_plus_tcp_SOURCE_DIR}/tools/CMakeLists.txt" COPYONLY)

  # Bring the populated content into the build
  add_subdirectory(${freertos_plus_tcp_SOURCE_DIR}/source ${freertos_plus_tcp_BINARY_DIR}/source)
  add_subdirectory(${freertos_plus_tcp_SOURCE_DIR}/tools ${freertos_plus_tcp_BINARY_DIR}/tools)
endif()
list(APPEND COVERAGE_LCOV_EXCLUDES "${freertos_plus_tcp_SOURCE_DIR}/*")
target_ignore_static_analysis(TARGET freertos_plus_tcp CLANG_TIDY)
target_ignore_static_analysis(TARGET freertos_plus_tcp_port CLANG_TIDY)
target_ignore_static_analysis(TARGET freertos_plus_tcp_network_if CLANG_TIDY)
target_ignore_static_analysis(TARGET freertos_plus_tcp_tools CLANG_TIDY)

# -----------------------------------------------------------------------------

FetchContent_GetProperties(freertos_plus_fat)
if(NOT freertos_plus_fat_POPULATED)
  # Fetch the content using previously declared details
  FetchContent_Populate(freertos_plus_fat)

  configure_file(${_freertos_cmake_dir}/freertos_plus_fat.cmake          "${freertos_plus_fat_SOURCE_DIR}/CMakeLists.txt" COPYONLY)
  configure_file(${_freertos_cmake_dir}/freertos_plus_fat_portable.cmake "${freertos_plus_fat_SOURCE_DIR}/portable/CMakeLists.txt" COPYONLY)

  # Bring the populated content into the build
  add_subdirectory(${freertos_plus_fat_SOURCE_DIR} ${freertos_plus_fat_BINARY_DIR})
endif()
list(APPEND COVERAGE_LCOV_EXCLUDES "${freertos_plus_fat_SOURCE_DIR}/*")
target_ignore_static_analysis(TARGET freertos_plus_fat CLANG_TIDY)
target_ignore_static_analysis(TARGET freertos_plus_fat_port CLANG_TIDY)

# -----------------------------------------------------------------------------

FetchContent_GetProperties(freertos_coremqtt)
if(NOT freertos_coremqtt_POPULATED)
  # Fetch the content using previously declared details
  FetchContent_Populate(freertos_coremqtt)

  configure_file(${_freertos_cmake_dir}/freertos_coremqtt.cmake "${freertos_coremqtt_SOURCE_DIR}/CMakeLists.txt" COPYONLY)

  # Bring the populated content into the build
  add_subdirectory(${freertos_coremqtt_SOURCE_DIR} ${freertos_coremqtt_BINARY_DIR})
endif()
list(APPEND COVERAGE_LCOV_EXCLUDES "${freertos_coremqtt_SOURCE_DIR}/*")
target_ignore_static_analysis(TARGET freertos_coremqtt CLANG_TIDY)

# -----------------------------------------------------------------------------

FetchContent_GetProperties(freertos_coresntp)
if(NOT freertos_coresntp_POPULATED)
  # Fetch the content using previously declared details
  FetchContent_Populate(freertos_coresntp)

  configure_file(${_freertos_cmake_dir}/freertos_coresntp.cmake "${freertos_coresntp_SOURCE_DIR}/CMakeLists.txt" COPYONLY)

  # Bring the populated content into the build
  add_subdirectory(${freertos_coresntp_SOURCE_DIR} ${freertos_coresntp_BINARY_DIR})
endif()
list(APPEND COVERAGE_LCOV_EXCLUDES "${freertos_coresntp_SOURCE_DIR}/*")
target_ignore_static_analysis(TARGET freertos_coresntp CLANG_TIDY)
# config
target_compile_definitions(freertos_coresntp
  PRIVATE
    SNTP_DO_NOT_USE_CUSTOM_CONFIG # Don't use a custom config for now.
)

# -----------------------------------------------------------------------------

FetchContent_GetProperties(freertos_backoffalgorithm)
if(NOT freertos_backoffalgorithm_POPULATED)
  # Fetch the content using previously declared details
  FetchContent_Populate(freertos_backoffalgorithm)

  configure_file(${_freertos_cmake_dir}/freertos_backoffalgorithm.cmake "${freertos_backoffalgorithm_SOURCE_DIR}/CMakeLists.txt" COPYONLY)

  # Bring the populated content into the build
  add_subdirectory(${freertos_backoffalgorithm_SOURCE_DIR} ${freertos_backoffalgorithm_BINARY_DIR})
endif()
list(APPEND COVERAGE_LCOV_EXCLUDES "${freertos_backoffalgorithm_SOURCE_DIR}/*")
target_ignore_static_analysis(TARGET freertos_backoffalgorithm CLANG_TIDY)
