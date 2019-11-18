# Copyright (c) 2017 Paul Helter
# Function to create a Version File.

# GitHash
# Creates the output variable GIT_HASH based on the current hash of the git repo.
# Adds '-dirty' if the git repo is dirty.
# Returns "Unknown" if can't find GIT.

function( GitHash )
    set(_git_hash "unknown")
    find_package(Git)
    if (GIT_FOUND)
        execute_process(
            COMMAND ${GIT_EXECUTABLE} rev-parse --short HEAD
            WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
            OUTPUT_VARIABLE _git_hash
            ERROR_QUIET
            OUTPUT_STRIP_TRAILING_WHITESPACE
        )
        execute_process(
            COMMAND ${GIT_EXECUTABLE} diff --quiet HEAD --
            WORKING_DIRECOTRY "${CMAKE_CURRENT_SOURCE_DIR}"
            RESULT_VARIABLE _git_dirty
            OUTPUT_VARIABLE _git_dirty_out
            ERROR_QUIET
            OUTPUT_STRIP_TRAILING_WHITESPACE
        )
        if (_git_dirty EQUAL 0 )
            set( GIT_HASH "${_git_hash}" PARENT_SCOPE )
        else()
            set( GIT_HASH "${_git_hash}-dirty" PARENT_SCOPE )
        endif()
        set( GIT_HASH_ONLY "${_git_hash}" PARENT_SCOPE )
#        message( STATUS "Git Hash: ${_git_hash}")
    else()
        message( STATUS "Git not found")
    endif()
endfunction()
