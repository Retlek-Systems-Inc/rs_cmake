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
# Add coreSNTP Lib

add_library(freertos_coresntp STATIC )
add_library(FreeRTOS::coreSNTP ALIAS freertos_coresntp )

target_sources(freertos_coresntp
  PRIVATE
    source/include/core_sntp_client.h
    source/include/core_sntp_config_defaults.h
    source/include/core_sntp_serializer.h

    source/core_sntp_client.c
    source/core_sntp_serializer.c
)

target_compile_options(freertos_coresntp
  PRIVATE
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-documentation-pedantic>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-documentation>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-padded>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-switch-enum>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-unused-macros>
)

target_include_directories(freertos_coresntp
  PUBLIC
    source/include
)

target_link_libraries(freertos_coresntp
  PUBLIC
    FreeRTOS::Config
)

