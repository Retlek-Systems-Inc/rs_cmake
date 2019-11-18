#https://github.com/google/googletest/tree/master/googletest#incorporating-into-an-existing-cmake-project
set(_target protobuf)

configure_file(${CMAKE_CURRENT_LIST_DIR}/ExternalProtobuf.cmake.in ${_target}-download/CMakeLists.txt)
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
#set(protobuf_BUILD_TESTS OFF CACHE BOOL "" FORCE)
#set(protobuf_BUILD_CONFORMANCE OFF CACHE BOOL "" FORCE)
#set(protobuf_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
#set(protobuf_BUILD_PROTOC_BINARIES OFF CACHE BOOL "" FORCE)
#set(protobuf_BUILD_SHARED_LIBS OFF CACHE BOOL "" FORCE)
#set(protobuf_WITH_ZLIB OFF CACHE BOOL "" FORCE)
#set(protobuf_VERBOSE ON CACHE BOOL "" FORCE)
#set(protobuf_MODULE_COMPATIBLE ON CACHE BOOL "" FORCE)
##set(protobuf_BUILD_EXAMPLES_MULTITEST OFF CACHE BOOL "" FORCE)

# Add googletest directly to our build. This defines
add_subdirectory(${CMAKE_BINARY_DIR}/${_target}-src/cmake
                 ${CMAKE_BINARY_DIR}/${_target}-build
                 EXCLUDE_FROM_ALL)

set (source "${CMAKE_CURRENT_LIST_DIR}/.clang-tidy-Protobuf")
set (destination "${CMAKE_BINARY_DIR}/${_target}-src/.clang-tidy")
configure_file(${source} ${destination} COPYONLY)


# These are some issues with the protobuf - just ignore them for now.
set(_c_compile_options
    -Wno-sign-compare
    -Wno-unused-function
)
    
set(_cxx_compile_options
    -Wno-sign-compare
    -Wno-unused-function
)

#set(_protobuf_targets libprotobuf.a libprotobuf-lite.a libprotoc.a)
#foreach(_target ${_protobuf_targets} )
#    target_compile_options(${_target}
#        PRIVATE
#            $<$<COMPILE_LANGUAGE:C>:${_c_compile_options}>
#            $<$<COMPILE_LANGUAGE:CXX>:${_cxx_compile_options}>
#    )
#endforeach(_target ${_protobuf_targets} )

# Settings for FindProtobuf.
#set(Protobuf_SRC_ROOT_FOLDER ${CMAKE_BINAR_DIR}/${_target}-src CACHE STRING "used for source root" FORCE)
#set(Protobuf_USE_STATIC_LIBS ON CACHE BOOL "Protobuf use static libs" FORCE  )
#set(Protobuf_DIR ${CMAKE_BINARY_DIR}/${_target}-build/lib/cmake/protobuf CACHE STRING "" FORCE)

# The gtest/gtest_main targets carry header search path
# dependencies automatically when using CMake 2.8.11 or
# later. Otherwise we have to add them here ourselves.
#if (CMAKE_VERSION VERSION_LESS 2.8.11)
#  include_directories("${protobuf_SOURCE_DIR}/include")
#endif()

