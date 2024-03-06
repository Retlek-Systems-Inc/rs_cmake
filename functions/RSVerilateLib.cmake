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
RSVerilateLib
----------------

Creates a verilated target from verilog and c code.
Uses standard CMake definitions to define the list of files and directories

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

RSVerilateLib(
    TARGET_DEST <target destination to add all verilated code>
    HDL_TARGET <target containing hdl(verilog) to verilate>
    [TOP_MODULE <top module>]
    [TRACE_STRUCTS]
    [PREFIX <prefix string>] - default is "V"
    [TRACE_THREADS <number of threads>]

    [VERILATOR_ARGS <args>]
    [OPT_SLOW <slow arg> [<arg> ...]]
    [OPT_FAST <fast arg> [<arg> ...]]
)
External Variables :
  VERILATOR_BIN - binary for executing verilate_bin exe.

  In FindVerilogTest which uses these for Verilator::base
    VERILATOR_COVERAGE - enable Coverage
    VERILATOR_SYSTEMC - enable SystemC
    VERILATOR_TRACE_VCD - enable for trace via VCD
    VERILATOR_TRACE_FST - enable for trace via FST


RSVerilateUsedBy( TARGET <target name verilator code is consumed in> 
)
This adds the necessary static analysis bypasses for anything consuming verilated c++ code.

#]=======================================================================]

function(RSVerilateLib TARGET_DEST)
  cmake_parse_arguments(VERILATE "TRACE_STRUCTS"
                                 "HDL_TARGET;PREFIX;TOP_MODULE;TRACE_THREADS"
                                 "VERILATOR_ARGS;OPT_SLOW;OPT_FAST"
                                 ${ARGN})

  if (NOT TARGET ${TARGET_DEST})
    message(FATAL_ERROR "rs_verilate target '${TARGET_DEST}' not found")
  endif()

  if (NOT TARGET ${VERILATE_HDL_TARGET})
  message(FATAL_ERROR "rs_verilate hdl target '${VERILATE_HDL_TARGET}' not found")
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

  if (VERILATE_TRACE_STRUCTS)
      list(APPEND VERILATOR_ARGS --trace-structs)
  endif()

  set(VERILATOR_VERILOG_INCLUDES "$<TARGET_PROPERTY:${VERILATE_HDL_TARGET},INTERFACE_INCLUDE_DIRECTORIES>")

  # TODO(phelter): Investigate why this is needed.
  # Don't think it is necessary if we have this generate the type and the compiler is just
  # whatever was identified in the global cmake file.
  string(TOLOWER ${CMAKE_CXX_COMPILER_ID} COMPILER)
  if (COMPILER STREQUAL "appleclang")
    set(COMPILER clang)
  elseif (NOT COMPILER MATCHES "^msvc$|^clang$")
    set(COMPILER gcc)
  endif()

  get_target_property(BINARY_DIR "${VERILATE_HDL_TARGET}" BINARY_DIR)
  get_target_property(TARGET_NAME "${VERILATE_HDL_TARGET}" NAME)
  set(VDIR "${BINARY_DIR}/CMakeFiles/${TARGET_NAME}.dir/${VERILATE_PREFIX}.dir")

  file(MAKE_DIRECTORY ${VDIR})
  set( VERILATOR_COMMAND_ARGS
    --compiler ${COMPILER}
    --prefix ${VERILATE_PREFIX}
    --Mdir ${VDIR}
    --make cmake
    # Toplevel options for compiling the verilator::base
    $<$<BOOL:${VERILATOR_COVERAGE}>:--coverage>
    $<IF:$<BOOL:${VERILATOR_SYSTEMC}>,--sc,--cc>
    $<$<BOOL:${VERILATOR_TRACE_VCD}>:--trace>
    $<$<BOOL:${VERILATOR_TRACE_FST}>:--trace-fst>

    ${VERILATE_VERILATOR_ARGS}
    ${VERILATOR_ARGS}
  )

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
            "$<$<BOOL:${VERILATOR_VERILOG_INCLUDES}>:-I$<JOIN:${VERILATOR_VERILOG_INCLUDES},;-I>>"
            "$<TARGET_PROPERTY:${VERILATE_HDL_TARGET},INTERFACE_SOURCES>"
    COMMAND_EXPAND_LISTS
    VERBATIM
    WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
    DEPENDS
      $<TARGET_PROPERTY:${VERILATE_HDL_TARGET},INTERFACE_SOURCES>
    COMMENT "Executing Verilator... ${VERILATE_PREFIX}"
  )


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
  target_include_directories(${TARGET_DEST}
    PUBLIC
      ${VDIR})

  target_sources(${TARGET_DEST}
    PRIVATE
      ${VDIR}/${VERILATE_PREFIX}.h # This links the generation of the add_custom_command above.
      ${VDIR}/${VERILATE_PREFIX}.cpp
      ${GENERATED_C_SOURCES}
      ${VERILATOR_C_SOURCES})

  set_property(
    TARGET ${TARGET_DEST}
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
  target_link_libraries( ${TARGET_DEST}
    PRIVATE
      Verilator::base
  )

  target_compile_features( ${TARGET_DEST} PRIVATE cxx_std_11)

  target_compile_options( ${TARGET_DEST}
    PUBLIC
      $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-Wno-inconsistent-missing-destructor-override>
      $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-Wno-suggest-destructor-override>
      $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-Wno-gnu-anonymous-struct>
    PRIVATE
      $<$<COMPILE_LANG_AND_ID:CXX,Clang,GNU>:-Wno-bool-operation>
      $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-Wno-missing-prototypes>
      $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-Wno-missing-variable-declarations>
      $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-Wno-nested-anon-types>
      $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-Wno-parentheses-equality>
      $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-Wno-unreachable-code>
      $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-Wno-unused-but-set-variable> # Only when trace disabled.
      $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-Wno-used-but-marked-unused>
  )

  target_clang_tidy_definitions( TARGET ${TARGET_DEST}
    CHECKS
      -*-braces-around-statements
      -*-function-size
      -*-magic-numbers
      -*-narrowing-conversions
      -*-static-assert
      -*-use-auto
      -*-use-equals-default
      -*-use-override
      -altera-id-dependent-backward-branch
      -altera-struct-pack-align
      -altera-unroll-loops
      -bugprone-branch-clone
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
      -misc-redundant-expression
      -modernize-concat-nested-namespaces
      -modernize-make-unique
      -modernize-use-bool-literals
      -modernize-use-nodiscard
      -readability-convert-member-functions-to-static
      -readability-function-cognitive-complexity
      -readability-identifier-length
      -readability-implicit-bool-conversion
      -readability-inconsistent-declaration-parameter-name
      -readability-simplify-boolean-expr
  )
  target_ignore_static_analysis( TARGET ${TARGET_DEST} CPPLINT )

  # Add target to GenerateVerilatedCode custom target.
  if (NOT TARGET GenerateVerilatedCode)
    add_custom_target(GenerateVerilatedCode)
  endif()
  add_dependencies(GenerateVerilatedCode ${TARGET_DEST})

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
