#https://github.com/google/googletest/tree/master/googletest#incorporating-into-an-existing-cmake-project
set(_target verilator)

configure_file(${CMAKE_CURRENT_LIST_DIR}/ExternalVerilator.cmake.in ${_target}-download/CMakeLists.txt)
execute_process(COMMAND ${CMAKE_COMMAND} -G "${CMAKE_GENERATOR}" .
  RESULT_VARIABLE result
  WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/${_target}-download )
if(result)
  message(FATAL_ERROR "CMake step for ${_target} failed: ${result}")
endif()
execute_process(COMMAND ${CMAKE_COMMAND} --build .
  RESULT_VARIABLE result
  WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/${_target}-download )
if(result)
  message(FATAL_ERROR "Build step for ${_target} failed: ${result}")
endif()

# Add googletest directly to our build. This defines
# the gtest and gtest_main targets.
add_subdirectory(${CMAKE_BINARY_DIR}/${_target}-src
                 ${CMAKE_BINARY_DIR}/${_target}-build
                 EXCLUDE_FROM_ALL)

# Add clang-tidy definition to remove any warnings/errors.
set (source "${CMAKE_CURRENT_LIST_DIR}/.clang-tidy-Googletest")
set (destination "${CMAKE_BINARY_DIR}/${_target}-src/.clang-tidy")
configure_file(${source} ${destination} COPYONLY)

add_library(Verilator::GTest ALIAS gtest)
add_library(GTest::Main ALIAS gtest_main)
add_library(GMock::GMock ALIAS gmock)
add_library(GMock::Main ALIAS gmock_main)
