# Copyright (c) 2017 Paul Helter

# Based on : https://crascit.com/2016/04/09/using-ccache-with-cmake/

find_program(CCACHE_PROGRAM NAMES ccache DOC "path to the ccache executable")
mark_as_advanced(CCACHE_PROGRAM)

if( CCACHE_PROGRAM )
  execute_process(
	COMMAND "${CCACHE_PROGRAM}" --version
	OUTPUT_VARIABLE CCACHE_VERSION
	OUTPUT_STRIP_TRAILING_WHITESPACE
	RESULT_VARIABLE _Ccache_version_result
  )
  string(REGEX REPLACE ".* version ([0-9]+.[0-9]+.[0-9]+[a-z]*).*" "\\1" CCACHE_VERSION "${CCACHE_VERSION}")
  
  if(_CCache_version_result)
	message(WARNING "Unable to determine CCache version: ${_CCache_version_result}")
  endif()
endif()

# Verify find results
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(
    CCache
    REQUIRED_VARS CCACHE_PROGRAM
    VERSION_VAR CCACHE_VERSION
)

if(CCache_FOUND)
    set(CMAKE_C_COMPILER_LAUNCHER "${CCACHE_PROGRAM}")
    set(CMAKE_CXX_COMPILER_LAUNCHER "${CCACHE_PROGRAM}")
endif()
