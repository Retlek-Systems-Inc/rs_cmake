# Copyright (c) 2017 Paul Helter

# add a target to generate API documentation with Doxygen
find_package(Doxygen)
             
option(BUILD_DOC "Create and install the HTML based API documentation (requires Doxygen)" ${DOXYGEN_FOUND})

if(BUILD_DOC)
    if(NOT DOXYGEN_FOUND)
        message(FATAL_ERROR "Doxygen is needed to build the documentation.")
    endif()

    set(DOXYGEN_GENERATE_HTML YES)
    set(DOXYGEN_GENERATE_MAN  NO)
    set(DOXYGEN_OPTIMIZE_OUTPUT_VERILOG YES)
    set(DOXYGEN_OUTPUT_DIRECTORY ./doc_output)
    
    set(DOXYGEN_WARN_NO_PARAMDOC YES)
    set(DOXYGEN_WARN_AS_ERROR    NO) # TODO Change this to YES.
    
    set(DOXYGEN_FILE_PATTERNS  
            *.c *.cpp 
            *.h *.hpp
            *.inc
            *.m *.markdown *.md *.mm *.dox
            *.py *.pyw
            *.tcl 
            *.vhd *.vhdl 
            *.sv *.v 
            *.vh *.svh
    )
    set(DOXYGEN_EXTENSION_MAPPING sv=v svh=v vh=v)
    set(DOXYGEN_EXCLUDE_PATTERNS */obj_dir/*)
    
    set(DOXYGEN_RECURSIVE  YES)
    set(DOXYGEN_USE_MDFILE_AS_MAINPAGE Description.md)
    
    set(DOXYGEN_PLANTUML_JAR_PATH ${FRONT_END_ROOT_DIR}/build/plantuml/plantuml.jar)
    set(DOXYGEN_PLANTUML_CFG_FILE ${FRONT_END_ROOT_DIR}/scripts/plantuml_cfg.txt)
    
    #set(DOXYGEN_PROJECT_LOGO )    
    
    doxygen_add_docs(docs
        ${PROJECT_SOURCE_DIR}
        #WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
        COMMENT "Generate HTML doucmentation")

#    set( DOXYFILE_IN  $ENV{CAD_ENV_ROOT}/front-end/scripts/Doxyfile.in )
#    set( DOXYFILE_OUT ${CMAKE_CURRENT_BINARY_DIR}/Doxyfile )

#    configure_file(${DOXYFILE_IN} ${DOXYFILE_OUT} @ONLY)

#    add_custom_target(doc
#    COMMAND ${DOXYGEN_EXECUTABLE} ${DOXYFILE_OUT}
#    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
#    COMMENT "Generating API documentation with Doxygen"
#    VERBATIM)

#    install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/html DESTINATION share/doc)
endif(BUILD_DOC)
