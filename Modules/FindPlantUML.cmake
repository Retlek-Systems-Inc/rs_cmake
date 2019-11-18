# Copyright (c) 2017 Paul Helter

if(NOT DEFINED PlantUML_FOUND)

  find_file(PLANTUML_JARFILE
    NAMES plantuml.jar
    HINTS "" "~/java" ENV PLANTUML_DIR
  )
  
  include(FindPackageHandleStandardArgs)
  find_package_handle_standard_args(PlantUML DEFAULT_MSG PLANTUML_JARFILE)
  
  if (PlantUML_FOUND)
    message( STATUS "Found PlantUML: ${PLANTUML_JARFILE}" )
  endif()
endif()
