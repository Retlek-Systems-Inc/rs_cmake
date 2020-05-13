# Copyright (c) 2017 Paul Helter
# Adds the necessary information for testing environment with googletest.
# Note googletest/googlemock are down-loaded into the build dir and compiled as part
# of the test environment from there.

if(BUILD_TEST)
	#set(INSTALL_GTEST OFF)
    include(FetchContent)
    FetchContent_Declare( googletest
      GIT_REPOSITORY    git@github.com:google/googletest.git
      GIT_TAG           release-1.10.0
    )

    # Prevent overriding the parent project's compiler/linker
    # settings on Windows
    set(gtest_force_shared_crt ON CACHE BOOL "" FORCE) 


    FetchContent_MakeAvailable(googletest)
    # Add clang-tidy definition to remove any warnings/errors.
    configure_file("${CMAKE_CURRENT_LIST_DIR}/../External/.clang-tidy-Googletest"
                   "${googletest_SOURCE_DIR}/.clang-tidy" COPYONLY)

    add_library(GTest::GTest ALIAS gtest)
    add_library(GTest::Main ALIAS gtest_main)
    add_library(GMock::GMock ALIAS gmock)
    add_library(GMock::Main ALIAS gmock_main)
    
    enable_testing()
    add_definitions(-DBUILD_TEST)
    
    add_custom_target( build_tests ALL )

    include(ProcessorCount)
    ProcessorCount(PROCESSOR_COUNT)
    if(NOT PROCESSOR_COUNT EQUAL 0)
        set(CTEST_BUILD_FLAGS -j${_numProcessors} -V)
        set(ctest_test_args ${ctest_test_args} PARALLEL_LEVEL ${_numProcessors})
    endif()

    # Code analysis
    if (UNIX)
    
        # Create a code coverage target.
        set(_coverageTarget code-coverage)
        string(TOLOWER ${CMAKE_BUILD_TYPE} _buildType)
        if ( ${_buildType} STREQUAL coverage AND NOT TARGET ${_coverageTarget} )
            include(CodeCoverage)
            # Exclude standard and test framework environment builds.
            list(APPEND COVERAGE_LCOV_EXCLUDES
                '/usr/include/*'
                '${googletest_SOURCE_DIR}/*'
            )
            SETUP_TARGET_FOR_COVERAGE_LCOV( 
                NAME ${_coverageTarget}
                EXECUTABLE ctest
                EXECUTABLE_ARGS ${CTEST_BUILD_FLAGS}
                LCOV_ARGS
                    --strip 1
                    --rc lcov_branch_coverage=1
                GENHTML_ARGS
                    --rc genhtml_branch_coverage=1
                    --demangle-cpp
                    --prefix ${CMAKE_SOURCE_DIR}
            )
        endif()

        include(${CMAKE_CURRENT_LIST_DIR}/Sanitizer.cmake)
        SETUP_FOR_SANITIZE(BUILD_TYPE ASAN)
        SETUP_FOR_SANITIZE(BUILD_TYPE TSAN)
        SETUP_FOR_SANITIZE(BUILD_TYPE MSAN)
        SETUP_FOR_SANITIZE(BUILD_TYPE UBSAN)
    endif(UNIX)
endif(BUILD_TEST)
