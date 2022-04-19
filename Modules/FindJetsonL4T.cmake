# @copyright 2022 Retlek Systems Inc.
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
FindJetsonL4T
-----------

Find the Jetson L4T Multimedia library.

This module finds an installed Jetson L4T Multimedia library

Optional COMPONENTS
^^^^^^^^^^^^^^^^^^^

This module supports optional COMPONENTS: ``BufUtils``, ``Jpeg``, and ``Osd``. Each component
has associated imported targets, as described below.

Imported Targets
^^^^^^^^^^^^^^^^

This module defines the following :prop_tgt:`IMPORTED` targets:

``JetsonL4T::BufUtils``
  The Jetson ``nvbuf_utils`` library, if found.
``JetsonL4T::Jpeg``
  The Jetson ``nvjpeg`` library, if found.
``JetsonL4T::Osd``
  The Jetson ``nvosd`` library, if found.

Result Variables
^^^^^^^^^^^^^^^^

This module will set the following variables in your project:

``JETSONL4T_FOUND``
  System has the Jetson library.
# ``JETSONL4T_INCLUDE_DIR``
#   The Jetson include directory.
``JETSONL4T_BUFUTILS_LIBRARY``
  The Jetson buf utils library.
``JETSONL4T_BUFUTILS_LIBRARIES``
  The Jetson buf utils library and its dependencies.
``JETSONL4T_JPEG_LIBRARY``
  The Jetson JPEG library.
``JETSONL4T_JPEG_LIBRARIES``
  The Jetson JPEG library and its dependencies.
``JETSONL4T_OSD_LIBRARY``
  The Jetson OSD library.
``JETSONL4T_OSD_LIBRARIES``
  The Jetson OSD library and its dependencies.
``JETSONL4T_LIBRARIES``
  All Jetson libraries and their dependencies.
# ``JETSON_VERSION``
#   This is set to ``$major.$minor.$revision$patch`` (e.g. ``0.9.8s``).

Hints
^^^^^

Set ``JETSONL4T_ROOT_DIR`` to the root directory of an Jetson installation.

#]=======================================================================]

if (NOT UNIX)
  return()
endif()

#find_package(PkgConfig QUIET)
#pkg_check_modules(_JETSONL4T QUIET nvbuf_utils)

set(_JETSONL4T_ROOT_HINTS
  ${JETSONL4T_ROOT_DIR}
  ENV JETSONL4T_ROOT_DIR
)

set(_JETSONL4T_ROOT_HINTS_AND_PATHS
  HINTS ${_JETSONL4T_ROOT_HINTS}
  PATHS ${_JETSONL4T_ROOT_PATHS}
)

find_library(JETSONL4T_BUFUTILS_LIBRARY
  NAMES
    nvbuf_utils
  NAMES_PER_DIR
    ${_JETSONL4T_ROOT_HINTS_AND_PATHS}
  HINTS
    ${_JETSONL4T_LIBDIR}
    ${_JETSONL4T_LIBRARY_DIRS}
  PATH_SUFFIXES
    lib lib64 tegra
)

find_library(JETSONL4T_JPEG_LIBRARY
  NAMES
    nvjpeg
  NAMES_PER_DIR
    ${_JETSONL4T_ROOT_HINTS_AND_PATHS}
  HINTS
    ${_JETSONL4T_LIBDIR}
    ${_JETSONL4T_LIBRARY_DIRS}
  PATH_SUFFIXES
    lib lib64 tegra
)

find_library(JETSONL4T_OSD_LIBRARY
  NAMES
    nvosd
  NAMES_PER_DIR
    ${_JETSONL4T_ROOT_HINTS_AND_PATHS}
  HINTS
    ${_JETSONL4T_LIBDIR}
    ${_JETSONL4T_LIBRARY_DIRS}
  PATH_SUFFIXES
    lib lib64 tegra
)
mark_as_advanced(JETSONL4T_BUFUTILS_LIBRARY JETSONL4T_JPEG_LIBRARY JETSONL4T_OSD_LIBRARY)


set(JETSONL4T_BUFUTILS_LIBRARIES ${JETSONL4T_BUFUTILS_LIBRARY})
set(JETSONL4T_JPEG_LIBRARIES ${JETSONL4T_JPEG_LIBRARY})
set(JETSONL4T_OSD_LIBRARIES ${JETSONL4T_OSD_LIBRARY})
set(JETSONL4T_LIBRARIES ${JETSONL4T_BUFUTILS_LIBRARIES} ${JETSONL4T_JPEG_LIBRARIES}  ${JETSONL4T_OSD_LIBRARIES} )

foreach(_comp IN LISTS JetsonL4T_FIND_COMPONENTS)
  if(_comp STREQUAL "BufUtils")
    if(EXISTS "${JETSONL4T_BUFUTILS_LIBRARY}" )
      set(JetsonL4T_${_comp}_FOUND TRUE)
    else()
      set(JetsonL4T_${_comp}_FOUND FALSE)
    endif()
  elseif(_comp STREQUAL "Jpeg")
    if(EXISTS "${JETSONL4T_JPEG_LIBRARY}")
      set(JetsonL4T_${_comp}_FOUND TRUE)
    else()
      set(JetsonL4T_${_comp}_FOUND FALSE)
    endif()
  elseif(_comp STREQUAL "Osd")
    if(EXISTS "${JETSONL4T_OSD_LIBRARY}")
      set(JetsonL4T_${_comp}_FOUND TRUE)
    else()
      set(JetsonL4T_${_comp}_FOUND FALSE)
    endif()
  else()
    message(WARNING "${_comp} is not a valid JetsonL4T component")
    set(JetsonL4T_${_comp}_FOUND FALSE)
  endif()
endforeach()
unset(_comp)

find_package(PackageHandleStandardArgs)

find_package_handle_standard_args(JetsonL4T
  REQUIRED_VARS
    JETSONL4T_BUFUTILS_LIBRARY
    #JETSONL4T_INCLUDE_DIR
#  VERSION_VAR
#    JETSONL4T_VERSION
#  HANDLE_VERSION_RANGE
  HANDLE_COMPONENTS
  FAIL_MESSAGE
    "Could NOT find JetsonL4T, try to set the path to Jetson root folder in the system variable JETSONL4T_ROOT_DIR"
)

#mark_as_advanced(JETSONL4T_INCLUDE_DIR)

if(JetsonL4T_FOUND)
  if((NOT TARGET JetsonL4T::BufUtils) AND
      (EXISTS "${JETSONL4T_BUFUTILS_LIBRARY}"))
      add_library(JetsonL4T::BufUtils UNKNOWN IMPORTED)
    # set_target_properties(JetsonL4T::BufUtils PROPERTIES
    #   INTERFACE_INCLUDE_DIRECTORIES "${JETSONL4T_INCLUDE_DIR}")
    set_target_properties(JetsonL4T::BufUtils PROPERTIES
      IMPORTED_LINK_INTERFACE_LANGUAGES "C"
      IMPORTED_LOCATION         "${JETSONL4T_BUFUTILS_LIBRARY}"
      IMPORTED_LOCATION_RELEASE "${JETSONL4T_BUFUTILS_LIBRARY}"
      IMPORTED_LOCATION_DEBUG   "${JETSONL4T_BUFUTILS_LIBRARY}"
    )
  endif()

  if((NOT TARGET JetsonL4T::Jpeg) AND
     (EXISTS "${JETSONL4T_JPEG_LIBRARY}"))
    add_library(JetsonL4T::Jpeg UNKNOWN IMPORTED)
    # set_target_properties(JetsonL4T::Jpeg PROPERTIES
    #   INTERFACE_INCLUDE_DIRECTORIES "${JETSONL4T_INCLUDE_DIR}")
    set_target_properties(JetsonL4T::Jpeg PROPERTIES
      IMPORTED_LINK_INTERFACE_LANGUAGES "C"
      IMPORTED_LOCATION         "${JETSONL4T_JPEG_LIBRARY}"
      IMPORTED_LOCATION_RELEASE "${JETSONL4T_JPEG_LIBRARY}"
      IMPORTED_LOCATION_DEBUG   "${JETSONL4T_JPEG_LIBRARY}"
    )
  endif()

  if((NOT TARGET JetsonL4T::Osd) AND
     (EXISTS "${JETSONL4T_OSD_LIBRARY}"))
    add_library(JetsonL4T::Osd UNKNOWN IMPORTED)
    # set_target_properties(JetsonL4T::Osd PROPERTIES
    #   INTERFACE_INCLUDE_DIRECTORIES "${JETSONL4T_INCLUDE_DIR}")
    set_target_properties(JetsonL4T::Osd PROPERTIES
      IMPORTED_LINK_INTERFACE_LANGUAGES "C"
      IMPORTED_LOCATION         "${JETSONL4T_OSD_LIBRARY}"
      IMPORTED_LOCATION_RELEASE "${JETSONL4T_OSD_LIBRARY}"
      IMPORTED_LOCATION_DEBUG   "${JETSONL4T_OSD_LIBRARY}"
    )
  endif()
endif()
