# Copyright (c) 2017 Paul Helter
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