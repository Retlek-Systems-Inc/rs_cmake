# Docker file for installation.

# Copyright (c) 2022 Retlek Systems Inc.

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

# hadolint ignore=DL3007,DL3029
FROM --platform=$BUILDPLATFORM ghcr.io/retlek-systems-inc/rs_cmake/sw-dev:latest

LABEL org.opencontainers.image.description="RS CMake Hardware Frontend Dev"

# Default gtkwave and verilator
# hadolint ignore=DL3008
RUN apt-get update -y \
    && DEBIAN_FRONTEND=noninteractive \
    apt-get install --no-install-recommends -y \
    gtkwave \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Instead of installing default
#    verilator=4.038-1 \

# Install Verilator
# modified from: https://github.com/verilator/verilator/blob/master/ci/docker/run/Dockerfile
# Also used: https://verilator.org/guide/latest/install.html#git-quick-install

# hadolint ignore=DL3008
RUN apt-get update -y \
    && DEBIAN_FRONTEND=noninteractive \
    apt-get install --no-install-recommends -y \
    autoconf \
    bc \
    bison \
    flex \
    help2man \
    libfl2 \
    libfl-dev \
    libgoogle-perftools-dev \
    libunwind-dev \
    numactl \
    perl \
    perl-doc \
    python3 \
    zlib1g \
    zlib1g-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*


# Using version v5.006
ARG VERILATOR_REPO=https://github.com/verilator/verilator
ARG VERILATOR_COMMIT=v5.040

ARG SLANG_REPO=https://github.com/MikePopoloski/slang.git
ARG SLANG_COMMIT=v9.0

ARG VERIBLE_URL=https://github.com/chipsalliance/verible/releases/download
ARG VERIBLE_VERSION=v0.0-4023-gc1271a00
ARG VERIBLE_FILE=verible-${VERIBLE_VERSION}-linux-static-x86_64.tar.gz
ARG VERIBLE_RELEASE=${VERIBLE_URL}/${VERIBLE_VERSION}/${VERIBLE_FILE}


ENV WORK_PATH=/tmp
ENV CMAKE_ENV_DEPS_PATH=${WORK_PATH}/cmake_env_deps
ENV CMAKE_ENV_BASE_PATH=${WORK_PATH}/base
ARG CMAKE_ENV_VERILATOR_PATH=${WORK_PATH}/verilator

ARG CMAKE_ENV_SLANG_PATH=${WORK_PATH}/slang


WORKDIR ${WORK_PATH}

# Add an exception for the linter, we want to cd here in one layer
# to reduce the number of layers (and thereby size).
# hadolint ignore=DL3003
RUN git clone "${VERILATOR_REPO}" ${CMAKE_ENV_VERILATOR_PATH} \
    && cd ${CMAKE_ENV_VERILATOR_PATH} \
    && git checkout "${VERILATOR_COMMIT}" \
    && autoconf \
    && ./configure \
    && make -j "$(nproc)" \
    && make install \
    && cd ${WORK_PATH} \
    && chmod a+rx /usr/local/bin \
    && rm -r ${CMAKE_ENV_VERILATOR_PATH}


# Add an exception for the linter, we want to cd here in one layer
# to reduce the number of layers (and thereby size).
# hadolint ignore=DL3003
RUN git clone "${SLANG_REPO}" ${CMAKE_ENV_SLANG_PATH} \
    && cd ${CMAKE_ENV_SLANG_PATH} \
    && git checkout "${SLANG_COMMIT}" \
    && cmake -G Ninja -B build -DCMAKE_BUILD_TYPE=Release . \
    && cmake --build build \
    && cmake --install build --strip \
    && rm -r ${CMAKE_ENV_SLANG_PATH}

# Install verible.
RUN wget --progress=dot:giga ${VERIBLE_URL}/${VERIBLE_VERSION}/${VERIBLE_FILE} \
    && tar -xzf ${VERIBLE_FILE} -C /usr/local --strip-components=1 \
    && rm -f ${VERIBLE_FILE}
