
find_program(CLANG_FORMAT
    NAMES
        clang-format
        clang-format-8
        clang-format-7
        clang-format-6.0
)

if(NOT CLANG_FORMAT)
  message(WARNING "Could not find clang-format, must be installed to update with format.")
  return()
endif()

set(CLANG_FORMAT_CXX_FILE_EXTENSIONS ${CLANG_FORMAT_CXX_FILE_EXTENSIONS} *.cpp *.h *.cxx *.hxx *.hpp *.cc *.ipp)

file(GLOB_RECURSE ALL_SOURCE_FILES ${CLANG_FORMAT_CXX_FILE_EXTENSIONS})
add_custom_target(format
  COMMENT "Reformat source files to match clang-format standard definition"
  COMMAND ${CLANG_FORMAT}
	      -style=file
	      -i
	      ${ALL_SOURCE_FILES}
)