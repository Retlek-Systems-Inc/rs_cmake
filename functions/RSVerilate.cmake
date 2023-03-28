#######################################################################
# @copyright 2022 Retlek Systems Inc.
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
#[=======================================================================[.rst:
RSVerilate
----------------

Creates a verilated target from verilog and c code.
Based off of: https://github.com/verilator/verilator/blob/v5.006/verilator-config.cmake.in
And fixes following issues:
* Ability to run verilator at the build stage and not the generate stage of cmake
  * Remove need to consume a local cmake file in the generated directory
  * Add Custom target GenerateVerilatedCode to have verilated code be able to execute on its own
    two stage run of build cmake due to FILE GLOB being updated, but if file names don't change and the
    files are regenerated - this is reduced to 1.
* Ability to have file changes re-run the verilator function
  * TODO: Sub modules still may not cause this to happen - i.e. files from include
* Ability to clean out generated files with clean
* Removal of superfulous properties - all defined in compile_definitions of verilator base
* Missing checks for invalid configuration between Verilator::base and VERILATOR_ARGS
* General clean-up

RSVerilate has the same function args as verilate() in the verilator-config.cmake.in for v4.222

RSVerilate(
    TARGET <target name to verilate>
    SOURCES <source file> [<source file> ...]
    [DEPS  <dependencies> [<dependencies> ...]]
    [COVERAGE]  - deprecated - moved to External variable to be same as Verilator::base
    [TRACE]     - deprecated - moved to External variable to be same as Verilator::base
    [TRACE_FST] - deprecated - moved to External variable to be same as Verilator::base
    [SYSTEMC]   - deprecated - moved to External variable to be same as Verilator::base
    [TRACE_STRUCTS]
    [PREFIX <prefix string>] - default is "V"
    [TOP_MODULE <top module>]
    [TRACE_THREADS <number of threads>]

    [VERILATOR_ARGS <args>]
    [INCLUDE_DIRS <dir> [<dir> ...]]
    [OPT_SLOW <slow arg> [<arg> ...]]
    [OPT_FAST <fast arg> [<arg> ...]]
    [OPT_GLOBAL ...] - deprecated - using Verilator::base

Note the first source file identifies the top level module to verilate.

External Variables :
   VERILATOR_BIN - binary for executing verilate_bin exe.

  In FindVerilogTest which uses these for Verilator::base
   VERILATOR_COVERAGE - enable Coverage
   VERILATOR_SYSTEMC - enable SystemC
   VERILATOR_TRACE_VCD - enable for trace via VCD
   VERILATOR_TRACE_FST - enable for trace via FST
#]=======================================================================]

define_property(TARGET
  PROPERTY VERILATOR_VERILOG_SOURCES
  BRIEF_DOCS "Verilator verilog sources"
  FULL_DOCS "Verilator verilog sources"
)

define_property(TARGET
  PROPERTY VERILATOR_C_SOURCES
  BRIEF_DOCS "Verilator c sources"
  FULL_DOCS "Verilator c sources"
)

define_property(TARGET
  PROPERTY VERILATOR_VERILOG_INCLUDES
  BRIEF_DOCS "Verilator verilog includes"
  FULL_DOCS "Verilator verilog includes"
)

function(RSVerilate TARGET)
  cmake_parse_arguments(VERILATE "TRACE_STRUCTS"
                                 "PREFIX;TOP_MODULE;TRACE_THREADS;DIRECTORY"
                                 "SOURCES;VERILATOR_ARGS;INCLUDE_DIRS;DEPS;OPT_SLOW;OPT_FAST;OPT_GLOBAL"
                                 ${ARGN})
  if (NOT TARGET ${TARGET})
    message(FATAL_ERROR "rs_verilate target '${TARGET}' not found")
  endif()

  if (NOT VERILATE_SOURCES)
    message(FATAL_ERROR "Need at least one source")
  endif()

  if (NOT VERILATE_PREFIX)
    if (VERILATE_TOP_MODULE)
      set(VERILATE_PREFIX V${VERILATE_TOP_MODULE})
    else()
      list(GET VERILATE_SOURCES 0 TOPSRC)
      get_filename_component(_SRC_NAME ${TOPSRC} NAME_WE)
      set(VERILATE_PREFIX V${_SRC_NAME})
    endif()
  endif()

  if (VERILATE_TOP_MODULE)
    list(APPEND VERILATOR_ARGS --top ${VERILATE_TOP_MODULE})
  endif()

  if (VERILATE_TRACE_THREADS)
    list(APPEND VERILATOR_ARGS --trace-threads ${VERILATE_TRACE_THREADS})
  endif()

  if (VERILATOR_COVERAGE)
    list(APPEND VERILATOR_ARGS --coverage)
  endif()

  # Note TRACE and TRACE_FST also checked in verilate args
  if (VERILATOR_TRACE_VCD AND VERILATOR_TRACE_FST)
    message(FATAL_ERROR "Cannot have both TRACE_VCD and TRACE_FST")
  endif()

  if (VERILATOR_TRACE_VCD)
    list(APPEND VERILATOR_ARGS --trace)
  endif()

  if (VERILATOR_TRACE_FST)
    list(APPEND VERILATOR_ARGS --trace-fst)
  endif()

  if (VERILATOR_SYSTEMC)
    list(APPEND VERILATOR_ARGS --sc)
  else()
    list(APPEND VERILATOR_ARGS --cc)
  endif()

  if (VERILATE_TRACE_STRUCTS)
      list(APPEND VERILATOR_ARGS --trace-structs)
  endif()


  # Separate out the USER C/CPP classes
  set (VERILATOR_C_SOURCES "")
  set (VERILATOR_VERILOG_SOURCES "")
  set (VERILATOR_VERILOG_INCLUDES "")
  foreach( _SRC ${VERILATE_SOURCES})
    get_filename_component(_SRC_ABSOLUTE ${_SRC} ABSOLUTE)
    get_filename_component(_SRC_EXT ${_SRC} EXT)
    if (_SRC_EXT MATCHES "(cpp|c)")
      list(APPEND VERILATOR_C_SOURCES ${_SRC_ABSOLUTE})
    else()
      list(APPEND VERILATOR_VERILOG_SOURCES ${_SRC_ABSOLUTE})
    endif()
  endforeach()

  foreach( _INC ${VERILATE_INCLUDE_DIRS})
    get_filename_component(_INC_ABSOLUTE ${_INC} ABSOLUTE)
    list(APPEND VERILATOR_VERILOG_INCLUDES ${_INC_ABSOLUTE})
  endforeach()

  # Now add all of the dependencies' verilator verilog sources, verilog includes, and c sources.
  foreach( _DEP ${VERILATE_DEPS})
    if (NOT TARGET ${_DEP})
      message(FATAL_ERROR "Unknown dependency for ${TARGET} : ${_DEP}")
    endif()

    get_target_property(_DEP_C_SOURCES ${_DEP} VERILATOR_C_SOURCES)
    if (_DEP_C_SOURCES)
      list(APPEND VERILATOR_C_SOURCES ${_DEP_C_SOURCES})
    endif()

    get_target_property(_DEP_VERILOG_SOURCES ${_DEP} VERILATOR_VERILOG_SOURCES)
    if (_DEP_VERILOG_SOURCES)
      list(APPEND VERILATOR_VERILOG_SOURCES ${_DEP_VERILOG_SOURCES})
    endif()

    get_target_property(_DEP_VERILOG_INCLUDES ${_DEP} VERILATOR_VERILOG_INCLUDES)
    if (_DEP_VERILOG_INCLUDES)
      list(APPEND VERILATOR_VERILOG_INCLUDES ${_DEP_VERILOG_INCLUDES})
    endif()
  endforeach()

  list(REMOVE_DUPLICATES VERILATOR_VERILOG_SOURCES)
  list(REMOVE_DUPLICATES VERILATOR_C_SOURCES)
  list(REMOVE_DUPLICATES VERILATOR_VERILOG_INCLUDES)


  set_target_properties( ${TARGET}
    PROPERTIES
      VERILATOR_VERILOG_SOURCES "${VERILATOR_VERILOG_SOURCES}"
      VERILATOR_C_SOURCES "${VERILATOR_C_SOURCES}"
      VERILATOR_VERILOG_INCLUDES "${VERILATOR_VERILOG_INCLUDES}")


  foreach(INC ${VERILATOR_VERILOG_INCLUDES})
    list(APPEND VERILATOR_ARGS -y "${INC}")
  endforeach()

  # TODO(phelter): Investigate why this is needed.
  # Don't think it is necessary if we have this generate the type and the compiler is just
  # whatever was identified in the global cmake file.
  string(TOLOWER ${CMAKE_CXX_COMPILER_ID} COMPILER)
  if (COMPILER STREQUAL "appleclang")
    set(COMPILER clang)
  elseif (NOT COMPILER MATCHES "^msvc$|^clang$")
    set(COMPILER gcc)
  endif()

  get_target_property(BINARY_DIR "${TARGET}" BINARY_DIR)
  get_target_property(TARGET_NAME "${TARGET}" NAME)
  set(VDIR "${BINARY_DIR}/CMakeFiles/${TARGET_NAME}.dir/${VERILATE_PREFIX}.dir")

  if (VERILATE_DIRECTORY)
    set(VDIR "${VERILATE_DIRECTORY}")
  endif()

  file(MAKE_DIRECTORY ${VDIR})

  set(VERILATOR_COMMAND_ARGS
    --compiler ${COMPILER}
    --prefix ${VERILATE_PREFIX}
    --Mdir ${VDIR}
    --make cmake
    ${VERILATOR_ARGS}
    ${VERILATE_VERILATOR_ARGS}
    ${VERILATOR_VERILOG_SOURCES}
    ${VERILATOR_C_SOURCES})

  # Now that all the args are combined - check validity of VERILATOR_COMMAND_ARGS relative to Verilator::base
  # Note most of these could be removed if the Verilator::base code removed the #defines and used templated params
  # for these and/or supported same API but multiple implementations - most of the code is just removing code execution
  # could do selective execution based on templated params
  if (NOT VERILATOR_COVERAGE AND ("--coverage" IN_LIST VERILATOR_COMMAND_ARGS))
    message(FATAL_ERROR "Coverage added in verilate args when not enabled")
  endif()
  if (NOT VERILATOR_SYSTEMC AND ("--sc" IN_LIST VERILATOR_COMMAND_ARGS))
    message(FATAL_ERROR "SystemC added in verilate args when not enabled")
  endif()
  if (NOT VERILATOR_TRACE_VCD AND ("--trace" IN_LIST VERILATOR_COMMAND_ARGS))
    message(FATAL_ERROR "trace (VCD) added in verilate args when not enabled")
  endif()
  if (NOT VERILATOR_TRACE_FST AND ("--trace-fst" IN_LIST VERILATOR_COMMAND_ARGS))
    message(FATAL_ERROR "trace (FST) added in verilate args when not enabled")
  endif()
  if (("--trace" IN_LIST VERILATOR_COMMAND_ARGS) AND ("--trace-fst" IN_LIST VERILATOR_COMMAND_ARGS))
    message(FATAL_ERROR "Cannot have both --trace and --trace-fst")
  endif()

  add_custom_command(
    OUTPUT
      ${VDIR}/${VERILATE_PREFIX}.h
      ${VDIR}/${VERILATE_PREFIX}.cpp
      # Note there are others and they are all defined in ${VDIR}/${VERILATE_PREFIX}__ver.d
      # using file(GLOB ... CONFIGURE_DEPENDS ...) to get full list below
    BYPRODUCTS
      ${VDIR}/${VERILATE_PREFIX}__ver.d
      ${VDIR}/${VERILATE_PREFIX}__verFiles.dat
      ${VDIR}/${VERILATE_PREFIX}.cmake
    COMMAND ${VERILATOR_BIN}
    ARGS    ${VERILATOR_COMMAND_ARGS}
    WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
    DEPENDS
      # TODO(phelter): Expand this to all sources used - included files as well - this will allow
      # the proper update of a verilog file to regenerate the associated output.
      ${VERILATE_SOURCES}
    COMMENT "Executing Verilator... ${VERILATE_PREFIX}"
  )
  # Not used - except for debug
  set(VARGS_FILE "${VDIR}/verilator_args.txt")
  file(WRITE "${VARGS_FILE}" "${VERILATOR_BIN} ${VERILATOR_COMMAND_ARGS}")


  # Re-creating cmake based on settings - no need to use the one in that directory.
  # Based on verilator output from verilator 4.222
  # No need for <PREFIX>_USER_CFLAGS - done using target_compile_options after RSVerilate
  # No need for <PREFIX>_USER_LDLIBS - done using target_link_libraries after RSVerilate

  # No need for <PREFIX>_GLOBAL - done using target_include Verilator::base
  # All files generated in this directory are assumed to be required - CONFIGURE_DEPENDS will ensure
  # any updates cause a new build.
  # This may cause a requirement to run the build twice
  file(GLOB GENERATED_C_SOURCES LIST_DIRECTORIES false
       CONFIGURE_DEPENDS
       ${VDIR}/${VERILATE_PREFIX}_*.cpp
       ${VDIR}/${VERILATE_PREFIX}_*.h)

  # Add the compile flags only on Verilated sources
  target_include_directories(${TARGET}
    PUBLIC
      ${VDIR})

  target_sources(${TARGET}
    PRIVATE
      ${VDIR}/${VERILATE_PREFIX}.h # This links the generation of the add_custom_command above.
      ${VDIR}/${VERILATE_PREFIX}.cpp
      ${GENERATED_C_SOURCES}
      ${VERILATOR_C_SOURCES})

  set_property(
    TARGET ${TARGET}
    APPEND
    PROPERTY ADDITIONAL_CLEAN_FILES ${VDIR})

  # Add the compile flags only on Verilated sources
  file(GLOB GENERATED_C_SLOW_SOURCES LIST_DIRECTORIES false
    ${VDIR}/${VERILATE_PREFIX}_*Slow.cpp
    ${VDIR}/${VERILATE_PREFIX}_*Syms.cpp)

  foreach(_SRC ${GENERATED_C_SOURCES})
    if (_SRC IN_LIST GENERATED_C_SLOW_SOURCES )
      set_property(SOURCE "${_SRC}" APPEND_STRING PROPERTY COMPILE_FLAGS " ${VERILATE_OPT_SLOW}")
    else()
      # OPT_FAST
      set_property(SOURCE "${_SRC}" APPEND_STRING PROPERTY COMPILE_FLAGS " ${VERILATE_OPT_FAST}")
    endif()
  endforeach()
  # Note: Global is part of Verilator::base

  # Note all the VERILATOR_[COVERAGE|SYSTEMC|THREADED|TRACE*] options are added to Verilator::base and
  # compile definitions are set to PUBLIC so when included with link library they will be here too.
  # No need to duplicate them.
  # target_compile_definitions(${TARGET} ...) - See FindVerilogTest.cmake

  # Note the target_link_libraries for Verilator::base are also public so they will migrate to the
  # verilated module as well.
  target_link_libraries( ${TARGET}
    PRIVATE
      Verilator::base
  )

  target_compile_features( ${TARGET} PRIVATE cxx_std_11)

  target_compile_options( ${TARGET}
    PUBLIC
      $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-Wno-inconsistent-missing-destructor-override>
      $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-Wno-suggest-destructor-override>
      $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-Wno-gnu-anonymous-struct>
    PRIVATE
      $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-Wno-bool-operation>
      $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-Wno-missing-prototypes>
      $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-Wno-unreachable-code>
      $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-Wno-used-but-marked-unused>
  )

  target_clang_tidy_definitions( TARGET ${TARGET}
    CHECKS
      -*-braces-around-statements
      -*-magic-numbers
      -*-narrowing-conversions
      -*-static-assert
      -*-use-auto
      -*-use-equals-default
      -*-use-override
      -altera-unroll-loops
      -bugprone-exception-escape
      -bugprone-reserved-identifier
      -cert-dcl37-c
      -cert-dcl51-cpp
      -cert-dcl03-c
      -clang-analyzer-deadcode.DeadStores
      -cppcoreguidelines-explicit-virtual-functions
      -cppcoreguidelines-init-variables
      -cppcoreguidelines-prefer-member-initializer
      -cppcoreguidelines-pro-type-member-init,hicpp-member-init
      -cppcoreguidelines-virtual-class-destructor
      -google-explicit-constructor
      -google-readability-casting
      -hicpp-explicit-conversions
      -hicpp-member-init
      -llvm-include-order
      -modernize-concat-nested-namespaces
      -modernize-make-unique
      -modernize-use-nodiscard
      -readability-convert-member-functions-to-static
      -readability-function-cognitive-complexity
      -readability-identifier-length
      -readability-implicit-bool-conversion
      -readability-inconsistent-declaration-parameter-name
      -readability-simplify-boolean-expr
  )

  # Add target to GenerateVerilatedCode custom target.
  if (NOT TARGET GenerateVerilatedCode)
    add_custom_target(GenerateVerilatedCode)
  endif()
  add_dependencies(GenerateVerilatedCode ${TARGET})

endfunction()

function(RSVerilateUsedBy TARGET)
  cmake_parse_arguments(VERILATE ""
                                 ""
                                 ""
                                 ${ARGN})
  if (NOT TARGET ${TARGET})
    message(FATAL_ERROR "rs_verilate target '${TARGET}' not found")
  endif()

  # Issues in header files generated.
  target_clang_tidy_definitions( TARGET ${TARGET}
    CHECKS
      -*-use-override
      -*-move-const-arg
      -bugprone-exception-escape
      -bugprone-reserved-identifier
      -cert-dcl37-c
      -cert-dcl51-cpp
      -cppcoreguidelines-explicit-virtual-functions
      -cppcoreguidelines-prefer-member-initializer
      -cppcoreguidelines-virtual-class-destructor
      -google-explicit-constructor
      -hicpp-explicit-conversions
      -llvm-include-order
      -modernize-concat-nested-namespaces
      -modernize-use-nodiscard
  )
endfunction()

