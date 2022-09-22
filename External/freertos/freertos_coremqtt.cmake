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
# CMake Definition for coreMQTT target until supported in this repo

add_library(freertos_coremqtt STATIC )
add_library(FreeRTOS::coreMQTT ALIAS freertos_coremqtt )

target_sources(freertos_coremqtt
  PRIVATE
    source/include/core_mqtt_config_defaults.h
    source/include/core_mqtt_serializer.h
    source/include/core_mqtt_state.h
    source/include/core_mqtt.h
    source/interface/transport_interface.h
    source/core_mqtt_serializer.c
    source/core_mqtt_state.c
    source/core_mqtt.c
)

target_compile_options(freertos_coremqtt
  PRIVATE
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-cast-qual>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-covered-switch-default>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-documentation-pedantic>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-documentation-unknown-command>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-documentation>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-gnu-zero-variadic-macro-arguments>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-gnu-statement-expression>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-gnu-zero-variadic-macro-arguments>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-string-compare>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-unused-value>
    $<$<COMPILE_LANG_AND_ID:C,Clang>:-Wno-padded>
)

target_include_directories(freertos_coremqtt
  PUBLIC
    source/include
    source/interface
)

target_link_libraries(freertos_coremqtt
  PUBLIC
    FreeRTOS::Config
    FreeRTOS::Logging
)

# TODO(phelter): Add test/cbmc, test/unit-tests
