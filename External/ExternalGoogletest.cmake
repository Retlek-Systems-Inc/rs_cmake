#https://github.com/google/googletest/tree/master/googletest#incorporating-into-an-existing-cmake-project
set(_target googletest)

configure_file(${CMAKE_CURRENT_LIST_DIR}/ExternalGoogletest.cmake.in ${_target}-download/CMakeLists.txt)
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

# Prevent overriding the parent project's compiler/linker
# settings on Windows
set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)

# Add googletest directly to our build. This defines
# the gtest and gtest_main targets.
add_subdirectory(${CMAKE_BINARY_DIR}/${_target}-src
                 ${CMAKE_BINARY_DIR}/${_target}-build
                 EXCLUDE_FROM_ALL)

# Add clang-tidy definition to remove any warnings/errors.
set (source "${CMAKE_CURRENT_LIST_DIR}/.clang-tidy-Googletest")
set (destination "${CMAKE_BINARY_DIR}/${_target}-src/.clang-tidy")
configure_file(${source} ${destination} COPYONLY)

# The gtest/gtest_main targets carry header search path
# dependencies automatically when using CMake 2.8.11 or
# later. Otherwise we have to add them here ourselves.
if (CMAKE_VERSION VERSION_LESS 2.8.11)
  include_directories("${gtest_SOURCE_DIR}/include"
                      "${gmock_SOURCE_DIR}/include")
endif()


add_library(GTest::GTest ALIAS gtest)
add_library(GTest::Main ALIAS gtest_main)
add_library(GMock::GMock ALIAS gmock)
add_library(GMock::Main ALIAS gmock_main)
