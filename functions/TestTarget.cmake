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
TestTarget
----------------

Creates a test target from a pre-existing target and the unit test envrionment.

Checks that there is a target available that is identified as the target,
removes all linkages between other linked targets and allows to replace with
MOCK_LIBRARY mocked versions.

The newly created target is UnitTest_<target> or ManualTest_<target>.

TestTarget(
  TARGET  <target name to test>
  SOURCES   <filename> [<filename> ...]

  [ TYPE [UNIT, MANUAL, BENCHMARK] ] - default unit.
  [ CUSTOM_NAME <executable name> ] - overrides default naming convention of executable
  [ FRAMEWORK [ GTest | GMock | Benchmark ] ] - default GTest
  [ NO_DISCOVERY ] - when used will only create a single test and bypass any sub-test discovery
  [ MOCK_LIBRARY <mock target> [<mock target> ...] ]
  [ LINK_LIBRARY <target> [<target> ...] ]
)

External Variables :
   BUILD_TEST - if this is set to OFF then no test is generated.
   BUILD_BENCHMARK - if this is set to OFF then no benchmark TYPE tests are generated.
   TEST_EXCLUDE_FROM_ALL - if this is set, then the tests will be excluded from the entire build.
      - useful for when compiling
   TEST_DESTINATION_DIR if this is sent the destination directory inside the current build dir is used.

Examples:

.. code-block:: cmake

  TestTarget( TARGET your_target
    SOURCES
      test_your_target.cpp
    UNIT
    FRAMEWORK
      GMock
    MOCK_LIBRARY
      target_A
    LINK_LIBRARY
      target_B
  )
  #Where dependent_target_A is a mock of target_A
  #Where target_B is the actual implementation

The following targets are defined by this module:

.. variable:: UnitTest_<target name> OR ManualTest_<target_name> OR
              Benchark_<target_name> OR `CUSTOM_NAME name defined`.
#]=======================================================================]
function( TestTarget )
    set( _options NO_DISCOVERY )
    set( _oneValueArgs TARGET FRAMEWORK TYPE CUSTOM_NAME)
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
    elseif (_arg_TYPE STREQUAL "BENCHMARK" )
        set( _exec_name Benchmark )
    else()
        message( FATAL_ERROR "Unknown Test Type ${_arg_TYPE}, must be blank, UNIT, MANUAL, or BENCHMARK" )
    endif()

    # Now that inputs are checked - Check Tests are not Disabled.
    if( NOT BUILD_TEST )
        message( STATUS "Disabling Tests: Target ${_arg_TARGET} is removed." )
        return ()
    endif()

    if( _arg_TYPE STREQUAL "BENCHMARK" )
        if( NOT BUILD_BENCHMARK )
            message( STATUS "Disabling Benchmark: Target ${_arg_TARGET} benchmark is removed." )
            return()
        endif()

        string(TOLOWER ${CMAKE_BUILD_TYPE} _buildType)
        if (BUILD_BENCHMARK_RELEASE_ONLY AND NOT ${_buildType} MATCHES "^rel.*" )
            message(STATUS "Disabling Benchmark: Target ${_arg_TARGET}, CMAKE_BUILD_TYPE = ${CMAKE_BUILD_TYPE}")
            return()
        endif()
    endif()

    if ( NOT _arg_CUSTOM_NAME )
        set( _target ${_exec_name}_${_arg_TARGET} )
    else()
        set( _target ${_arg_CUSTOM_NAME} )
    endif()

    # Currently assumes GoogleTest and GoogleMock.
    if( _arg_TYPE STREQUAL "BENCHMARK" )
        # For now when BENCHMARK - use Benchmark framework
        # Might be more later.
        set(_arg_FRAMEWORK "Benchmark" )
    elseif (NOT _arg_FRAMEWORK)
        # Default
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
    elseif(_arg_FRAMEWORK STREQUAL "Benchmark")
        set(_framework_libs benchmark::benchmark benchmark::benchmark_main)
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
	          ${_arg_TARGET}
              # Note: Care must be taken here - these have to be last.
	          ${_mock_libs}
	          ${_arg_LINK_LIBRARY}
	    )
	else()
	    # Include the local source directory and private directories of the target
	    # can get away with the private ones since this is a test.
	    target_include_directories( ${_target}
	        PRIVATE
	          ${CMAKE_CURRENT_SOURCE_DIR}
	          $<TARGET_PROPERTY:${_arg_TARGET},INCLUDE_DIRECTORIES>
	    )

	    add_dependencies( ${_target} ${_arg_TARGET} )

	    # Compile the same as the target under test.
	    target_compile_definitions( ${_target}
	        PRIVATE
	          $<TARGET_PROPERTY:${_arg_TARGET},COMPILE_DEFINITIONS>
	    )
	    target_compile_options( ${_target}
	        PRIVATE
	          $<TARGET_PROPERTY:${_arg_TARGET},COMPILE_OPTIONS>
	    )
	    target_compile_features( ${_target}
	        PRIVATE
	          $<TARGET_PROPERTY:${_arg_TARGET},COMPILE_FEATURES>
	    )

	    target_link_libraries( ${_target}
	        PRIVATE
	          ${_framework_libs}
	          $<TARGET_LINKER_FILE:${_arg_TARGET}>
              # Note: Care must be taken here - these have to be last.
	          ${_mock_libs}
	          ${_arg_LINK_LIBRARY}
              $<$<CONFIG:Msan>:${MSAN_LINK_LIBRARIES}>
	    )
	endif()

    if( (_arg_FRAMEWORK STREQUAL "GTest") OR (_arg_FRAMEWORK STREQUAL "GMock") )
        # Add in any GTest/GMock header specific issues - need to add to each of the test argets.
    elseif(_arg_FRAMEWORK STREQUAL "Benchmark")
        target_clang_tidy_definitions( TARGET ${_target}
          CHECKS
            -bugprone-macro-parentheses
            -cert-err58-cpp
            -clang-analyzer-deadcode.DeadStores # Note this is for the template of for(auto _: state)
            -cppcoreguidelines-avoid-non-const-global-variables
            -cppcoreguidelines-explicit-virtual-functions
            -cppcoreguidelines-explicit-virtual-functions
            -cppcoreguidelines-macro-usage
            -cppcoreguidelines-pro-type-const-cast
            -cppcoreguidelines-pro-type-member-init
            -google-explicit-constructor
            -hicpp-deprecated-headers
            -hicpp-explicit-conversions
            -hicpp-member-init
            -hicpp-named-parameter
            -hicpp-no-assembler
            -hicpp-use-emplace
            -hicpp-use-equals-default
            -hicpp-use-equals-delete
            -hicpp-use-override
            -readability-named-parameter
            -*-braces-around-statements
        )
    endif() # Unit or Manual GTEST.

    #Optionally move the tests into one dir.
    option(TEST_DESTINATION_DIR  "Use this directory as the destination <build>/test" ON)
    if( TEST_DESTINATION_DIR )
       set_target_properties( ${_target} PROPERTIES
          RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/test/"
       )
    endif()

    # Add Test functionality.
    if( _arg_TYPE STREQUAL UNIT )
        message( STATUS "${_arg_TYPE} test ${_target} add_test.")
        # Note: If we support other test frameworks will need to do the following:
        if( NOT _arg_NO_DISCOVERY AND NOT CMAKE_CROSSCOMPILING AND ((_arg_FRAMEWORK STREQUAL "GTest") OR (_arg_FRAMEWORK STREQUAL "GMock")) )
            if(CMAKE_BUILD_TYPE STREQUAL "MSan")
                gtest_discover_tests( ${_target}
                    DISCOVERY_MODE PRE_TEST
                    DISCOVERY_TIMEOUT 30
                    PROPERTIES ENVIRONMENT "MSAN_OPTIONS=halt_on_error=0:report_umrs=0"
                )
            else()
                gtest_discover_tests( ${_target} )
            endif()
        else()
            add_test( NAME ${_target} COMMAND ${_command} )
        endif()
    else()
        message( STATUS "Generated ${_arg_TYPE} test ${_target} - not part of unit test runs.")
    endif()

endfunction()
