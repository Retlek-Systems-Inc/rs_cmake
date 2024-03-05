# Docker file for installation.

# Copyright (c) 2024 Retlek Systems Inc.

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# FROM ubuntu:22.04
# hadolint ignore=DL3007
FROM ghcr.io/retlek-systems-inc/rs_cmake/sw-dev:latest

ENV WORK_PATH=/tmp

# Default update to latest.
# hadolint ignore=DL3008
RUN apt-get update -y \
    && DEBIAN_FRONTEND=noninteractive \
    apt-get install --no-install-recommends -y \
    wget \
    gnupg \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR ${WORK_PATH}

# OpenROAD separate from build if want a newer version
ARG OPENROAD_DEB_VERSION=2024-02-05
ARG OPENROAD_DEB_FILE=openroad_2.0_amd64-ubuntu22.04-${OPENROAD_DEB_VERSION}.deb
ARG OPENROAD_DEB_URL=https://github.com/Precision-Innovations/OpenROAD/releases/download/${OPENROAD_DEB_VERSION}/${OPENROAD_DEB_FILE}

ARG ORFS_REPO=https://github.com/The-OpenROAD-Project/OpenROAD-flow-scripts
ARG ORFS_COMMIT=v3.0
ARG ORFS_PATH=${WORK_PATH}/OpenROAD-flow-scripts

ARG KLAYOUT_GPG_PUBKEY_FILE=klayout-public.asc
ARG KLAYOUT_GPG_PUBKEY_URL=https://www.klayout.org/downloads/gpg-public.key

ARG KLAYOUT_DEB_VERSION=0.28.15-1
ARG KLAYOUT_DEB_FILE=klayout_${KLAYOUT_DEB_VERSION}_amd64.deb
ARG KLAYOUT_DEB_URL=https://www.klayout.org/downloads/Ubuntu-22/${KLAYOUT_DEB_FILE}
ARG KLAYOUT_DEB_MD5=8c7d0ebaa96b954a584f752236fc0cd4

ARG YOSYS_TGZ_VERSION=2024-02-07
ARG YOSYS_TGZ_VERSION_NO_DASH=20240207
ARG YOSYS_TGZ_FILE=oss-cad-suite-linux-x64-${YOSYS_TGZ_VERSION_NO_DASH}.tgz
ARG YOSYS_TGZ_URL=https://github.com/YosysHQ/oss-cad-suite-build/releases/download/${YOSYS_TGZ_VERSION}/${YOSYS_TGZ_FILE}
ARG YOSYS_INSTALL_DIR=/usr/local

# Install klayout
RUN wget --progress=dot:giga ${KLAYOUT_GPG_PUBKEY_URL} -O ./${KLAYOUT_GPG_PUBKEY_FILE} \
    && wget --progress=dot:giga ${KLAYOUT_DEB_URL} \
    && echo "${KLAYOUT_DEB_MD5} ./${KLAYOUT_DEB_FILE}" > ./${KLAYOUT_DEB_FILE}.md5 \
    && md5sum -c ${KLAYOUT_DEB_FILE}.md5 \
    && apt-key add ${KLAYOUT_GPG_PUBKEY_FILE}

RUN apt-get update -y \
    && DEBIAN_FRONTEND=noninteractive apt-get upgrade -y  \
    && dpkg --configure -a \
    && apt-get autoremove \
    && apt-get --fix-broken install \
    && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y ./${KLAYOUT_DEB_FILE} \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* ./${KLAYOUT_GPG_PUBKEY_FILE} ./${KLAYOUT_DEB_FILE}

# If KLayout is built from source
# ENV LD_LIBRARY_PATH="<klayout_location>/bin:$PATH"

# Install yosys
RUN wget --progress=dot:giga ${YOSYS_TGZ_URL} \
    && tar -xzvf ./${YOSYS_TGZ_FILE} -C ${YOSYS_INSTALL_DIR} \
    && rm -rf ./${YOSYS_TGZ_FILE}

ENV PATH="${YOSYS_INSTALL_DIR}/oss-cad-suite/bin:${PATH}"

# Install OpenROAD toolchain
RUN wget --progress=dot:giga ${OPENROAD_DEB_URL}

#Note: `time` is for the OpenROAD flow scripts - used in make files.

# hadolint ignore=DL3008
RUN add-apt-repository universe \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive \
    apt-get install --no-install-recommends -y \
    tcl-tclreadline \
    libtcl8.6 \
    time \
    && DEBIAN_FRONTEND=noninteractive  \
    apt-get install --no-install-recommends -y ./${OPENROAD_DEB_FILE} \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* ${OPENROAD_DEB_FILE}

# Set environment variables based on above installation
ENV YOSYS_CMD=${YOSYS_INSTALL_DIR}/oss-cad-suite/bin/yosys
ENV OPENROAD_EXE=/usr/bin/openroad

# TODO(phelter): Debug later - bug in final_report.tcl
# Install OpenROAD flow scripts
# hadolint ignore=DL3003
# RUN git clone "${ORFS_REPO}" ${ORFS_PATH} \
#     && yosys -help \
#     && openroad -help \
#     && cd ${ORFS_PATH}/flow \
#     && make
