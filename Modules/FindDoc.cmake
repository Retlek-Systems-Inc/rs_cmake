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

# add a target to generate API documentation with Doxygen

if(BUILD_DOC)
    find_package(Doxygen REQUIRED dot)
    find_package(PlantUML REQUIRED)
   
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
#    find_package(Sphinx REQUIRED COMPONENTS build breathe)
#
#    set(SPHINX_SOURCE ${CMAKE_CURRENT_SOURCE_DIR})
#    set(SPHINX_BUILD  ${CMAKE_CURRENT_BINARY_DIR}/docs/sphinx)
#    add_custom_target(Sphinx ALL
#    	COMMAND ${SPHINX_EXECUTABLE} -b html -Dbreathe_projects.${SPHINX_SOURCE} ${SPHINX_BUILD}
#        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
#        COMMENT "Generating documentation with Sphinx"
#    )

endif(BUILD_DOC)
