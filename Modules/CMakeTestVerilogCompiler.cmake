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

# This is based on: https://stackoverflow.com/questions/38293535/generic-rule-from-makefile-to-cmake

# For now just do nothing in here
set(CMAKE_FOO_COMPILER_WORKS 1 CACHE INTERNAL "")


# TODO: Add when need another compiler.

#if(CMAKE_${lang}_COMPILER_FORCED)
#  # The compiler configuration was forced by the user.
#  # Assume the user has configured all compiler information.
#  set(CMAKE_${lang}_COMPILER_WORKS TRUE)
#  return()
#endif()

# TODO: update this to check a simple case.
#set(CMAKE_${lang}_COMPILER_WORKS TRUE)
#return()


#include(CMakeTestCompilerCommon)

# Remove any cached result from an older CMake version.
# We now store this in CMakeVerilogCompiler.cmake.
#unset(CMAKE_${lang}_COMPILER_WORKS CACHE)

# This file is used by EnableLanguage in cmGlobalGenerator to
# determine that that selected Verilog compiler can actually compile
# and link the most basic of programs.   If not, a fatal error
# is set and cmake stops processing commands and will not generate
# any makefiles or projects.
#if(NOT CMAKE_${lang}_COMPILER_WORKS)
#  PrintTestCompilerStatus("Verilog" "")
#  file(WRITE ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeTmp/test${lang}Compiler.sv
#    "module test\n"
#    "\n"
#    "initial begin\n"
#    "  \$display (\"The CMAKE_Verilog_COMPILER ran\"\n"
#    "end\n"
#    "endmodule\n")
#
#  try_compile(CMAKE_${lang}_COMPILER_WORKS ${CMAKE_BINARY_DIR}
#    ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeTmp/test${lang}Compiler.sv
#    OUTPUT_VARIABLE __CMAKE_Verilog_COMPILER_OUTPUT)
  # Move result from cache to normal variable.
#  set(CMAKE_${lang}_COMPILER_WORKS ${CMAKE_${lang}_COMPILER_WORKS})
#  unset(CMAKE_${lang}_COMPILER_WORKS CACHE)
#  set(${lang}_TEST_WAS_RUN 1)
#endif()


#if(NOT CMAKE_${lang}_COMPILER_WORKS)
#  PrintTestCompilerStatus("Verilog" " -- broken")
#  file(APPEND ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeError.log
#    "Determining if the Verilog compiler works failed with "
#    "the following output:\n${__CMAKE_${lang}_COMPILER_OUTPUT}\n\n")
#  string(REPLACE "\n" "\n  " _output "${__CMAKE_${lang}_COMPILER_OUTPUT}")
#  message(FATAL_ERROR "The ${lang} compiler\n  \"${CMAKE_${lang}_COMPILER}\"\n"
#    "is not able to compile a simple test program.\nIt fails "
#    "with the following output:\n  ${_output}\n\n"
#    "CMake will not be able to correctly generate this project.")
#else()
#  if(CXX_TEST_WAS_RUN)
#    PrintTestCompilerStatus("${lang}" " -- works")
#    file(APPEND ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeOutput.log
#      "Determining if the ${lang} compiler works passed with "
#      "the following output:\n${__CMAKE_${lang}_COMPILER_OUTPUT}\n\n")
#  endif()

  # Try to identify the ABI and configure it into CMakeCXXCompiler.cmake
#  include(${CMAKE_ROOT}/Modules/CMakeDetermineCompilerABI.cmake)
#  CMAKE_DETERMINE_COMPILER_ABI(CXX ${CMAKE_ROOT}/Modules/CMakeCXXCompilerABI.cpp)
#  # Try to identify the compiler features
#  include(${CMAKE_ROOT}/Modules/CMakeDetermineCompileFeatures.cmake)
#  CMAKE_DETERMINE_COMPILE_FEATURES(CXX)

  # Re-configure to save learned information.
#  configure_file(
#    ${CMAKE_ROOT}/Modules/CMake${lang}Compiler.cmake.in
#    ${CMAKE_PLATFORM_INFO_DIR}/CMake${lang}Compiler.cmake
#    @ONLY
#    )
#  include(${CMAKE_PLATFORM_INFO_DIR}/CMake${lang}Compiler.cmake)
#
#  if(CMAKE_${lang}_SIZEOF_DATA_PTR)
#    foreach(f ${CMAKE_${lang}_ABI_FILES})
#      include(${f})
#    endforeach()
#    unset(CMAKE_${lang}_ABI_FILES)
#  endif()
#endif()
#
#unset(__CMAKE_${lang}_COMPILER_OUTPUT)
#unset(lang)