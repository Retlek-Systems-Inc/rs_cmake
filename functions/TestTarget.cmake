# Copyright (c) 2017 Paul Helter
# Function to create a Test target for a given component.

# TestTarget(
#   TARGET  target name to test.
#   SOURCES   <filename> [<filename> ...]
#   
#   [ TYPE [UINT, MANUAL] ] - default unit.
#   [ FRAMEWORK [ GTest ] ] - default GTest
#   [ MOCK_LIBRARY <mock target> [<mock target> ...] ]
#   [ LINK_LIBRARY <target> [<target> ...] ]
#)
# 
# External Variables : 
#    BUILD_TEST - if this is set to OFF then no test is generated.
#    TEST_EXCLUDE_FROM_ALL - if this is set, then the tests will be excluded from the entire build.
#       - useful for when compiling 
#    TEST_DESTINATION_DIR if this is sent the destination directory inside the current build dir is used.
#
# Checks that the mock libraries (made with MockTarget.cmake - prefixed with GMock*) are available.
# Checks that the link libraries are available.


function( TestTarget )
    set( _options )
    set( _oneValueArgs TARGET FRAMEWORK TYPE)
    set( _multiValueArgs SOURCES MOCK_LIBRARY LINK_LIBRARY)
    include( CMakeParseArguments )
    cmake_parse_arguments( "_arg" "${_options}" "${_oneValueArgs}" "${_multiValueArgs}" ${ARGN} )
    
    if( _arg_UNPARSED_ARGUMENTS )
        message( FATAL_ERROR "Unknown argument(s) to TestTarget: ${_arg_UNPARSED_ARGUMENTS}" )
    endif()
    
    if( NOT _arg_TARGET )
        message( FATAL_ERROR "Must specify TARGET <target> create the tests for" )
    endif()

    if( NOT TARGET ${_arg_TARGET} )
        message( FATAL_ERROR "Unknown TARGET <target> to create tests for: ${_arg_TARGET}" )
    endif()

    if( NOT _arg_SOURCES )
        message( FATAL_ERROR "Must specify SOURCES <source list> to implement the tests" )
    endif()
    
    # No Type defined - assume unit.
    if( NOT _arg_TYPE )
        set( _arg_TYPE "UNIT" )
    endif()
     
    if (_arg_TYPE STREQUAL "UNIT" )
        set( _exec_name UnitTest )
    elseif (_arg_TYPE STREQUAL "MANUAL" )
        set( _exec_name ManualTest )
    else()
       message( FATAL_ERROR "Unknown Test Type ${_arg_TYPE}, must be blank, UNIT or MANUAL" )
    endif()
  
    # Now that inputs are checked - Check Tests are not Disabled.
    if( NOT BUILD_TEST )
       message( STATUS "Disabling Tests: Target ${_arg_TARGET} is removed." )
       return ()
    endif()

    set( _target ${_exec_name}_${_arg_TARGET} )
    

    # Currently assumes GoogleTest and GoogleMock.
    if (NOT _arg_FRAMEWORK)
        set(_arg_FRAMEWORK GTest)
    endif()

    if (_arg_FRAMEWORK STREQUAL "GTest")
        # GTest is part of GMock
        include(GoogleTest)
        set(_framework_libs  GTest::GTest GTest::Main )
        set(_command ${_target} )
        # TODO: Do we want to create output in a known spot? -eg:
        #set(_test_cmd ${_target} --gtest_output=xml:${CMAKE_CURRENT_BINARY_DIR}/test/output/${_target}.xml )
    elseif(_arg_FRAMEWORK STREQUAL "GMock")
        include(GoogleTest)
        set(_framework_libs GMock::GMock GMock::Main)
        set(_command ${_target} )
    else()
        message( FATAL_ERROR "Unrecognized Test framework")
    endif()

    
    # Create the executable:
    if( TEST_EXCLUDE_FROM_ALL )
        add_executable( ${_target} EXCLUDE_FROM_ALL ${_arg_SOURCES} )
    else()
        add_executable( ${_target} ${_arg_SOURCES} )
    endif()
    
    get_target_property(_type ${_arg_TARGET} TYPE)
    
    # Link libraries
    foreach( _mock ${_arg_MOCK_LIBRARY})
      list(APPEND _mock_libs Mock_${_mock})
    endforeach()
    
    if(_type STREQUAL "INTERFACE_LIBRARY")
        # For interface - just include it in the link libraries - all other
        # params will be the same.
	    target_link_libraries( ${_target}
	        PRIVATE
	          ${_framework_libs}
	          ${_mock_libs}
	          ${_arg_TARGET}
	          ${_arg_LINK_LIBRARY}
	    )
	else()
	    # Include the local source directory and private directories of the target
	    # can get away with the private ones since this is a test.
	    target_include_directories( ${_target}
	        PRIVATE
	          ${CMAKE_CURRENT_SOURCE_DIR}
	          "$<TARGET_PROPERTY:${_arg_TARGET},INCLUDE_DIRECTORIES>"
	    )

	    add_dependencies( ${_target} ${_arg_TARGET} )

	    # Compile the same as the target under test.
	    target_compile_definitions( ${_target}
	        PRIVATE
	          "$<TARGET_PROPERTY:${_arg_TARGET},COMPILE_DEFINITIONS>"
	    )
    
	    target_link_libraries( ${_target}
	        PRIVATE
	          ${_framework_libs}
	          ${_mock_libs}
	          "$<TARGET_LINKER_FILE:${_arg_TARGET}>"
	          ${_arg_LINK_LIBRARY}
	    )
	endif()

    #Optionally move the tests into one dir.
    option(TEST_DESTINATION_DIR  "Use this directory as the destination <build>/test" ON)
    if (TEST_DESTINATION_DIR)
       set_target_properties( ${_target} PROPERTIES
          RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/test/"
       )
    endif()
    
    
    # Add Test functionality.
    if (_arg_TYPE STREQUAL UNIT )
        message( STATUS "${_arg_TYPE} test ${_target} add_test.")
        # Note: If we support other test frameworks will need to do the following:
        if ( (_arg_FRAMEWORK STREQUAL "GTest") OR (_arg_FRAMEWORK STREQUAL "GMock") )
            gtest_discover_tests( ${_target} )
        else()
            add_test( NAME ${_target} COMMAND ${_command} )
        endif()
    else()
        message( STATUS "Generated ${_arg_TYPE} test ${_target} - not part of unit test runs.")
    endif()

endfunction()
