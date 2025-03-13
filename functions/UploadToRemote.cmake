#######################################################################
# @copyright 2025 Retlek Systems Inc.
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

CheckUploadToRemote
-------------------

Confirms all of the executables are available on both remote and local host
for UploadToRemote(...) calls.

CheckUploadToRemote(
  REMOTE_USER <user>
  REMOTE_HOST <hostname>
)

Examples:

.. code-block:: cmake

  CheckUploadToRemote(
    REMOTE_USER user
    REMOTE_HOST hostname
  )
The following variables are defined by this function:

.. variable:: SSH_EXE    ssh executable
.. variable:: RSYNC_EXE  rsync executable optional
.. variable:: SCP_EXE    ssh copy executable (optional if RSYNC_EXE supported)


UploadToRemote
--------------

Uploads either the results of a target or a resource directory to a remote
host using either scp or rsync, depending on what is available.

UploadToRemote(
  <TARGET|DIRECTORY|FILE> <item to upload from local host>
  [TARGET_NAME <created target name>]
  REMOTE_USER <user>
  REMOTE_HOST <hostname>
  REMOTE_DEST <remote directory to write to>
)

Examples:

.. code-block:: cmake

  UploadToRemote(TARGET MyTargetExe
    REMOTE_USER user 
    REMOTE_HOST hostname
    REMOTE_DEST ~/uploads
  )
  if(NOT TARGET UploadToRemote_MyTargetExe)
     message(WARNING "UploadToRemote failed.")
  endif()

  UploadToRemote(DIRECTORY ${CMAKE_SOURCE_DIR}/resource
    TARGET_NAME Res
    REMOTE_USER user
    REMOTE_HOST hostname
    REMOTE_DEST ~/uploads
  )
  if(NOT TARGET UploadToRemote_Res)
     message(WARNING "UploadToRemote failed.")
  endif()

  UploadToRemote(FILE ${CMAKE_SOURCE_DIR}/version.txt
    TARGET_NAME Version
    REMOTE_USER user
    REMOTE_HOST hostname
    REMOTE_DEST ~/uploads
  )
  if(NOT TARGET UploadToRemote_Version)
     message(WARNING "UploadToRemote failed.")
  endif()

The following targets are defined by this function:

.. variable:: UploadToRemote_<target name> OR UploadToRemote_<created target name>
.. variable:: UploadToRemoteAll - for all targets.

Where the created target name is:
   TARGET <target> - the target's name
   DIRECTORY <directory> - the last directory's name
   FILE <file path> - the file name of the file path

#]=======================================================================]


function( CheckUploadToRemote )
    set( _options )
    set( _oneValueArgs REMOTE_USER REMOTE_HOST)
    set( _multiValueArgs )
    include( CMakeParseArguments )
    cmake_parse_arguments( "_arg" "${_options}" "${_oneValueArgs}" "${_multiValueArgs}" ${ARGN} )

    if( _arg_UNPARSED_ARGUMENTS )
        message( FATAL_ERROR "Unknown argument(s) to CheckUploadMode: ${_arg_UNPARSED_ARGUMENTS}" )
    endif()

    if(NOT _arg_REMOTE_USER)
        message( FATAL_ERROR "Must specify REMOTE_USER <user> name - eg: 'user'" )
    endif()

    if(NOT _arg_REMOTE_HOST)
        message( FATAL_ERROR "Must specify REMOTE_HOST <hostname> name - eg: 'hostname'" )
    endif()

    find_program(SSH_EXE NAMES ssh )
    find_program(RSYNC_EXE NAMES rsync )
    find_program(SCP_EXE NAMES scp )

    set(REMOTE   "${_arg_REMOTE_USER}@${_arg_REMOTE_HOST}")

    execute_process(
        COMMAND ${SSH_EXE} -q -o BatchMode=yes -o ConnectTimeout=5 ${REMOTE} exit
        RESULT_VARIABLE SSH_RESULT
        OUTPUT_QUIET ERROR_QUIET
    )
    if(SSH_RESULT EQUAL 0)
        message(STATUS "CheckUploadToRemote: SSH connection to '${REMOTE}' successful.")
        set(SSH_EXE ${SSH_EXE} PARENT_SCOPE)
    else()
        message(WARNING "CheckUploadToRemote: SSH connection to '${REMOTE}' failed. Ensure credentials and network settings are correct.")
        return()
    endif()

    # Check if rsync is available on the remote machine
    if(RSYNC_EXE)
        execute_process(
            COMMAND ${SSH_EXE} ${REMOTE} rsync --version
            RESULT_VARIABLE RSYNC_RESULT
            ERROR_QUIET
        )
        if(RSYNC_RESULT EQUAL 0)
            message(STATUS "CheckUploadToRemote: 'rsync' is available on the remote machine '${REMOTE}'")
            set(RSYNC_EXE ${RSYNC_EXE} PARENT_SCOPE)
            return()
        else()
            message(STATUS "CheckUploadToRemote: 'rsync' is NOT available on the remote machine '${REMOTE}'")
            #continue
        endif()
    else()
        message(STATUS "CheckUploadToRemote: 'rsync' is NOT installed locally.")
        #continue
    endif()

    if(SCP_EXE)
        # Check if SCP is available on the remote machine
        execute_process(
            COMMAND ${SSH_EXE} ${REMOTE} command -v scp
            RESULT_VARIABLE SCP_RESULT
            OUTPUT_QUIET ERROR_QUIET
        )
        if(SCP_RESULT EQUAL 0)
            message(STATUS "CheckUploadToRemote: 'scp' is available on the remote machine '${REMOTE}'")
            set(SCP_EXE ${SCP_EXE} PARENT_SCOPE)
        else()
            message(WARNING "CheckUploadToRemote: Neither 'rsync' nor 'scp' is available on the remote machine '${REMOTE}'. Unable to support 'UploadToRemote'.")
        endif()
    else()
        message(WARNING "CheckUploadToRemote: 'scp' is NOT installed locally. Unable to support 'UploadToRemote'")
    endif()
endfunction()


function( UploadToRemote )
    set( _options )
    set( _oneValueArgs TARGET DIRECTORY FILE TARGET_NAME REMOTE_USER REMOTE_HOST REMOTE_DEST)
    set( _multiValueArgs )
    include( CMakeParseArguments )
    cmake_parse_arguments( "_arg" "${_options}" "${_oneValueArgs}" "${_multiValueArgs}" ${ARGN} )

    if( _arg_UNPARSED_ARGUMENTS )
        message( FATAL_ERROR "Unknown argument(s) to UploadToRemote: ${_arg_UNPARSED_ARGUMENTS}" )
    endif()

    if (NOT (_arg_TARGET OR _arg_DIRECTORY OR _arg_FILE ))
        message( FATAL_ERROR "Must specify only one of TARGET, DIRECTORY, or FILE")
    elseif(_arg_TARGET AND (_arg_DIRECTORY OR _arg FILE) OR (_arg_DIRECTORY AND _arg_FILE))
        message(FATAL_ERROR "Multiple TARGET, DIRECTORY, FILE specified, only support one type")
    endif()
    
    if(NOT _arg_REMOTE_USER)
        message( FATAL_ERROR "Must specify REMOTE_USER <user> name - eg: 'user'" )
    endif()

    if(NOT _arg_REMOTE_HOST)
        message( FATAL_ERROR "Must specify REMOTE_HOST <hostname> name - eg: 'hostname'" )
    endif()

    if(NOT _arg_REMOTE_DEST)
        message( FATAL_ERROR "Must specify REMOTE_DEST <destination directory> name - eg: '~/uploads'" )
    endif()

    # Check remote accessibility
    set(HOST_DEST   "${_arg_REMOTE_USER}@${_arg_REMOTE_HOST}")
    set(DESTINATION "${HOST_DEST}:${_arg_REMOTE_DEST}")

    if (NOT (SSH_EXE AND (RSYNC_EXE OR SCP_EXE)))
        message(WARNING "UploadToRemote: Cannot access remote host: ${HOST_DEST}. UploadToRemote disabled.")
        return()
    endif()

    # Determine the local source path and UploadToRemote Target name
    set (TARGET_NAME "UploadToRemote_${_arg_TARGET_NAME}")
    if (_arg_TARGET)
        if (NOT TARGET ${_arg_TARGET})
            message( FATAL_ERROR "Unknown TARGET: ${_arg_TARGET}")
        endif()
        if (NOT _arg_TARGET_NAME)
            set(TARGET_NAME "UploadToRemote_${_arg_TARGET}")
        endif()
    elseif (_arg_DIRECTORY)
        if (NOT EXISTS ${_arg_DIRECTORY})
            message(FATAL_ERROR "Specified DIRECTORY does not exist: ${_arg_DIRECTORY}")
        endif()
        set(SOURCE_PATH "${_arg_DIRECTORY}")
        file(GLOB_RECURSE DEP_FILES CONFIGURE_DEPENDS "${SOURCE_PATH}/*" )
        if (NOT _arg_TARGET_NAME)
            get_filename_component(DIR_NAME ${_arg_DIRECTORY} NAME)
            set(TARGET_NAME "UploadToRemote_${DIR_NAME}")
        endif()
    elseif (_arg_FILE)
        if (NOT EXISTS ${_arg_FILE})
            message(FATAL_ERROR "Specified FILE does not exist: ${_arg_FILE}")
        endif()
        set(SOURCE_PATH "${_arg_FILE}")
        set(DEP_FILES "${SOURCE_PATH}")
        if (NOT _arg_TARGET_NAME)
            get_filename_component(FILE_NAME ${_arg_FILE} NAME)
            set(TARGET_NAME "UploadToRemote_${FILE_NAME}")
        endif()
    endif()

    #Prioritize RSYNC over SCP.
    set(UPLOAD_OUTPUT_FILE "${CMAKE_BINARY_DIR}/upload_stamp_${TARGET_NAME}")
    if (RSYNC_EXE)
        if (_arg_TARGET)
            add_custom_command(
                OUTPUT ${UPLOAD_OUTPUT_FILE}
                DEPENDS ${_arg_TARGET}
                COMMAND ${RSYNC_EXE} -avz $<TARGET_FILE:${_arg_TARGET}> ${DESTINATION}
                COMMAND ${CMAKE_COMMAND} -E touch ${UPLOAD_OUTPUT_FILE} # Create timestamp file.
                COMMENT "Uploading (rsync) '$<TARGET_FILE:${_arg_TARGET}>' to '${DESTINATION}'")
        else()
            add_custom_command(
                OUTPUT ${UPLOAD_OUTPUT_FILE}
                DEPENDS ${DEP_FILES}
                COMMAND ${RSYNC_EXE} -avz ${SOURCE_PATH} ${DESTINATION}
                COMMAND ${CMAKE_COMMAND} -E touch ${UPLOAD_OUTPUT_FILE} # Create timestamp file.
                COMMENT "Uploading (rsync) '${SOURCE_PATH}' to '${DESTINATION}'")
        endif()
    elseif (SCP_EXE)
        if (_arg_TARGET)
            add_custom_command(
                OUTPUT ${UPLOAD_OUTPUT_FILE}
                DEPENDS ${_arg_TARGET}
                COMMAND ${SSH_EXE} ${HOST_DEST} "mkdir -p ${_arg_REMOTE_DEST}"
                COMMAND ${SCP_EXE} -r $<TARGET_FILE:${_arg_TARGET}> ${DESTINATION}
                COMMAND ${CMAKE_COMMAND} -E touch ${UPLOAD_OUTPUT_FILE} # Create timestamp file.
                COMMENT "Uploading (scp) '$<TARGET_FILE:${_arg_TARGET}>' to '${DESTINATION}'")
        else()
            add_custom_command(
                OUTPUT ${UPLOAD_OUTPUT_FILE}
                DEPENDS ${DEP_FILES}
                COMMAND ${SSH_EXE} ${HOST_DEST} "mkdir -p ${_arg_REMOTE_DEST}"
                COMMAND ${SCP_EXE} -r ${SOURCE_PATH} ${DESTINATION}
                COMMAND ${CMAKE_COMMAND} -E touch ${UPLOAD_OUTPUT_FILE} # Create timestamp file.
                COMMENT "Uploading (scp) '${SOURCE_PATH}' to '${DESTINATION}'")
        endif()
    else()
        message(FATAL_ERROR "UploadToRemote: Neither rsync nor (scp + ssh) is available for file transfer.")
    endif()
    add_custom_target( ${TARGET_NAME} DEPENDS ${UPLOAD_OUTPUT_FILE})
    message(STATUS "UploadToRemote: Created target '${TARGET_NAME}'")

    if(TARGET ${TARGET_NAME})
        if (NOT TARGET "UploadToRemoteAll")
            add_custom_target(UploadToRemoteAll
                COMMENT "Uploading All function")
            message(STATUS "UploadToRemote: Created target 'UploadToRemoteAll' for All uploads")
        endif()
        add_dependencies(UploadToRemoteAll ${TARGET_NAME})
    endif()
endfunction()
