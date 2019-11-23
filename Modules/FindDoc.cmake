# Copyright (c) 2017 Paul Helter
# add a target to generate API documentation with Doxygen

if(BUILD_DOC)
    find_package(Doxygen REQUIRED dot)
    find_package(PlantUML REQUIRED)

    include(FetchContent)
    FetchContent_Declare(
      wavedrom   
      GIT_REPOSITORY    https://github.com/wavedrom/wavedrom.git
      GIT_TAG           v2.1.2
    )
    #FetchContent_MakeAvailable(wavedrom)
    # Currently assuming these are installed.
#    FetchContent_Declare(
#      doxygenVerilog
#      GIT_REPOSITORY https://github.com/avelure/doxygen-verilog.git
#      GIT_TAG        master
#    )
#    FetchContent_MakeAvailable(doxygenVerilog)
    
    set(DOXYGEN_GENERATE_HTML YES)
    set(DOXYGEN_GENERATE_MAN  NO)
    set(DOXYGEN_OPTIMIZE_OUTPUT_VERILOG YES)
    set(DOXYGEN_OUTPUT_DIRECTORY ./doc)
    
    set(DOXYGEN_WARN_IF_UNDOCUMENTED YES)
    set(DOXYGEN_WARN_IF_DOC_ERROR YES)
    set(DOXYGEN_WARN_NO_PARAMDOC YES)
    set(DOXYGEN_WARN_AS_ERROR    YES)

    # Modify this as needed.    
    set(DOXYGEN_FILE_PATTERNS  
            *.c *.cpp 
            *.h *.hpp
            *.inc
            *.m *.markdown *.md *.mm *.dox
            *.py *.pyw
    )
    set(DOXYGEN_RECURSIVE  YES)
    set(DOXYGEN_USE_MDFILE_AS_MAINPAGE README.md)
    
    set(FRONT_END_ROOT_DIR ${CMAKE_CURRENT_LIST_DIR}/../../)
    set(DOXYGEN_PLANTUML_JAR_PATH ${PLANTUML_JARFILE})    
    
    doxygen_add_docs(doc
        ${PROJECT_SOURCE_DIR}
        #WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
        COMMENT "Generate HTML doucmentation")
        
    # Now for sphinx:
    find_package(Sphinx REQUIRED COMPONENTS build breathe)

    set(SPHINX_SOURCE ${CMAKE_CURRENT_SOURCE_DIR})
    set(SPHINX_BUILD  ${CMAKE_CURRENT_BINARY_DIR}/docs/sphinx)
    add_custom_target(Sphinx ALL
    	COMMAND ${SPHINX_EXECUTABLE} -b html -Dbreathe_projects.${SPHINX_SOURCE} ${SPHINX_BUILD}
        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
        COMMENT "Generating documentation with Sphinx"
    )
    		
    
endif(BUILD_DOC)
