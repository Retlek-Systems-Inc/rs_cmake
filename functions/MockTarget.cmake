# Copyright (c) 2017 Paul Helter
# Function to create a mock target from a pre-existing target.

# MockTarget
#   TARGET  target name to mock.
#   SOURCES replacement sources.

# External Variables : 
#    BUILD_TEST - if this is set to OFF then no test is generated.
#
# Checks that there is a target available that is identified as the target, and then
# removes all link libraries and sources, but uses the interface include files of the original target.
# The newly created target is Mock_<target>.

function( MockTarget )
    set( _options )
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
    
    target_link_libraries( ${_target} PRIVATE GMock::GMock)
    
    
    get_target_property( _target_type ${_arg_TARGET}  TYPE )
    if (_target_type STREQUAL "INTERFACE_LIBRARY" )
        # For interface libraries can just link against the library.
        target_link_libraries( ${_target}  PUBLIC ${_arg_TARGET} )
    else()
        # For all other library types must extract the interface portions of the include directories.
        target_include_directories( ${_target}
            PUBLIC
                "$<TARGET_PROPERTY:${_arg_TARGET},INTERFACE_INCLUDE_DIRECTORIES>"
        #TODO: Do we want the PUBLIC portions that were pushed into just INTERFACE ?
        #        "$<TARGET_PROPERTY:${_arg_TARGET},INCLUDE_DIRECTORIES>"
        )
        target_include_directories( ${_target} SYSTEM
            PUBLIC
                "$<TARGET_PROPERTY:${_arg_TARGET},INTERFACE_SYSTEM_INCLUDE_DIRECTORIES>" 
        )
        target_link_libraries( ${_target} PUBLIC ${_arg_TARGET} )
    endif()
endfunction()
