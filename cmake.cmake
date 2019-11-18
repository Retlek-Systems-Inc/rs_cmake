# Copyright (c) 2017 Paul Helter
# See accompanying file Copyright.txt or https://tbd for details.

list( APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/Modules" )

# Create a common cmake path for identification of modules etc.
set( COMMON_CMAKE_PATH "${CMAKE_CURRENT_LIST_DIR}"  )

# Add in CCache if available.
find_package(CCache)

# Ensure Build dir isn't same as local dir.
if ( ${CMAKE_SOURCE_DIR} STREQUAL ${CMAKE_BINARY_DIR} )
    message( FATAL_ERROR "Do not perform build in source directory. Make a separate directory for build:\n\tmkdir build; cd build; cmake ..\n And ensure it is empty.")
endif()


#Limit it to Makefile or Ninja for now.
if ( NOT CMAKE_BUILD_TYPE AND ( (CMAKE_GENERATOR MATCHES ".*Makefile.*") OR (CMAKE_GENERATOR MATCHES ".*Ninja.*")))
    message( STATUS "Makefile generator detected and build type not defined. Defaulting to `release`.")
    set( CMAKE_BUILD_TYPE release CACHE STRING "Choose the type of build" FORCE )
endif()

# Common Functions and Macros
file( GLOB _functions ${CMAKE_CURRENT_LIST_DIR}/functions/*.cmake )
foreach( _f ${_functions} )
  include( ${_f} )
endforeach()
