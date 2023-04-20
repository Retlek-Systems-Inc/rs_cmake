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
# This file sets the basic flags for the Verilog language in CMake.
# It also loads the available platform file for the system-compiler
# if it exists.
# It also loads a system - compiler - processor (or target hardware)
# specific file, which is mainly useful for crosscompiling and embedded systems.

#set(CMAKE_Verilog_OUTPUT_EXTENSION .o)

# Load compiler-specific information.
if(CMAKE_Verilog_COMPILER_ID)
  include(Compiler/${CMAKE_Verilog_COMPILER_ID}-Verilog OPTIONAL)

  # load a hardware specific file, mostly useful for embedded compilers
  if(CMAKE_SYSTEM_PROCESSOR)
    include(Platform/${CMAKE_EFFECTIVE_SYSTEM_NAME}-${CMAKE_Verilog_COMPILER_ID}-Verilog-${CMAKE_SYSTEM_PROCESSOR} OPTIONAL)
  endif()
  include(Platform/${CMAKE_EFFECTIVE_SYSTEM_NAME}-${CMAKE_Verilog_COMPILER_ID}-Verilog OPTIONAL) 
endif()

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


# These are the only types of flags that should be passed to the verilog
# command, if COMPILE_FLAGS is used on a target this will be used
# to filter out any other flags
set(CMAKE_Verilog_FLAG_REGEX "^[-/](D|I)")


if(NOT CMAKE_INCLUDE_FLAG_Verilog)
  set(CMAKE_INCLUDE_FLAG_Verilog "-I ")
endif()

# add the flags to the cache based
# on the initial values computed in the platform/*.cmake files
# use _INIT variables so that this only happens the first time
# and you can set these flags in the cmake cache
set(CMAKE_Verilog_FLAGS_INIT "$ENV{VCFLAGS} ${CMAKE_Verilog_FLAGS_INIT}")

set (CMAKE_Verilog_FLAGS "${CMAKE_Verilog_FLAGS_INIT}" CACHE STRING
     "Flags used by the compiler during all build types.")

include(CMakeCommonLanguageInclude)

#########################################
# Start of Easy.
# This is based on: https://stackoverflow.com/questions/38293535/generic-rule-from-makefile-to-cmake
#
# This file sets the basic flags for the Verilog compiler
if(NOT CMAKE_Verilog_COMPILE_OBJECT)
  # This is slang version.
  set(CMAKE_Verilog_COMPILE_OBJECT "<CMAKE_Verilog_COMPILER> <DEFINES> <INCLUDES> <FLAGS> <SOURCE>")
endif()

# set this variable so we can avoid loading this more than once.
set(CMAKE_Verilog_INFORMATION_LOADED 1)

#End of Easy########################################

