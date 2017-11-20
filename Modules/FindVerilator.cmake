# Copyright (c) 2017 Paul Helter

# Add a target to generate c++ from verilog to compile.

#.rst:
# FindVerilator
# ---------
#
# Find ``Verilator`` executable, include dirs, and libraries
#
# Use this module by invoking find_package with the form::
#
#   find_package(Verilator
#     [version] [EXACT]      # Minimum or EXACT version e.g. 3.914
#     [REQUIRED]             # Fail with error if ``verilator`` is not found
#     [TBD <libs>...]        # Verilator libraries by their canonical name
#     )

# The module defines the following variables:
#
# ``Verilator_EXECUTABLE``
#   path to the ``verilator`` program
#
# ``Verilator_VERSION``
#   version of ``verilator``
#
# ``Verilator_FOUND``
#   true if the program was found
#
# If ``verilator`` is found, the module defines the macro::
#
#   Verilator_TARGET(
#           <Target Name> 
#           [VERILOG_SRC  <verilog source>]
#           [CODE_OUTPUT  <code output>]
#           [COMPILE_FLAGS <flags>]
#           [DEFINES_FILE <file>]
#           [VERBOSE [<file>]]
#           [REPORT_FILE <file>]
#           )

#

#-------------------------------------------------------------------------------
find_program(Verilator_EXECUTABLE NAMES verilator DOC "Path to the Verilator executable")

include(FindPkgConfig)
include(FindPackageHandleStandardArgs)

pkg_check_modules(Verilator verilator)

find_path(
    Verilator_INCLUDE_DIRS
    NAMES verilated.h verilated_config.h
    HINTS $ENV{Verilator_DIR}/include
          ${Verilator_INCLUDEDIR}
    PATHS ${CMAKE_INSTALL_PREFIX}/include
          /usr/local/share/
          /usr/local/include
          /usr/include
)

#find_library(
#    Verilator_LIBRARIES
#    NAMES verilator
#    HINTS $ENV{Verilator_DIR}/lib
#          ${Verilator_LIBDIR}
#    PATHS ${CMAKE_INSTALL_PREFIX}/lib
#          ${CMAKE_INSTALL_PREFIX}/lib64
#          /usr/local/share/
#          /usr/local/lib
#          /usr/local/lib64
#          /usr/lib
#          /usr/lib64
#)

find_package_handle_standard_args( Verilator
    DEFAULT_MSG
    Verilator_EXECUTABLE
    #Verilator_LIBRARIES
    Verilator_INCLUDE_DIRS
)
  
mark_as_advanced(
    Verilator_EXECUTABLE 
    #Verilator_LIBRARIES 
    Verilator_INCLUDE_DIRS)

if(Verilator_FOUND)

    macro(verilator_add_library)
        set(options CPP_GEN SYSTEMC_GEN)
        set(oneValueArgs "")
        set(multiValueArgs "")
        cmake_parse_arguments(verilator_create
             "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )

        include_directories(SYSTEM ${Verilator_INCLUDE_DIRS})

        set(_target verilator)
        
        # There are now 2 include dirs -use the first primary one.
        list(GET Verilator_INCLUDE_DIRS 0 _inc_dir )

        #message(STATUS "Verilator INCLUDE DIRS: ${Verilator_INCLUDE_DIRS}")
        
        set(_src
            ${_inc_dir}/verilated.cpp
            ${_inc_dir}/verilated_cov.cpp
            ${_inc_dir}/verilated_dpi.cpp
            ${_inc_dir}/verilated_save.cpp
        )
        if(verilator_add_library_CPP_GEN)
            #list(APPEND _src ${_inc_dir}/verilated_vcd_c.cpp)
        endif(verilator_add_library_CPP_GEN)

        if(verilator_add_library_SYSTEMC_GEN)
            #list(APPEND _src ${_inc_dir}/verilated_vcd_sc.cpp)
        endif(verilator_add_library_SYSTEMC_GEN)

        add_library(${_target} SHARED ${_src})

        set(Verilator_LIBRARY ${_target})
        set_target_properties(${_target}
            PROPERTIES COMPILE_FLAGS "-std=c++11 -Wall -Werror"
        )
    endmacro()

    macro(verilator_create)
        set(options "")
        set(oneValueArgs TARGET OUTPUT_DIR)
        set(multiValueArgs VERILATOR_ARGS VERILOG_INCLUDES VERILOG_SOURCE)
        cmake_parse_arguments(verilator_create
             "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )

        # OUTPUT_DIR - will use CMAKE_CURRENT_SOURCE_DIR if not there.
        if ("$verilator_create_OUTPUT_DIR" STREQUAL "" )
            set(verilator_create_OUTPUT_DIR ${CMAKE_CURRENT_SOURCE_DIR})
        endif()

        # Okay for VERILATOR_ARGS to be empty.
                
        # Update the List of Includes for Verilog:
        set(VERILOG_INCS "")
        foreach(inc ${verilator_create_VERILOG_INCLUDES})
            list(APPEND VERILOG_INCS -I${inc})
        endforeach()

        # Generate the list of output files based on VERILOG_SOURCE.
        set(OUTPUT_SOURCE "")
        foreach(src ${verilator_create_VERILOG_SOURCE}})
            list(APPEND OUTPUT_SOURCE ${verilator_create_OUTPUT_DIR}/${src})
        endforeach()

        add_custom_command(
            OUTPUT ${OUTPUT_SOURCE}
            COMMAND ${CMAKE_COMMAND} -E make_directory ${verilator_create_OUTPUT_DIR}
            COMMAND verilator ${verilator_create_VERILATOR_ARGS} ${VERILATOR_INCS}
                -Wall
                -Mdir ${verilator_create_OUTPUT_DIR}
                --cc ${verilog_module}.v
            #COMMAND ${CMAKE_COMMAND} -E remove ${verilator_create_OUTPUT_DIR}/*.mk
            #COMMAND ${CMAKE_COMMAND} -E remove ${verilator_create_OUTPUT_DIR}/*.d
            #COMMAND ${CMAKE_COMMAND} -E remove ${verilator_create_OUTPUT_DIR}/*.dat
            MAIN_DEPENDENCY ${verilog_module}.v
            WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
            COMMENT "Generating C++ module ${verilog_module}"
        )

        add_library(${verilog_create_TARGET} STATIC ${OUTPUT_SOURCE})
    endmacro()

else(Verilator_FOUND)
  if(Verilator_FIND_REQUIRED)
    message(FATAL_ERROR "Verilator not found!")
  endif(Verilator_FIND_REQUIRED)
endif(Verilator_FOUND)
