#######################################################################
# @copyright 2026 Retlek Systems Inc.
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
GenerateUmlDocs
----------

Creates UML Docs of a target.

GenerateUmlDocs( <target name> )

Examples:

.. code-block:: cmake

  # First setup virtual env.
  GenerateUmlDocs( my_target )

The following variables are defined by this module:

None

Execution of clang_uml will result in the target directory docs dir being
updated with an:
- API Class diagram
- Implementation Class diagram
- etc.
#]=======================================================================]

# Used for GenerateUmlDocs relative directory.
set(_GenerateUmlDocs_DIR ${CMAKE_CURRENT_LIST_DIR} CACHE INTERNAL "")

function(GenerateUmlDocs TARGET_NAME)

    if(NOT TARGET "${TARGET_NAME}")
        message(FATAL_ERROR "generate_uml_docs(): target '${TARGET_NAME}' does not exist")
    endif()

    get_target_property(TARGET_SOURCE_DIR "${TARGET_NAME}" SOURCE_DIR)

    set(DOCS_SOURCE_DIR   "${TARGET_SOURCE_DIR}/doc")
    set(DOCS_BINARY_DIR   "${CMAKE_CURRENT_BINARY_DIR}/doc/")
    set(CLANG_UML_CONFIG  "${DOCS_BINARY_DIR}/.clang-uml")

    file(MAKE_DIRECTORY "${DOCS_BINARY_DIR}" )

    set(CLANG_UML_COMPILATION_DATABASE_DIR "${CMAKE_BINARY_DIR}")
    set(CLANG_UML_OUTPUT_DIRECTORY         "${DOCS_SOURCE_DIR}")
    set(MODULE_SOURCE_DIR                  "${TARGET_SOURCE_DIR}")

    configure_file(
        "${_GenerateUmlDocs_DIR}/.clang-uml.in"
        "${CLANG_UML_CONFIG}"
        @ONLY
    )

    set(DOC_TARGET "${TARGET_NAME}_umldoc" )

    add_custom_target("${DOC_TARGET}"
        COMMAND clang-uml --config "${CLANG_UML_CONFIG}" --generator mermaid
        WORKING_DIRECTORY "${DOCS_BINARY_DIR}"
        DEPENDS "${TARGET_NAME}" "${CLANG_UML_CONFIG}"
        VERBATIM
    )

endfunction()