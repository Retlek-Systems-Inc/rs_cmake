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

# add a target to format info

if(FORMATTER)
    option(USE_CLANG_FORMAT "Use Clang Format." ON)

    if (USE_CLANG_FORMAT)
      find_program(CLANG_FORMAT 
        NAMES
            clang-format
            clang-format-8
            clang-format-7
            clang-format-6.0
            clang-format-4.0
      )
      if(NOT CLANG_FORMAT)
            message(WARNING "Could not find clang-format, must be installed to format itmes.")
        else()
            set(CMAKE_C_CLANG_FORMAT ${CLANG_FORMAT} "-format-style=file")
            set(CMAKE_CXX_CLANG_FORMAT ${CLANG_FORMAT} "-format-style=file")
        endif()
    endif()    
endif(FORMATTER)

  foreach(clangformat_source ${ARGV})
    get_filename_component(clangformat_source ${clangformat_source} ABSOLUTE)
    list(APPEND clangformat_sources ${clangformat_source})
  endforeach()

  add_custom_target(${PROJECT_NAME}_clangformat
    COMMAND
      ${CLANGFORMAT_EXECUTABLE}
      -style=file
      -i
      ${clangformat_sources}
    COMMENT
      "Formating with ${CLANGFORMAT_EXECUTABLE} ..."
  )

  if(TARGET clangformat)
    add_dependencies(clangformat ${PROJECT_NAME}_clangformat)
  else()
    add_custom_target(clangformat DEPENDS ${PROJECT_NAME}_clangformat)
  endif()
endfunction()

function(target_clangformat_setup target)
  get_target_property(target_sources ${target} SOURCES)
  clangformat_setup(${target_sources})
endfunction()