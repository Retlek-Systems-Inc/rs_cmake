# Copyright (c) 2019 Paul Helter
#[=======================================================================[.rst:
FindSphinx
----------

Sphinx is a documentation generation tool (see http://http://www.sphinx-doc.org).
This module looks for Sphinx and some optional tools it supports. These
tools are enabled as components in the :command:`find_package` command:

``sphinx``
  `Sphinx <http://www.sphinx-doc.org/en/master/usage/quickstart.html#running-the-build>`_ ``sphinx-build`` 
  utility used to convert rst, md and other style code into the Sphinx documentation.

``quickstart``
  `Sphinx <https://www.sphinx-doc.org/en/master/man/sphinx-quickstart.html>`_ ``sphinx-quickstart`` utility used to generate
  simple startup configuration files.

``autogen``
  `Sphinx <https://www.sphinx-doc.org/en/master/man/sphinx-autogen.html>`_ ``sphinx-autogen`` utility used to autogenerate
  python documentation.

``apidoc``
  `Sphinx <https://www.sphinx-doc.org/en/master/man/sphinx-apidoc.html>`_ ``sphinx-autogen`` utility used to document
  python package.
  
``breathe``
  `Breathe <https://breathe.readthedocs.io>`_ ``breathe`` utility used to convert
  doxygen style html documentation into the Sphinx documentation.

  Note for further Doxyen setup please see FindDoxygen.cmake - all of those components
  also apply here: ``dot``, ``mscgen``, ``dia``
  
Examples:

.. code-block:: cmake

  # Require breathe, treat the other components as optional
  find_package(Doxygen 
    REQUIRED dot 
    OPTIONAL_COMPONENTS mscgen dia
  )
  find_package(Sphinx
    REQUIRED breathe
  )

The following variables are defined by this module:

.. variable:: Sphinx_FOUND

  True if the ``sphinx-build`` executable was found.

.. variable:: SPHINX_VERSION

  The version reported by ``sphinx-build --version``.

The module defines ``IMPORTED`` targets for Sphinx and each component found.
These can be used as part of custom commands, etc. and should be preferred over
old-style (and now deprecated) variables like ``SPHINX_EXECUTABLE``. The
following import targets are defined if their corresponding executable could be
found (the component import targets will only be defined if that component was
requested):

::
  Sphinx::build (sphinx-build)
  Sphinx::quickstart
  Sphinx::apidoc
  Sphinx::autogen
  Sphinx::breathe

Functions
^^^^^^^^^

.. command:: sphinx_configure

  This function is intended as a convenience for configuring a conf.py and index.rst
  top level for landing page for documentation of this module.  This calls Sphinx::quickstart
  and uses this along with configuration settings to configure the project.
  TODO: Necessary with conf.py.in file?
  

.. command:: sphinx_add_docs

  This function is intended as a convenience for adding a target for generating
  documentation with Sphinx. It aims to provide sensible defaults so that
  projects can generally just provide the input files and directories and that
  will be sufficient to give sensible results. The function supports the
  ability to customize the Sphinx configuration used to build the
  documentation.

  ::

    sphinx_add_docs(targetName
        [filesOrDirs...]
        [ALL]
        [WORKING_DIRECTORY dir]
        [COMMENT comment])

  The function constructs a ``conf.py`` Sphinx configuration file and defines a 
  custom target that runs Sphinx on that generated file. The listed files and 
  directories are used as the ``INPUT`` of the generated ``Doxyfile`` and they can 
  contain wildcards.
  Any files that are listed explicitly will also be added as ``SOURCES`` of the
  custom target so they will show up in an IDE project's source list.

  So that relative input paths work as expected, by default the working
  directory of the Sphinx command will be the current source directory (i.e.
  :variable:`CMAKE_CURRENT_SOURCE_DIR`). This can be overridden with the
  ``WORKING_DIRECTORY`` option to change the directory used as the relative
  base point.

  If provided, the optional ``comment`` will be passed as the ``COMMENT`` for
  the :command:`add_custom_target` command used to create the custom target
  internally.

  If ALL is set, the target will be added to the default build target.

  The contents of the generated ``conf.py`` Sphinx configuration file can be 
  customized by setting CMake variables before calling ``sphinx_add_docs()``. 
  Any variable with a name of the form ``SPHINX_<tag>`` will have its value 
  substituted for the corresponding ``<tag>`` configuration option in the 
  ``conf.py``. See the `Sphinx documentation <https://www.sphinx-doc.org/en/master/usage/configuration.html>`_ for the
  full list of supported configuration options.

  Some of Sphinx defaults are overridden to provide more appropriate
  behavior for a CMake project. Each of the following will be explicitly set
  unless the variable already has a value before ``sphinx_add_docs()`` is
  called (with some exceptions noted):

  .. variable:: SPHINX_PROJECT (project)

    Populated with the name of the current project (i.e.
    :variable:`PROJECT_NAME`).

  .. variable:: SPHINX_VERSION (version)

    Populated with the version of the current project (i.e.
    :variable:`PROJECT_VERSION`).

  .. variable:: SPINX_RELEASE (release)

    Populated with the version of the current project (i.e.
    :variable:`PROJECT_VERSION`).

  .. variable:: SPHINX_EXCLUDE_PATTERNS (exclude_patterns)

    If the set of inputs includes directories, this variable will specify
    patterns used to exclude files from them. The following patterns are added
    by ``sphinx_add_docs()`` to ensure CMake-specific files and directories
    are not included in the input. If the project sets
    ``SPHINX_EXCLUDE_PATTERNS``, those contents are merged with these
    additional patterns rather than replacing them:

    ::

      */.git/*
      */.svn/*
      */.hg/*
      */CMakeFiles/*
      */_CPack_Packages/*
      DartConfiguration.tcl
      CMakeLists.txt
      CMakeCache.txt

  .. variable:: SPHINX_NEEDS_SPHINX (needs_spinx)
  
    Populated with the ``find_package(Sphinx [version] ..)``` version specified.
  
  .. variable:: SPHINX_OUTPUT_DIRECTORY

    Set to :variable:`CMAKE_CURRENT_BINARY_DIR` by this module. Note that if
    the project provides its own value for this and it is a relative path, it
    will be converted to an absolute path relative to the current binary
    directory. This is necessary because sphinx will normally be run from a
    directory within the source tree so that relative source paths work as
    expected. If this directory does not exist, it will be recursively created
    prior to executing the sphinx commands.

To change any of these defaults or override any other sphinx config option,
set relevant variables before calling ``sphinx_add_docs()``. For example:

  .. code-block:: cmake

    set(SPHINX_KEEP_WARNINGS YES)
    set(SPHINX_NITPICKY NO)
    set(SPHINX_COPYRIGHT "Copyright 2019 - test")

    sphinx_add_docs(
        sphinx_docs
        ${PROJECT_SOURCE_DIR}
        COMMENT "Generate documentation"
    )

A number of Sphinx config options accept lists of values, and Sphinx requires
them to be in python format. CMake variables hold lists as a string with
items separated by semi-colons, so a conversion needs to be performed. The
``sphinx_add_docs()`` command specifically checks the following Sphinx config
options and will convert their associated CMake variable's contents into the
required form if set.  The single value Sphinx options will be quoted automatically

::

# .. variable:: SPINX_COPYRIGHT (copyright)
# .. variable:: SPINX_AUTHOR (author)
# .. variable:: SPHINX_EXTENSIONS (extensions)
# .. variable:: SPHINX_SOURCE_SUFFIX (source_suffix)
# .. variable:: SPHINX_SOURCE_ENCODING (source_encoding)
# .. variable:: SPHINX_SOURCE_PARSERS (source_parsers)
# .. variable:: SPHINX_MASTER_DOC (master_doc)
# .. variable:: SPHINX_TEMPLATES_PATH (templates_path)
# .. variable:: SPHINX_TEMPLATE_BRIDGE (templates_bridge)
# .. variable:: SPHINX_RST_EPILOG (rst_epilog)
# .. variable:: SPHINX_RST_PROLOG (rst_prolog)
# .. variable:: SPHINX_PRIMARY_DOMAIN (primary_domain)
# .. variable:: SPHINX_DEFAULT_ROLE (default_role)
# .. variable:: SPHINX_KEEP_WARNINGS (keep_warnings)
# .. variable:: SPHINX_SUPPRESS_WARNINGS (suppress_warnings)
# .. variable:: SPHINX_NEEDS_EXTENSIONS (needs_extensions)
# .. variable:: SPHINX_MANPAGES_URL (manpages_url)
# .. variable:: SPHINX_NITPICKY (nitpicky)
# .. variable:: SPHINX_NITPICK_IGNORE (nitpick_ignore)
# .. variable:: SPHINX_NITPICK_IGNORE (nitpick_ignore)
# .. variable:: SPHINX_NUMFIG (numfig)
# .. variable:: SPHINX_NUMFIG_FORMAT (numfig_FORMAT)
# .. variable:: html_theme
# .. variable:: html_static_path

Deprecated Result Variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^

For compatibility with previous versions of CMake, the following variables
are also defined but they are deprecated and should no longer be used:

.. variable:: SPHINX_EXECUTABLE

  The path to the ``sphinx-build`` command. If projects need to refer to the
  ``sphinx-build`` executable directly, they should use the ``Sphinx::build``
  import target instead.

#]=======================================================================]


#
# Find spinx build
#
macro(_Sphinx_find_build )

    find_program(
        SPHINX_EXECUTABLE
        NAMES sphinx-build
        HINTS
          $ENV{SPHINX_DIR}
        PATH_SUFFIXES bin
        PATHS
          #${PYTHON_LIBRARIES}
        DOC "Sphinx documentation generation tool (build) (http://www.sphinx-doc.org)"
    )

	mark_as_advanced(SPHINX_EXECUTABLE)

    if(SPHINX_EXECUTABLE)
        execute_process(
            COMMAND "${SPHINX_EXECUTABLE}" --version
            OUTPUT_VARIABLE SPHINX_VERSION
            OUTPUT_STRIP_TRAILING_WHITESPACE
            RESULT_VARIABLE _Sphinx_version_result
        )
        string(REGEX REPLACE ".*sphinx-build ([0-9]+.[0-9]+.[0-9]+[a-z]*).*" "\\1" SPHINX_VERSION "${SPHINX_VERSION}")
        if(_Sphinx_version_result)
            message(WARNING "Unable to determine Sphinx version: ${_Sphinx_version_result}")
        endif()

        # Create an imported target for Sphinx exe.
        if(NOT TARGET Sphinx::build)
            add_executable( Sphinx::build IMPORTED GLOBAL)
            set_target_properties( Sphinx::build PROPERTIES
                IMPORTED_LOCATION "${SPHINX_EXECUTABLE}"
            )
        endif()
    endif()
endmacro()

#
# Find Sphinx executables...
#
macro(_Sphinx_find_exe exe_name )

    string( TOUPPER "sphinx-${exe_name}" _EXE_NAME )
	
    find_program(
        _EXE_VAR
        NAMES ${_EXE_NAME}
        HINTS
          $ENV{SPHINX_DIR}
        PATH_SUFFIXES bin
        PATHS
          #${PYTHON_LIBRARIES}
        DOC "Sphinx documentation generation tool (${exe_name}) (http://www.sphinx-doc.org)"
    )

    if(${_EXE_VAR})
        # Create an imported target for Sphinx exe.
        if(NOT TARGET Sphinx::${exe_name})
            add_executable(Sphinx::${exe_name} IMPORTED GLOBAL)
            set_target_properties(Sphinx::${exe_name} PROPERTIES
                IMPORTED_LOCATION "${_EXE_VAR}"
            )
        endif()
    endif()
endmacro()


#
# Find Sphinx breathe...
#
macro(_Sphinx_find_breathe)
 # TODO: Need to implement.
 # For now just set to build.
# BREATHE_PATH
# Project - points to toxyxml
# default_project
# extensions - need to add breathe.

   find_python_module("breathe")

   if(NOT PY_breathe_FOUND)
     if(NOT TARGET Sphinx::breathe)
       add_executable(Sphinx::breathe IMPORTED GLOBAL)
       set_target_properties(Sphinx::breathe PROPERTIES
         IMPORTED_LOCATION "${Python3_LIBRARY}"
       )
     endif()
   endif()
endmacro()


#
# Find Sphinx...
#
find_python_module("sphinx")
if(NOT PY_SPHINX)
  message(FATAL_ERROR "Unable to find Python3 Package 'sphinx'")
endif()

# Make sure `build` is one of the components to find
if(NOT Sphinx_FIND_COMPONENTS)
    # Search at least for `build` executable
    set( Sphinx_FIND_COMPONENTS "build")
elseif(NOT "build" IN_LIST Sphinx_FIND_COMPONENTS)
    list(INSERT Sphinx_FIND_COMPONENTS 0 "build")
endif()

#
# Find all requested components of Sphinx...
#
set(_Sphinx_exe_list "build" "quickstart" "apidoc" "autogen" )
foreach(_comp IN LISTS Sphinx_FIND_COMPONENTS)
    if(_comp STREQUAL "build")
        _Sphinx_find_build()
    elseif(_comp STREQUAL "breathe")
        _Sphinx_find_breathe()
    elseif(_comp  IN_LIST _Sphinx_exe_list)
        _Sphinx_find_exe(${_comp})
    else()
        message(WARNING "${_comp} is not a valid Sphinx component")
        set(Sphinx_${_comp}_FOUND FALSE)
        continue()
    endif()

    if(TARGET Sphinx::${_comp})
        set(Sphinx_${_comp}_FOUND TRUE)
    else()
        set(Sphinx_${_comp}_FOUND FALSE)
    endif()
endforeach()
unset(_comp)


# Verify find results
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(
    Sphinx
    REQUIRED_VARS SPHINX_EXECUTABLE
    VERSION_VAR SPHINX_VERSION
    HANDLE_COMPONENTS
)

#
# Sphinx_configure function.
#
function(sphinx_configure targetName)
    set(_options ALL QUIET)
    set(_one_value_args WORKING_DIRECTORY COMMENT)
    set(_multi_value_args)
    cmake_parse_arguments(_args
                          "${_options}"
                          "${_one_value_args}"
                          "${_multi_value_args}"
                          ${ARGN})

    if(NOT _args_COMMENT)
        set(_args_COMMENT "Generate API documentation for ${targetName}")
    endif()

    if(NOT _args_WORKING_DIRECTORY)
        set(_args_WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}")
    endif()

    if(NOT TARGET Sphinx::quickstart)
        message(FATAL_ERROR "Sphinx::quickstart was not found, needed by sphinx_configure for target ${targetName}")
    endif()

    # If not already defined, set some relevant defaults based on the
    # assumption that the documentation is for the whole project. Details
    # specified in the project() command will be used to populate a number of
    # these defaults.

    if(NOT DEFINED SPHINX_PROJECT_NAME)
        # The PROJECT_NAME tag is a single word (or a sequence of words
        # surrounded by double-quotes, unless you are using Doxywizard) that
        # should identify the project for which the documentation is generated.
        # This name is used in the title of most generated pages and in a few
        # other places.
        set(SPHINX_PROJECT_NAME ${PROJECT_NAME})
    endif()

    if(NOT DEFINED SPHINX_AUTHOR)
        # The Author is the author of the documentation.
        if(WINDOWS)
          set(SPHINX_AUTHOR $ENV{USER})
        else()
          set(SPHINX_AUTHOR $ENV{USERNAME})
        endif()
    endif()


    if(NOT DEFINED SPHINX_VERSION)
        # The PROJECT_VERSION tag can be used to enter a project or revision
        # number. This could be handy for archiving the generated documentation
        # or if some version control system is used.
        set(SPHINX_VERSION ${PROJECT_VERSION})
    endif()

    if(NOT DEFINED SPHINX_RELEASE)
        # The PROJECT_VERSION tag can be used to enter a project or revision
        # number. This could be handy for archiving the generated documentation
        # or if some version control system is used.
        set(SPHINX_RELEASE ${PROJECT_VERSION})
    endif()

    # NOTE: 
    #   SPHINX_EXTENSIONS used here.
    #   SPHINX_TEMPLATEDIR used here.
    #   SPHINX_TEMPLATE_VARIABLES used here - prefix each one with -d NAME=VALUE TODO?

    # Note creating makefile or batchfile.

    if(NOT DEFINED SPHINX_OUTPUT_DIRECTORY)
        # The OUTPUT_DIRECTORY tag is used to specify the (relative or
        # absolute) path into which the generated documentation will be
        # written. If a relative path is used, Sphinx will interpret it as
        # being relative to the location where Sphinx was started, but we need
        # to run Sphinx in the source tree so that relative input paths work
        # intuitively. Therefore, we ensure that the output directory is always
        # an absolute path and if the project provided a relative path, we
        # treat it as relative to the current BINARY directory so that output
        # is not generated inside the source tree.
        set(SPHINX_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}")
    elseif(NOT IS_ABSOLUTE "${SPHINX_OUTPUT_DIRECTORY}")
        get_filename_component(SPHINX_OUTPUT_DIRECTORY
                               "${SPHINX_OUTPUT_DIRECTORY}"
                               ABSOLUTE
                               BASE_DIR "${CMAKE_CURRENT_BINARY_DIR}")
    endif()


    # Any files from the INPUT that match any of the EXCLUDE_PATTERNS will be
    # excluded from the set of input files. We provide some additional patterns
    # to prevent commonly unwanted things from CMake builds being pulled in.
    #
    # Note that the wildcards are matched against the file with absolute path,
    # so to exclude all test directories for example use the pattern */test/*
    list(
        APPEND
        SPHINX_EXCLUDE_PATTERNS
        "*/.git/*"
        "*/.svn/*"
        "*/.hg/*"
        "*/CMakeFiles/*"
        "*/_CPack_Packages/*"
        "DartConfiguration.tcl"
        "CMakeLists.txt"
        "CMakeCache.txt"
    )
endfunction()

#
# Sphinx_add_docs function.
#
function(sphinx_add_docs targetName)
    set(_options ALL)
    set(_one_value_args WORKING_DIRECTORY COMMENT)
    set(_multi_value_args)
    cmake_parse_arguments(_args
                          "${_options}"
                          "${_one_value_args}"
                          "${_multi_value_args}"
                          ${ARGN})

    if(NOT _args_COMMENT)
        set(_args_COMMENT "Generate Sphinx documentation for ${targetName}")
    endif()

    if(NOT _args_WORKING_DIRECTORY)
        set(_args_WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}")
    endif()

    if(DEFINED SPHINX_INPUT)
        message(WARNING "SPHINX_INPUT is set but it will be ignored. Pass the files and directories directly to the sphinx_add_docs() command instead.")
    endif()
    set(SPHINX_INPUT ${_args_UNPARSED_ARGUMENTS})

    if(NOT TARGET Sphinx::build)
        message(FATAL_ERROR "Sphinx::build was not found, needed by sphinx_add_docs() for target ${targetName}")
    endif()

    # If not already defined, set some relevant defaults based on the
    # assumption that the documentation is for the whole project. Details
    # specified in the project() command will be used to populate a number of
    # these defaults.

    if(NOT DEFINED SPHINX_PROJECT_NAME)
        # The PROJECT_NAME tag is a single word (or a sequence of words
        # surrounded by double-quotes, unless you are using Doxywizard) that
        # should identify the project for which the documentation is generated.
        # This name is used in the title of most generated pages and in a few
        # other places.
        set(SPHINX_PROJECT_NAME ${PROJECT_NAME})
    endif()

    if(NOT DEFINED SPHINX_AUTHOR)
        # The Author is the author of the documentation.
        if(WINDOWS)
          set(SPHINX_AUTHOR $ENV{USER})
        else()
          set(SPHINX_AUTHOR $ENV{USERNAME})
        endif()
    endif()


    if(NOT DEFINED SPHINX_VERSION)
        # The PROJECT_VERSION tag can be used to enter a project or revision
        # number. This could be handy for archiving the generated documentation
        # or if some version control system is used.
        set(SPHINX_VERSION ${PROJECT_VERSION})
    endif()

    if(NOT DEFINED SPHINX_RELEASE)
        # The PROJECT_VERSION tag can be used to enter a project or revision
        # number. This could be handy for archiving the generated documentation
        # or if some version control system is used.
        set(SPHINX_RELEASE ${PROJECT_VERSION})
    endif()

    # NOTE: 
    #   SPHINX_EXTENSIONS used here.
    #   SPHINX_TEMPLATEDIR used here.
    #   SPHINX_TEMPLATE_VARIABLES used here - prefix each one with -d NAME=VALUE TODO?

    if(NOT DEFINED SPHINX_OUTPUT_DIRECTORY)
        # The OUTPUT_DIRECTORY tag is used to specify the (relative or
        # absolute) path into which the generated documentation will be
        # written. If a relative path is used, Sphinx will interpret it as
        # being relative to the location where Sphinx was started, but we need
        # to run Sphinx in the source tree so that relative input paths work
        # intuitively. Therefore, we ensure that the output directory is always
        # an absolute path and if the project provided a relative path, we
        # treat it as relative to the current BINARY directory so that output
        # is not generated inside the source tree.
        set(SPHINX_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}")
    elseif(NOT IS_ABSOLUTE "${SPHINX_OUTPUT_DIRECTORY}")
        get_filename_component(SPHINX_OUTPUT_DIRECTORY
                               "${SPHINX_OUTPUT_DIRECTORY}"
                               ABSOLUTE
                               BASE_DIR "${CMAKE_CURRENT_BINARY_DIR}")
    endif()


    # Any files from the INPUT that match any of the EXCLUDE_PATTERNS will be
    # excluded from the set of input files. We provide some additional patterns
    # to prevent commonly unwanted things from CMake builds being pulled in.
    #
    # Note that the wildcards are matched against the file with absolute path,
    # so to exclude all test directories for example use the pattern */test/*
    list(
        APPEND
        DOXYGEN_EXCLUDE_PATTERNS
        "*/.git/*"
        "*/.svn/*"
        "*/.hg/*"
        "*/CMakeFiles/*"
        "*/_CPack_Packages/*"
        "DartConfiguration.tcl"
        "CMakeLists.txt"
        "CMakeCache.txt"
    )

    # Now bring in Doxgen's defaults for those things the project has not
    # already set and we have not provided above
    include("${CMAKE_BINARY_DIR}/CMakeDoxygenDefaults.cmake" OPTIONAL)

    # Cleanup built HTMLs on "make clean"
    # TODO Any other dirs?
    if(DOXYGEN_GENERATE_HTML)
        if(IS_ABSOLUTE "${DOXYGEN_HTML_OUTPUT}")
            set(_args_clean_html_dir "${DOXYGEN_HTML_OUTPUT}")
        else()
            set(_args_clean_html_dir
                "${DOXYGEN_OUTPUT_DIRECTORY}/${DOXYGEN_HTML_OUTPUT}")
        endif()
        set_property(DIRECTORY APPEND PROPERTY
            ADDITIONAL_CLEAN_FILES "${_args_clean_html_dir}")
    endif()

    # Build up a list of files we can identify from the inputs so we can list
    # them as SOURCES in the custom target (makes them display in IDEs). We
    # must do this before we transform the various DOXYGEN_... variables below
    # because we need to process SPHINX_INPUT as a list first.
    unset(_sources)
    foreach(_item IN LISTS SPHINX_INPUT)
        get_filename_component(_abs_item "${_item}" ABSOLUTE
                               BASE_DIR "${_args_WORKING_DIRECTORY}")
        if(EXISTS "${_abs_item}" AND
           NOT IS_DIRECTORY "${_abs_item}" AND
           NOT IS_SYMLINK "${_abs_item}")
            list(APPEND _sources "${_abs_item}")
        endif()
    endforeach()
    if(_sources)
        list(INSERT _sources 0 SOURCES)
    endif()

    # Transform known list type options into space separated strings.
    set(_doxygen_list_options
        ABBREVIATE_BRIEF
        ALIASES
        CITE_BIB_FILES
        DIAFILE_DIRS
        DOTFILE_DIRS
        DOT_FONTPATH
        ENABLED_SECTIONS
        EXAMPLE_PATH
        EXAMPLE_PATTERNS
        EXCLUDE
        EXCLUDE_PATTERNS
        EXCLUDE_SYMBOLS
        EXPAND_AS_DEFINED
        EXTENSION_MAPPING
        EXTRA_PACKAGES
        EXTRA_SEARCH_MAPPINGS
        FILE_PATTERNS
        FILTER_PATTERNS
        FILTER_SOURCE_PATTERNS
        HTML_EXTRA_FILES
        HTML_EXTRA_STYLESHEET
        IGNORE_PREFIX
        IMAGE_PATH
        INCLUDE_FILE_PATTERNS
        INCLUDE_PATH
        INPUT
        LATEX_EXTRA_FILES
        LATEX_EXTRA_STYLESHEET
        MATHJAX_EXTENSIONS
        MSCFILE_DIRS
        PLANTUML_INCLUDE_PATH
        PREDEFINED
        QHP_CUST_FILTER_ATTRS
        QHP_SECT_FILTER_ATTRS
        STRIP_FROM_INC_PATH
        STRIP_FROM_PATH
        TAGFILES
        TCL_SUBST
    )
    foreach(_item IN LISTS _doxygen_list_options)
        doxygen_list_to_quoted_strings(DOXYGEN_${_item})
    endforeach()

    # Transform known single value variables which may contain spaces, such as
    # paths or description strings.
    set(_doxygen_quoted_options
        CHM_FILE
        DIA_PATH
        DOCBOOK_OUTPUT
        DOCSET_FEEDNAME
        DOCSET_PUBLISHER_NAME
        DOT_FONTNAME
        DOT_PATH
        EXTERNAL_SEARCH_ID
        FILE_VERSION_FILTER
        GENERATE_TAGFILE
        HHC_LOCATION
        HTML_FOOTER
        HTML_HEADER
        HTML_OUTPUT
        HTML_STYLESHEET
        INPUT_FILTER
        LATEX_FOOTER
        LATEX_HEADER
        LATEX_OUTPUT
        LAYOUT_FILE
        MAN_OUTPUT
        MAN_SUBDIR
        MATHJAX_CODEFILE
        MSCGEN_PATH
        OUTPUT_DIRECTORY
        PERL_PATH
        PLANTUML_JAR_PATH
        PROJECT_BRIEF
        PROJECT_LOGO
        PROJECT_NAME
        QCH_FILE
        QHG_LOCATION
        QHP_CUST_FILTER_NAME
        QHP_VIRTUAL_FOLDER
        RTF_EXTENSIONS_FILE
        RTF_OUTPUT
        RTF_STYLESHEET_FILE
        SEARCHDATA_FILE
        USE_MDFILE_AS_MAINPAGE
        WARN_FORMAT
        WARN_LOGFILE
        XML_OUTPUT
    )

    # Store the unmodified value of DOXYGEN_OUTPUT_DIRECTORY prior to invoking
    # doxygen_quote_value() below. This will mutate the string specifically for
    # consumption by Doxygen's config file, which we do not want when we use it
    # later in the custom target's commands.
    set( _original_doxygen_output_dir ${DOXYGEN_OUTPUT_DIRECTORY} )

    foreach(_item IN LISTS _doxygen_quoted_options)
        doxygen_quote_value(DOXYGEN_${_item})
    endforeach()

    # Prepare doxygen configuration file
    set(_doxyfile_template "${CMAKE_BINARY_DIR}/CMakeDoxyfile.in")
    set(_target_doxyfile "${CMAKE_CURRENT_BINARY_DIR}/Doxyfile.${targetName}")
    configure_file("${_doxyfile_template}" "${_target_doxyfile}")

    unset(_all)
    if(${_args_ALL})
        set(_all ALL)
    endif()

    # Add the target
    add_custom_target( ${targetName} ${_all} VERBATIM
        COMMAND ${CMAKE_COMMAND} -E make_directory ${_original_doxygen_output_dir}
        COMMAND "${DOXYGEN_EXECUTABLE}" "${_target_doxyfile}"
        WORKING_DIRECTORY "${_args_WORKING_DIRECTORY}"
        DEPENDS "${_target_doxyfile}"
        COMMENT "${_args_COMMENT}"
        ${_sources}
    )

endfunction()      
if( NOT DEFINED SPHINX_THEME)
  set(SPHINX_THEME default)
endif()

if( NOT DEFINED SPHINX_THEME_DIR )
  set(SPHINX_THEME_DIR)
endif()

set( SPHINX_BUILD_DIR ${CMAKE_CURRENT_BINARY_DIR}/sphinx_build )
set( SPHINX_CACHE_DIR ${CMAKE_CURRENT_BINARY_DIR}/sphinx_cache )
set

#    # Cleanup built HTMLs on "make clean"
#    # TODO Any other dirs?
#    if(SPHINX_GENERATE_HTML)
#        if(IS_ABSOLUTE "${SPHINX_HTML_OUTPUT}")
#            set(_args_clean_html_dir "${SPHINX_HTML_OUTPUT}")
#        else()
#            set(_args_clean_html_dir
#                "${SPHINX_OUTPUT_DIRECTORY}/${SPHINX_HTML_OUTPUT}")
#        endif()
#        set_property(DIRECTORY APPEND PROPERTY
#            ADDITIONAL_CLEAN_FILES "${_args_clean_html_dir}")
#    endif()

    # Build up a list of files we can identify from the inputs so we can list
    # them as SOURCES in the custom target (makes them display in IDEs). We
    # must do this before we transform the various SPHINX_... variables below
    # because we need to process DOXYGEN_INPUT as a list first.
    unset(_sources)
#    foreach(_item IN LISTS DOXYGEN_INPUT)
#        get_filename_component(_abs_item "${_item}" ABSOLUTE
#                               BASE_DIR "${_args_WORKING_DIRECTORY}")
#        if(EXISTS "${_abs_item}" AND
#           NOT IS_DIRECTORY "${_abs_item}" AND
#           NOT IS_SYMLINK "${_abs_item}")
#            list(APPEND _sources "${_abs_item}")
#        endif()
#    endforeach()
#    if(_sources)
#        list(INSERT _sources 0 SOURCES)
#    endif()
#
#    # Prepare doxygen configuration file
#    set(_doxyfile_template "${CMAKE_BINARY_DIR}/CMakeDoxyfile.in")
#    set(_target_doxyfile "${CMAKE_CURRENT_BINARY_DIR}/Doxyfile.${targetName}")
#    configure_file("${_doxyfile_template}" "${_target_doxyfile}")
#
#    unset(_all)
#    if(${_args_ALL})
#        set(_all ALL)
#    endif()
#
#    # Add the target
#    add_custom_target( ${targetName} ${_all} VERBATIM
#        COMMAND ${CMAKE_COMMAND} -E make_directory ${_original_doxygen_output_dir}
#        COMMAND "${DOXYGEN_EXECUTABLE}" "${_target_doxyfile}"
#        WORKING_DIRECTORY "${_args_WORKING_DIRECTORY}"
#        DEPENDS "${_target_doxyfile}"
#        COMMENT "${_args_COMMENT}"
#        ${_sources}
#    )

endfunction()
