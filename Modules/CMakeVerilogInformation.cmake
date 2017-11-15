# Copyright (c) 2017 Paul Helter
# See accompanying file Copyright.txt or https://tbd for details.

# This is based on: https://stackoverflow.com/questions/38293535/generic-rule-from-makefile-to-cmake

# This file sets the basic flags for the Verilog compiler
if(NOT CMAKE_Verilog_COMPILE_OBJECT)
    set(CMAKE_Verilog_COMPILE_OBJECT "<CMAKE_Verilog_COMPILER> <SOURCE> <OBJECT>")
endif()
set(CMAKE_Verilog_INFORMATION_LOADED 1)

#CMAKE_Verilog_CREATE_SHARED_LIBRARY
#CMAKE_Verilog_CREATE_SHARED_MODULE
#CMAKE_Verilog_CREATE_STATIC_LIBRARY
#CMAKE_Verilog_COMPILE_OBJECT
#CMAKE_Verilog_LINK_EXECUTABLE