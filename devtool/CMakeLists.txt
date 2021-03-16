#######################################################################
# @copyright 2020 Retlek Systems Inc.
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
# Development Tools Requirements

cmake_minimum_required( VERSION 3.19)

option(DOC_TOOLS "Install Documentation tools" OFF)
option(LLVM_TOOLS "Install native LLVM compiler" ON)
option(GNU_TOOLS "Install native GNU compiler" ON)
option(SA_TOOLS  "Install Static Analysis tools" ON)
option(ARM_CROSS_TOOLS "Install ARM processor cross compiler tools" OFF)
option(VERILOG_TOOLS   "Install Verilog Simulation tools" OFF)

set(LLVM_TOOL_VERSION 10)
set(GNU_TOOL_VERSION 10)

set(helpMsg "
Development Tool Dependencies

This is the standard list of development tools required for install for Linux machines.
This creates a deb or rpm install for development execution in your repo.

")

message( STATUS helpMsg )

if(CMAKE_HOST_SYSTEM_NAME STREQUAL Linux)
    find_program(LSB_RELEASE_EXEC lsb_release)
    execute_process(COMMAND ${LSB_RELEASE_EXEC} -is
        OUTPUT_VARIABLE LSB_RELEASE_ID_SHORT
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    if(LSB_RELEASE_ID_SHORT STREQUAL Ubuntu)
        set(CPACK_GENERATOR "DEB")
    elseif(LSBRELEASE_ID_SHORT STREQUAL RHEL)
        set(CPACK_GENERATOR "RPM")
    else()
        message(FATAL_ERROR "No support for unknown Release ${LSBRELEASE_ID_SHORT}")
    endif()
else()
    message(FATAL_ERROR "Currently not supported on ${CMAKE_HOST_SYSTEM_NAME}")
endif()


###############################################################################
# Base information
set(CPACK_PACKAGE_NAME "devtools_${CMAKE_PROJECT_NAME}")
set(CPACK_PACKAGE_VENDOR "Retlek Systems Inc.")
set(CPACK_PACKAGE_CONTACT "paulheltera@gmail.com")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "Linux Development Environment Packages")

set(CPACK_PACKAGE_VERSION_MAJOR ${PROJECT_VERSION_MAJOR})
set(CPACK_PACKAGE_VERSION_MINOR ${PROJECT_VERSION_MINOR})
set(CPACK_PACKAGE_VERSION_PATCH ${PROJECT_VERSION_PATCH})
set(CPACK_VERBATIM_VARIABLES YES)
# set(CPACK_PACKAGE_DESCRIPTION_FILE ${CMAKE_CURRENT_LIST_DIR}/Description.txt)
# set(CPACK_RESOURCE_FILE_WELCOME ${CMAKE_CURRENT_LIST_DIR}/Welcome.txt)
# set(CPACK_RESOURCE_FILE_LICENSE ${CMAKE_CURRENT_LIST_DIR}/License.txt)
set(CPACK_RESOURCE_FILE_README ${CMAKE_CURRENT_BINARY_DIR}/Readme.txt)
# Note content of readme is based on type.

###############################################################################
# List of package information.
list(APPEND _package_list
    software-properties-common 
    ninja-build 
    ccache
    clang-format-${LLVM_TOOL_VERSION}
)

if(GNU_TOOLS)
    list(APPEND _package_list
        gcc-${GNU_TOOL_VERSION}
        g++-${GNU_TOOL_VERSION}
    )
endif(GNU_TOOLS)

if(LLVM_TOOLS)
    list(APPEND _package_list
        clang-${LLVM_TOOL_VERSION}
        clang++-${LLVM_TOOL_VERSION}
    )
endif(LLVM_TOOLS)

if(DOC_TOOLS)
    list(APPEND _package_list
        doxygen
        graphviz
        default-jdk
        python3-sphinx
        python3-pip
    )
endif(DOC_TOOLS)

if(SA_TOOLS)
    list(APPEND _package_list
        clang-tidy-${LLVM_TOOL_VERSION}
        lcov
    )
endif(SA_TOOLS)

if(ARM_CROSS_TOOLS)
    # TODO: May need to get latest gcc from here:
    # https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/gnu-rm/downloads    
    list(APPEND _package_list
        gcc-arm-embedded
        srecord
    )

endif(ARM_CROSS_TOOLS)

if(VERILOG_TOOLS)
    list(APPEND _package_list
        verilator
    )
endif(VERILOG_TOOLS)

###############################################################################
if (CPACK_GENERATOR STREQUAL "DEB")
    # CPACK_DEBIAN_PACKAGE_NAME derived from CPACK_PACKAGE_NAME
    # CPACK_DEBIAN_PACKAGE_VERSION derived from CPACK_PACKAGE_VERSION
    set(CPACK_DEBIAN_PACKAGE_ARCHITECTURE "amd64")
    # CPACK_DEBIAN_PACKAGE_MAINTAINER derived from CPACK_PACKAGE_CONTACT
    # CPACK_DEBIAN_PACKAGE_DESCRIPTION derived from CPACK_PACKAGE_DESCRIPTION 
    set(CPACK_DEBIAN_PACKAGE_SECTION "devel")
    set(CPACK_DEBIAN_COMPRESSION_TYPE "gzip")
    set(CPACK_DEBIAN_PACKAGE_PRIORITY "optional")

    #set(CPACK_DEBIAN_PACKAGE_DEPENDS "$<GENEX_EVAL:$<JOIN:${_package_list}, $<COMMA>>>")
    list(TRANSFORM _package_list GENEX_STRIP )
    list(JOIN _package_list ", " CPACK_DEBIAN_PACKAGE_DEPENDS)

    set(debInfo "
Install latest CMake:
    # For Ubuntu Bionic Beaver (18.04):
    sudo apt-add-repository 'deb https://apt.kitware.com/ubuntu/ bionic main'
    sudo apt-get update
    sudo apt-get install kitware-archive-keyring
    sudo apt-key --keyring /etc/apt/trusted.gpg del C1F34CDD40CD72DA

Prepare for install:
    # GCC Arm Embedded processor repository location (added before first update).
    add-apt-repository -y ppa:team-gcc-arm-embedded/ppa
    apt-get update -y

    sudo dpkg -i ${CPACK_DEBIAN_FILE_NAME}
    sudo apt-get -f -y install
")
    file(WRITE ${CPACK_RESOURCE_FILE_README} "${helpMsg} ${debInfo}")


elseif(CPACK_GENERATOR STREQUAL "RPM")
    message(AUTHOR_WARNING "Need to implement. Deal with later.")
endif()

include(CPack)
