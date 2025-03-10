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
FROM --platform=$BUILDPLATFORM ubuntu:24.04

LABEL org.opencontainers.image.description="RS CMake Software Dev"

# ---------------------------------------------------------
# Latest cmake - setup keyring
# See: https://apt.kitware.com/

# hadolint ignore=DL3008
RUN apt-get update -y \
    && DEBIAN_FRONTEND=noninteractive \
    apt-get install --no-install-recommends -y \
    ca-certificates \
    gpg \
    wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# hadolint ignore=DL3008,DL4006
RUN test -f /usr/share/doc/kitware-archive-keyring/copyright \
    || wget -q -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | tee /usr/share/keyrings/kitware-archive-keyring.gpg >/dev/null \
    && echo 'deb [signed-by=/usr/share/keyrings/kitware-archive-keyring.gpg] https://apt.kitware.com/ubuntu/ jammy main' | tee /etc/apt/sources.list.d/kitware.list >/dev/null \
    && apt-get update -y \
    && test -f /usr/share/doc/kitware-archive-keyring/copyright \
    || rm /usr/share/keyrings/kitware-archive-keyring.gpg \
    && apt-get install --no-install-recommends -y \
    kitware-archive-keyring \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# ---------------------------------------------------------
# Default GCC, latest cmake and ninja-build

# hadolint ignore=DL3008
RUN apt-get update -y \
    && DEBIAN_FRONTEND=noninteractive \
    apt-get install --no-install-recommends -y \
    software-properties-common \
    wget \
    openssh-client \
    gcc-14 \
    g++-14 \
    gpg \
    git \
    cmake \
    ninja-build \
    ccache \
    lcov \
    libjson-xs-perl \
    cppcheck \
    cpplint \
    iwyu \
    build-essential \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# ---------------------------------------------------------
# Latest Clang and LLVM
# See: https://apt.llvm.org

# hadolint ignore=DL3008
RUN wget -q https://apt.llvm.org/llvm.sh \
    && chmod +x llvm.sh \
    && ./llvm.sh 19 all

# ---------------------------------------------------------

ENV WORK_PATH=/tmp
ENV CMAKE_ENV_DEPS_PATH=${WORK_PATH}/cmake_env_deps
ENV CMAKE_ENV_BASE_PATH=${WORK_PATH}/base

WORKDIR ${WORK_PATH}
