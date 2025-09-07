# Docker file for installation.

# Copyright (c) 2022-2024 Retlek Systems Inc.

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

# hadolint ignore=DL3029
FROM --platform=$BUILDPLATFORM ghcr.io/retlek-systems-inc/rs_cmake/sw-dev:latest

LABEL org.opencontainers.image.description="RS CMake Software Arm None EABI Dev"

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

# arm-none-eabi from https://developer.arm.com/downloads/-/arm-gnu-toolchain-downloads
ARG ARM_VER="14.3.rel1"
ARG ARM_TRIPLET="arm-none-eabi"
ARG ARM_NAME="arm-gnu-toolchain-${ARM_VER}-x86_64-${ARM_TRIPLET}"
ENV PATH="$PATH:/usr/local/${ARM_NAME}/bin"
RUN wget --progress=dot:giga "https://developer.arm.com/-/media/Files/downloads/gnu/${ARM_VER}/binrel/${ARM_NAME}.tar.xz" \
    && wget --progress=dot:giga "https://developer.arm.com/-/media/Files/downloads/gnu/${ARM_VER}/binrel/${ARM_NAME}.tar.xz.asc" \
    && md5sum --check ${ARM_NAME}.tar.xz.asc \
    && mkdir -p /usr/local \
    && tar -xJf ${ARM_NAME}.tar.xz -C /usr/local \
    && rm -f ${ARM_NAME}.tar.xz*

ENV WORK_PATH=/tmp
ENV PATH="$PATH:/usr/local/${ARM_NAME}"
ENV CMAKE_ENV_DEPS_PATH=${WORK_PATH}/cmake_env_deps
ENV CMAKE_ENV_BASE_PATH=${WORK_PATH}/base

WORKDIR ${WORK_PATH}
