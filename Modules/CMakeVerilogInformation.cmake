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

#
# This file sets the basic flags for the C++ language in CMake.
# It also loads the available platform file for the system-compiler
# if it exists.
# It also loads a system - compiler - processor (or target hardware)
# specific file, which is mainly useful for crosscompiling and embedded systems.

include(CMakeLanguageInformation)

# some compilers use different extensions (e.g. sdcc uses .rel)
# so set the extension here first so it can be overridden by the compiler specific file
if(UNIX)
  # TODO:
  set(CMAKE_Verilog_OUTPUT_EXTENSION .o)
else()
  # TODO:
  set(CMAKE_Verilog_OUTPUT_EXTENSION .o)
endif()

set(_INCLUDED_FILE 0)

# Load compiler-specific information.
if(CMAKE_Verilog_COMPILER_ID)
  include(Compiler/${CMAKE_Verilog_COMPILER_ID}-Verilog OPTIONAL)
endif()

set(CMAKE_BASE_NAME)
get_filename_component(CMAKE_BASE_NAME "${CMAKE_Verilog_COMPILER}" NAME_WE)

# load a hardware specific file, mostly useful for embedded compilers
if(CMAKE_SYSTEM_PROCESSOR)
  if(CMAKE_Verilog_COMPILER_ID)
    include(Platform/${CMAKE_SYSTEM_NAME}-${CMAKE_Verilog_COMPILER_ID}-Verilog-${CMAKE_SYSTEM_PROCESSOR} OPTIONAL RESULT_VARIABLE _INCLUDED_FILE)
  endif()
  if (NOT _INCLUDED_FILE)
    include(Platform/${CMAKE_SYSTEM_NAME}-${CMAKE_BASE_NAME}-${CMAKE_SYSTEM_PROCESSOR} OPTIONAL)
  endif ()
endif()

# load the system- and compiler specific files
if(CMAKE_Verilog_COMPILER_ID)
  include(Platform/${CMAKE_SYSTEM_NAME}-${CMAKE_Verilog_COMPILER_ID}-Verilog OPTIONAL RESULT_VARIABLE _INCLUDED_FILE)
endif()
if (NOT _INCLUDED_FILE)
  include(Platform/${CMAKE_SYSTEM_NAME}-${CMAKE_BASE_NAME} OPTIONAL
          RESULT_VARIABLE _INCLUDED_FILE)
endif ()

# load any compiler-wrapper specific information
if (CMAKE_Verilog_COMPILER_WRAPPER)
  __cmake_include_compiler_wrapper(Verilog)
endif ()

# We specify the compiler information in the system file for some
# platforms, but this language may not have been enabled when the file
# was first included.  Include it again to get the language info.
# Remove this when all compiler info is removed from system files.
if (NOT _INCLUDED_FILE)
  include(Platform/${CMAKE_SYSTEM_NAME} OPTIONAL)
endif ()

#if(CMAKE_Verilog_SIZEOF_DATA_PTR)
#  foreach(f ${CMAKE_Verilog_ABI_FILES})
#    include(${f})
#  endforeach()
#  unset(CMAKE_Verilog_ABI_FILES)
#endif()

# This should be included before the _INIT variables are
# used to initialize the cache.  Since the rule variables
# have if blocks on them, users can still define them here.
# But, it should still be after the platform file so changes can
# be made to those values.

if(CMAKE_USER_MAKE_RULES_OVERRIDE)
  # Save the full path of the file so try_compile can use it.
  include(${CMAKE_USER_MAKE_RULES_OVERRIDE} RESULT_VARIABLE _override)
  set(CMAKE_USER_MAKE_RULES_OVERRIDE "${_override}")
endif()

if(CMAKE_USER_MAKE_RULES_OVERRIDE_Verilog)
  # Save the full path of the file so try_compile can use it.
  include(${CMAKE_USER_MAKE_RULES_OVERRIDE_Verilog} RESULT_VARIABLE _override)
  set(CMAKE_USER_MAKE_RULES_OVERRIDE_Verilog "${_override}")
endif()


# Create a set of shared library variable specific to C++
# For 90% of the systems, these are the same flags as the C versions
# so if these are not set just copy the flags from the c version
if(NOT CMAKE_SHARED_LIBRARY_CREATE_Verilog_FLAGS)
  set(CMAKE_SHARED_LIBRARY_CREATE_Verilog_FLAGS ${CMAKE_SHARED_LIBRARY_CREATE_C_FLAGS})
endif()

#if(NOT CMAKE_Verilog_COMPILE_OPTIONS_PIC)
#  set(CMAKE_Verilog_COMPILE_OPTIONS_PIC ${CMAKE_C_COMPILE_OPTIONS_PIC})
#endif()

#if(NOT CMAKE_Verilog_COMPILE_OPTIONS_PIE)
#  set(CMAKE_Verilog_COMPILE_OPTIONS_PIE ${CMAKE_C_COMPILE_OPTIONS_PIE})
#endif()

#if(NOT CMAKE_Verilog_COMPILE_OPTIONS_DLL)
#  set(CMAKE_Verilog_COMPILE_OPTIONS_DLL ${CMAKE_C_COMPILE_OPTIONS_DLL})
#endif()

if(NOT CMAKE_SHARED_LIBRARY_Verilog_FLAGS)
  set(CMAKE_SHARED_LIBRARY_Verilog_FLAGS ${CMAKE_SHARED_LIBRARY_C_FLAGS})
endif()

if(NOT DEFINED CMAKE_SHARED_LIBRARY_LINK_Verilog_FLAGS)
  set(CMAKE_SHARED_LIBRARY_LINK_Verilog_FLAGS ${CMAKE_SHARED_LIBRARY_LINK_C_FLAGS})
endif()

if(NOT CMAKE_SHARED_LIBRARY_RUNTIME_Verilog_FLAG)
  set(CMAKE_SHARED_LIBRARY_RUNTIME_Verilog_FLAG ${CMAKE_SHARED_LIBRARY_RUNTIME_C_FLAG})
endif()

if(NOT CMAKE_SHARED_LIBRARY_RUNTIME_Verilog_FLAG_SEP)
  set(CMAKE_SHARED_LIBRARY_RUNTIME_Verilog_FLAG_SEP ${CMAKE_SHARED_LIBRARY_RUNTIME_C_FLAG_SEP})
endif()

#if(NOT CMAKE_SHARED_LIBRARY_RPATH_LINK_Verilog_FLAG)
#  set(CMAKE_SHARED_LIBRARY_RPATH_LINK_Verilog_FLAG ${CMAKE_SHARED_LIBRARY_RPATH_LINK_C_FLAG})
#endif()

#if(NOT DEFINED CMAKE_EXE_EXPORTS_Verilog_FLAG)
#  set(CMAKE_EXE_EXPORTS_Verilog_FLAG ${CMAKE_EXE_EXPORTS_C_FLAG})
#endif()

#if(NOT DEFINED CMAKE_SHARED_LIBRARY_SONAME_Verilog_FLAG)
#  set(CMAKE_SHARED_LIBRARY_SONAME_Verilog_FLAG ${CMAKE_SHARED_LIBRARY_SONAME_C_FLAG})
#endif()

if(NOT CMAKE_EXECUTABLE_RUNTIME_Verilog_FLAG)
  set(CMAKE_EXECUTABLE_RUNTIME_Verilog_FLAG ${CMAKE_SHARED_LIBRARY_RUNTIME_Verilog_FLAG})
endif()

if(NOT CMAKE_EXECUTABLE_RUNTIME_Verilog_FLAG_SEP)
  set(CMAKE_EXECUTABLE_RUNTIME_Verilog_FLAG_SEP ${CMAKE_SHARED_LIBRARY_RUNTIME_Verilog_FLAG_SEP})
endif()

if(NOT CMAKE_EXECUTABLE_RPATH_LINK_Verilog_FLAG)
  set(CMAKE_EXECUTABLE_RPATH_LINK_Verilog_FLAG ${CMAKE_SHARED_LIBRARY_RPATH_LINK_Verilog_FLAG})
endif()

if(NOT DEFINED CMAKE_SHARED_LIBRARY_LINK_Verilog_WITH_RUNTIME_PATH)
  set(CMAKE_SHARED_LIBRARY_LINK_Verilog_WITH_RUNTIME_PATH ${CMAKE_SHARED_LIBRARY_LINK_C_WITH_RUNTIME_PATH})
endif()

if(NOT CMAKE_INCLUDE_FLAG_Verilog)
  set(CMAKE_INCLUDE_FLAG_Verilog ${CMAKE_INCLUDE_FLAG_C})
endif()

if(NOT CMAKE_INCLUDE_FLAG_SEP_Verilog)
  set(CMAKE_INCLUDE_FLAG_SEP_Verilog ${CMAKE_INCLUDE_FLAG_SEP_C})
endif()

# for most systems a module is the same as a shared library
# so unless the variable CMAKE_MODULE_EXISTS is set just
# copy the values from the LIBRARY variables
if(NOT CMAKE_MODULE_EXISTS)
  set(CMAKE_SHARED_MODULE_Verilog_FLAGS ${CMAKE_SHARED_LIBRARY_Verilog_FLAGS})
  set(CMAKE_SHARED_MODULE_CREATE_Verilog_FLAGS ${CMAKE_SHARED_LIBRARY_CREATE_Verilog_FLAGS})
endif()

# repeat for modules
if(NOT CMAKE_SHARED_MODULE_CREATE_Verilog_FLAGS)
  set(CMAKE_SHARED_MODULE_CREATE_Verilog_FLAGS ${CMAKE_SHARED_MODULE_CREATE_C_FLAGS})
endif()

if(NOT CMAKE_SHARED_MODULE_Verilog_FLAGS)
  set(CMAKE_SHARED_MODULE_Verilog_FLAGS ${CMAKE_SHARED_MODULE_C_FLAGS})
endif()

# Initialize Verilog link type selection flags from C versions.
foreach(type SHARED_LIBRARY SHARED_MODULE EXE)
  if(NOT CMAKE_${type}_LINK_STATIC_Verilog_FLAGS)
    set(CMAKE_${type}_LINK_STATIC_Verilog_FLAGS
      ${CMAKE_${type}_LINK_STATIC_C_FLAGS})
  endif()
  if(NOT CMAKE_${type}_LINK_DYNAMIC_Verilog_FLAGS)
    set(CMAKE_${type}_LINK_DYNAMIC_Verilog_FLAGS
      ${CMAKE_${type}_LINK_DYNAMIC_C_FLAGS})
  endif()
endforeach()

# add the flags to the cache based
# on the initial values computed in the platform/*.cmake files
# use _INIT variables so that this only happens the first time
# and you can set these flags in the cmake cache
set(CMAKE_Verilog_FLAGS_INIT "$ENV{VerilogFLAGS} ${CMAKE_Verilog_FLAGS_INIT}")

foreach(c "" _DEBUG _RELEASE _MINSIZEREL _RELWITHDEBINFO)
  string(STRIP "${CMAKE_Verilog_FLAGS${c}_INIT}" CMAKE_Verilog_FLAGS${c}_INIT)
endforeach()

set (CMAKE_Verilog_FLAGS "${CMAKE_Verilog_FLAGS_INIT}" CACHE STRING
     "Flags used by the compiler during all build types.")

if(NOT CMAKE_NOT_USING_CONFIG_FLAGS)
  set (CMAKE_Verilog_FLAGS_DEBUG "${CMAKE_Verilog_FLAGS_DEBUG_INIT}" CACHE STRING
     "Flags used by the compiler during debug builds.")
  set (CMAKE_Verilog_FLAGS_MINSIZEREL "${CMAKE_Verilog_FLAGS_MINSIZEREL_INIT}" CACHE STRING
     "Flags used by the compiler during release builds for minimum size.")
  set (CMAKE_Verilog_FLAGS_RELEASE "${CMAKE_Verilog_FLAGS_RELEASE_INIT}" CACHE STRING
     "Flags used by the compiler during release builds.")
  set (CMAKE_Verilog_FLAGS_RELWITHDEBINFO "${CMAKE_Verilog_FLAGS_RELWITHDEBINFO_INIT}" CACHE STRING
     "Flags used by the compiler during release builds with debug info.")

endif()

#if(CMAKE_Verilog_STANDARD_LIBRARIES_INIT)
#  set(CMAKE_Verilog_STANDARD_LIBRARIES "${CMAKE_Verilog_STANDARD_LIBRARIES_INIT}"
#    CACHE STRING "Libraries linked by default with all C++ applications.")
#  mark_as_advanced(CMAKE_Verilog_STANDARD_LIBRARIES)
#endif()

include(CMakeCommonLanguageInclude)

# now define the following rules:
# CMAKE_Verilog_CREATE_SHARED_LIBRARY
# CMAKE_Verilog_CREATE_SHARED_MODULE
# CMAKE_Verilog_COMPILE_OBJECT
# CMAKE_Verilog_LINK_EXECUTABLE

# variables supplied by the generator at use time
# <TARGET>
# <TARGET_BASE> the target without the suffix
# <OBJECTS>
# <OBJECT>
# <LINK_LIBRARIES>
# <FLAGS>
# <LINK_FLAGS>

# Verilog compiler information
# <CMAKE_Verilog_COMPILER>
# <CMAKE_SHARED_LIBRARY_CREATE_Verilog_FLAGS>
# <CMAKE_Verilog_SHARED_MODULE_CREATE_FLAGS>
# <CMAKE_Verilog_LINK_FLAGS>

# Static library tools
# <CMAKE_AR>
# <CMAKE_RANLIB>

#########################################
# Start of Easy.
# This is based on: https://stackoverflow.com/questions/38293535/generic-rule-from-makefile-to-cmake
#
# This file sets the basic flags for the Verilog compiler
#if(NOT CMAKE_Verilog_COMPILE_OBJECT)
#    set(CMAKE_Verilog_COMPILE_OBJECT "<CMAKE_Verilog_COMPILER> <SOURCE> <OBJECT>")
#endif()
#set(CMAKE_Verilog_INFORMATION_LOADED 1)
#
#if(NOT CMAKE_Verilog_CREATE_SHARED_LIBRARY)
#    set(CMAKE_Verilog_CREATE_SHARED_LIBRARY "")
#endif()
#
# TODO: Figure this out.
#if(NOT CMAKE_Verilog_CREATE_SHARED_MODULE)
#    set(CMAKE_Verilog_CREATE_SHARED_MODULE "")
#endif()
#
#
#
#CMAKE_Verilog_CREATE_STATIC_LIBRARY
#CMAKE_Verilog_COMPILE_OBJECT
#CMAKE_Verilog_LINK_EXECUTABLE
#End of Easy########################################


# create a shared C++ library
if(NOT CMAKE_Verilog_CREATE_SHARED_LIBRARY)
  set(CMAKE_Verilog_CREATE_SHARED_LIBRARY
      "<CMAKE_Verilog_COMPILER> <CMAKE_SHARED_LIBRARY_Verilog_FLAGS> <LANGUAGE_COMPILE_FLAGS> <LINK_FLAGS> <CMAKE_SHARED_LIBRARY_CREATE_Verilog_FLAGS> <SONAME_FLAG><TARGET_SONAME> -o <TARGET> <OBJECTS> <LINK_LIBRARIES>")
endif()

# create a c++ shared module copy the shared library rule by default
if(NOT CMAKE_Verilog_CREATE_SHARED_MODULE)
  set(CMAKE_Verilog_CREATE_SHARED_MODULE ${CMAKE_Verilog_CREATE_SHARED_LIBRARY})
endif()


# Create a static archive incrementally for large object file counts.
# If CMAKE_Verilog_CREATE_STATIC_LIBRARY is set it will override these.
if(NOT DEFINED CMAKE_Verilog_ARCHIVE_CREATE)
  set(CMAKE_Verilog_ARCHIVE_CREATE "<CMAKE_AR> qc <TARGET> <LINK_FLAGS> <OBJECTS>")
endif()
if(NOT DEFINED CMAKE_Verilog_ARCHIVE_APPEND)
  set(CMAKE_Verilog_ARCHIVE_APPEND "<CMAKE_AR> q  <TARGET> <LINK_FLAGS> <OBJECTS>")
endif()
if(NOT DEFINED CMAKE_Verilog_ARCHIVE_FINISH)
  set(CMAKE_Verilog_ARCHIVE_FINISH "<CMAKE_RANLIB> <TARGET>")
endif()

# compile a C++ file into an object file
if(NOT CMAKE_Verilog_COMPILE_OBJECT)
  set(CMAKE_Verilog_COMPILE_OBJECT
    "<CMAKE_Verilog_COMPILER>  <DEFINES> <INCLUDES> <FLAGS> -o <OBJECT> -c <SOURCE>")
endif()

if(NOT CMAKE_Verilog_LINK_EXECUTABLE)
  set(CMAKE_Verilog_LINK_EXECUTABLE
    "<CMAKE_Verilog_COMPILER>  <FLAGS> <CMAKE_Verilog_LINK_FLAGS> <LINK_FLAGS> <OBJECTS>  -o <TARGET> <LINK_LIBRARIES>")
endif()

mark_as_advanced(
CMAKE_VERBOSE_MAKEFILE
CMAKE_Verilog_FLAGS
CMAKE_Verilog_FLAGS_RELEASE
CMAKE_Verilog_FLAGS_RELWITHDEBINFO
CMAKE_Verilog_FLAGS_MINSIZEREL
CMAKE_Verilog_FLAGS_DEBUG)

set(CMAKE_Verilog_INFORMATION_LOADED 1)
