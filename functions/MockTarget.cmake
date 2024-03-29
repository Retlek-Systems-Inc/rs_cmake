#######################################################################
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
#[=======================================================================[.rst:
MockTarget
----------------

Creates a mock target from a pre-existing target and the input mock implementation

Checks that there is a target available that is identified as the target, and then
removes all link libraries and sources, but uses the interface include files of the
original target.
The newly created target is Mock_<target>.

MockTarget(
  TARGET  <target name to mock>
  SOURCES   <filename> [<filename> ...]
  [ DEPENDS_ON_TARGET ] - optional to allow mock to link to the target
  [ USE_GMOCK_C ]       - optional when C Language is enabled to use GMOCK_C <cmock/cmock.h>
)

For INTERFACE targets DEPENDS_ON_TARGET is by default selected.

External Variables :
   BUILD_TEST - if this is set to OFF then no test is generated.

Examples:

.. code-block:: cmake

  MockTarget( TARGET your_target
    SOURCES
      mock_your_target.cpp
  )

The following targets are defined by this module:

.. variable:: Mock_<target name>
#]=======================================================================]

function( MockTarget )
    set( _options DEPENDS_ON_TARGET )
    get_property(_languages GLOBAL PROPERTY ENABLED_LANGUAGES)
    if ("C" IN_LIST _languages)
        list(APPEND _options USE_GMOCK_C )
    endif()
    set( _oneValueArgs TARGET )
    set( _multiValueArgs SOURCES )
    include( CMakeParseArguments )
    cmake_parse_arguments( "_arg" "${_options}" "${_oneValueArgs}" "${_multiValueArgs}" ${ARGN} )
    
    if( _arg_UNPARSED_ARGUMENTS )
        message( FATAL_ERROR "Unknown argument(s) to add_mock_target: ${_arg_UNPARSED_ARGUMENTS}" )
    endif()
    
    if( NOT _arg_TARGET )
        message( FATAL_ERROR "Must specify TARGET <target> that is to be mocked" )
    endif()

    if( NOT TARGET ${_arg_TARGET})
        message( FATAL_ERROR "Unknown TARGET <target> to be mocked: ${_arg_TARGET}" )
    endif()
        
    if( NOT _arg_SOURCES )
        message( FATAL_ERROR "Must specify SOURCES <source list> to implement the mock" )
    endif()
    
    # Now that inputs are checked - Check Tests are not Disabled.
    if( NOT BUILD_TEST )
       message( STATUS "Disabling Mock: Target ${_arg_TARGET} is removed." )
       return ()
    endif()

    # Currently assumes GoogleTest and GoogleMock.
    #find_package(GMmock REQUIRED)
    
    # Create the Library
    set( _target Mock_${_arg_TARGET})
    add_library( ${_target} EXCLUDE_FROM_ALL STATIC ${_arg_SOURCES} )

    # Include the local directory.
    target_include_directories( ${_target} PUBLIC . )
    
    target_link_libraries( ${_target}
        PUBLIC
            GMock::GMock
            $<$<BOOL:${_arg_USE_GMOCK_C}>:gmock_c>
    )

    if (_arg_USE_GMOCK_C)
        target_clang_tidy_definitions( TARGET ${_target}
            CHECKS
                -readability-inconsistent-declaration-parameter-name
        )
    endif()

    get_target_property( _target_type ${_arg_TARGET}  TYPE )
    if ((_target_type STREQUAL "INTERFACE_LIBRARY") OR _arg_DEPENDS_ON_TARGET)
        # For interface libraries can just link against the library.
        # Or if a mock of a DEPENDS_ON_TARGET - eg a mock of a CPP class which is inherited.
        message( STATUS "Mock ${_arg_TARGET} is dependent on target.")
        target_link_libraries( ${_target}  PUBLIC ${_arg_TARGET} )
    elseif ((_target_type MATCHES "SHARED_LIBRARY|OBJECT_LIBRARY") AND _arg_USE_GMOCK_C )
        # For linked Dynamic libraries and using GMOCK_C - allows to use native library as well.
        message( STATUS "Mock ${_arg_TARGET} is dynamic and using GMOCK_C, dependent on target.")
        target_link_libraries( ${_target}  PUBLIC ${_arg_TARGET} )
    else()
        # Note - Private options of mocked object should not be propagated since
        # they have no bearing on the mock.
        
        # For all other library types must extract the interface portions of the include directories.
        target_include_directories( ${_target}
            PUBLIC
                $<TARGET_PROPERTY:${_arg_TARGET},INTERFACE_INCLUDE_DIRECTORIES>
        )
        target_include_directories( ${_target} SYSTEM
            PUBLIC
                $<TARGET_PROPERTY:${_arg_TARGET},INTERFACE_SYSTEM_INCLUDE_DIRECTORIES> 
        )
        # Note have to do it this way otherwise $<LINK_ONLY:*> inside the INTERFACE_LINK_LIBRARIES 
        # does not resolve correctly.
#        get_target_property(_link_libs ${_arg_TARGET} INTERFACE_LINK_LIBRARIES)
#        message(STATUS "Link Libs for ${_target}:  ${_link_libs}")
#        target_link_libraries( ${_target} 
#            PUBLIC
#                "$<TARGET_PROPERTY:${_arg_TARGET},INTERFACE_LINK_LIBRARIES>"
#        )
        
        target_compile_definitions( ${_target}
            PUBLIC
                $<TARGET_PROPERTY:${_arg_TARGET},INTERFACE_COMPILE_DEFINITIONS>
        )
        target_compile_options( ${_target}
            PUBLIC
                $<TARGET_PROPERTY:${_arg_TARGET},INTERFACE_COMPILE_OPTIONS>
        )
        target_compile_features( ${_target}
            PUBLIC
                $<TARGET_PROPERTY:${_arg_TARGET},INTERFACE_COMPILE_FEATURES>
        )
    endif()

    # target_clang_tidy_definitions( TARGET ${_target}
    #     CHECKS
    # )
    target_cppcheck_definitions( TARGET ${_target}
      DEFINES
        -UGMOCK_DECLARE_bool_
    )
endfunction()
