# Copyright (c) 2019 Paul Helter
#[=======================================================================[.rst:
FindPythonModule
----------------

Checks for the existence of a python module - only works for python3 and up.
  
Examples:

.. code-block:: cmake

  # Require breathe, treat the other components as optional
  find_python_module( breathe REQUIRED )
  find_python_module( pytest QUIET )

The following variables are defined by this module:

.. variable:: PY_<module> which contains the spec information of the module.


#]=======================================================================]



function(find_python_module module)
    find_package(Python3 3.4 REQUIRED)

    set(_options REQUIRED QUIET)
    set(_one_value_args)
    set(_multi_value_args)
    cmake_parse_arguments(_args
                          "${_options}"
                          "${_one_value_args}"
                          "${_multi_value_args}"
                          ${ARGN})
	string(TOUPPER ${module} module_upper)
	if(NOT PY_${module_upper})
		if(${_args_REQUIRED})
			set(${module}_FIND_REQUIRED TRUE)
		endif()
		if(${_args_QUIET})
		  set(${module}_FIND_QUIETLY TRUE)
		endif()

		# A module's location is usually a directory, but for binary modules
		# it's a .so file.
		execute_process(COMMAND "${Python3_EXECUTABLE}" "-c" 
            "import importlib; spec = importlib.util.find_spec('${module}'); print(spec);"
            RESULT_VARIABLE _${module}_status
            OUTPUT_VARIABLE _${module}_spec
            ERROR_QUIET
            OUTPUT_STRIP_TRAILING_WHITESPACE
        )
        
		if(NOT _${module}_status)
		    if(NOT (_${module}_spec STREQUAL "None" ) )
    			set(PY_${module_upper} ${_${module}_spec} CACHE STRING 
				  "Location of Python module ${module}")
		    endif()
		endif(NOT _${module}_status)
	endif(NOT PY_${module_upper})
	find_package_handle_standard_args(PY_${module} DEFAULT_MSG PY_${module_upper})
endfunction(find_python_module)