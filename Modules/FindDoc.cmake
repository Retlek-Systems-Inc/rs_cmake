# Copyright (c) 2017 Paul Helter

# add a target to generate API documentation with Doxygen
find_package(Doxygen)
             
option(BUILD_DOC "Create and install the HTML based API documentation (requires Doxygen)" ${DOXYGEN_FOUND})

if(BUILD_DOC)
    if(NOT DOXYGEN_FOUND)
        message(FATAL_ERROR "Doxygen is needed to build the documentation.")
    endif()

    set( DOXYFILE_IN  $ENV{CAD_ENV_ROOT}/front-end/scripts/Doxyfile.in )
    set( DOXYFILE_OUT ${CMAKE_CURRENT_BINARY_DIR}/Doxyfile )

    configure_file(${DOXYFILE_IN} ${DOXYFILE_OUT} @ONLY)

    add_custom_target(doc
    COMMAND ${DOXYGEN_EXECUTABLE} ${DOXYFILE_OUT}
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    COMMENT "Generating API documentation with Doxygen"
    VERBATIM)

#    install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/html DESTINATION share/doc)
endif(BUILD_DOC)
