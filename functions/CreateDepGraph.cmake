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
Create Dependency Graph
-----------------------

Creates a target that will execute and create the dependency graph for this
project

Examples:

.. code-block:: cmake

  add_dependency_graph_target(dep_graph)

There are no variables that are defined only the target.
Will create a generate_<dep_graph> target which is part of the all function.
.. variable:: PY_<module> which contains the spec information of the module.


#]=======================================================================]

function(add_dependency_graph_target target_name)
    # Define the directory for dependency .dot files
    set(DEPENDENCY_DOT_DIR ${CMAKE_BINARY_DIR}/${target_name}_files)
    file(MAKE_DIRECTORY ${DEPENDENCY_DOT_DIR})

    # Custom command to generate the .dot file
    add_custom_command(
        OUTPUT ${DEPENDENCY_DOT_DIR}/deps.dot
        COMMAND cmake -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -DFETCHCONTENT_BASE_DIR=${FETCH_CONTENT_BASE_DIR} --graphviz=${DEPENDENCY_DOT_DIR}/deps.dot .
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        VERBATIM
    )

    # Custom target for Graphviz generation
    add_custom_target(
        generate_${target_name}
        DEPENDS ${DEPENDENCY_DOT_DIR}/deps.dot
    )

    # Add dependencies to the target
    get_target_property(_targets_all GLOBAL TARGETS)
    add_dependencies(generate_${target_name} ${_targets_all})
endfunction()
