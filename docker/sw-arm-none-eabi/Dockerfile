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

FROM ubuntu:22.04

# Default latest cmake and ninja-build
# hadolint ignore=DL3008
RUN apt-get update -y \
    && DEBIAN_FRONTEND=noninteractive \
    apt-get install --no-install-recommends -y \
    software-properties-common \
    wget \
    openssh-client \
    gpg \
    git \
    cmake \
    ninja-build \
    ccache \
    xz-utils \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# arm-none-eabi from arm/linaro.
RUN wget --progress=dot:giga https://developer.arm.com/-/media/Files/downloads/gnu/12.2.mpacbti-rel1/binrel/arm-gnu-toolchain-12.2.mpacbti-rel1-x86_64-arm-none-eabi.tar.xz \
    && wget --progress=dot:giga https://developer.arm.com/-/media/Files/downloads/gnu/12.2.mpacbti-rel1/binrel/arm-gnu-toolchain-12.2.mpacbti-rel1-x86_64-arm-none-eabi.tar.xz.asc \
    && md5sum --check arm-gnu-toolchain-12.2.mpacbti-rel1-x86_64-arm-none-eabi.tar.xz.asc \
    && mkdir -p /usr/local \
    && tar -xJf arm-gnu-toolchain-12.2.mpacbti-rel1-x86_64-arm-none-eabi.tar.xz -C /usr/local \
    && rm -f arm-gnu-toolchain-12.2.mpacbti-rel1-aarch64-arm-none-eabi.tar.xz*

ENV WORK_PATH=/tmp
ENV PATH="$PATH:/usr/local/arm-gnu-toolchain-12.2.mpacbti-rel1-x86_64-arm-none-eabi/bin"
ENV CMAKE_ENV_DEPS_PATH=${WORK_PATH}/cmake_env_deps
ENV CMAKE_ENV_BASE_PATH=${WORK_PATH}/base

WORKDIR ${WORK_PATH}

# Now create DEPS directory with pre-downloaded git repos
RUN mkdir -p ${CMAKE_ENV_DEPS_PATH} \
    && mkdir -p ${CMAKE_ENV_BASE_PATH}

COPY base.cmake ${CMAKE_ENV_BASE_PATH}/CMakeLists.txt
COPY arm-none-eabi-gcc.toolchain.cmake ${CMAKE_ENV_BASE_PATH}/arm-none-eabi-gcc.toolchain.cmake

RUN  cmake -G "Ninja Multi-Config" -B${CMAKE_ENV_BASE_PATH}/build --toolchain ${CMAKE_ENV_BASE_PATH}/arm-none-eabi-gcc.toolchain.cmake  -DFETCHCONTENT_BASE_DIR=${CMAKE_ENV_DEPS_PATH} ${CMAKE_ENV_BASE_PATH}
