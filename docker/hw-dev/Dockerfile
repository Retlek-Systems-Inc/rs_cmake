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

# hadolint ignore=DL3007,DL3008
FROM phelter/sw-dev:latest
#FROM registry.gitlab.com/retleksystems/env/cmake/sw-dev:latest

# Default gtkwave and verilator
RUN apt-get update -y \
    && DEBIAN_FRONTEND=noninteractive \
    apt-get install --no-install-recommends -y \
    gtkwave=3.3.104-2build1 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Instead of installing default
#    verilator=4.038-1 \

# Install Verilator
# modified from: https://github.com/verilator/verilator/blob/master/ci/docker/run/Dockerfile
# Also used: https://verilator.org/guide/latest/install.html#git-quick-install

# Note libunwind-14 is installed with llvm-14 tools.  This clashes with libunwind-dev used by
# libgoogle-perftools-dev so removing it for now.  This means cannot use libc++abi* but must use
# gcc version libstdc++abi.
RUN DEBIAN_FRONTEND=noninteractive \
    apt-get -y autoremove --purge libunwind-14

# hadolint ignore=DL3008
RUN apt-get update -y \
    && DEBIAN_FRONTEND=noninteractive \
    apt-get install --no-install-recommends -y \
        autoconf \
        bc \
        bison \
        flex \
        libfl2 \
        libfl-dev \
        zlib1g \
        zlib1g-dev \
        libgoogle-perftools-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*


# Using version 4.222
ARG REPO=https://github.com/verilator/verilator
ARG SOURCE_COMMIT=v4.222

WORKDIR /tmp

# Add an exception for the linter, we want to cd here in one layer
# to reduce the number of layers (and thereby size).
# hadolint ignore=DL3003
RUN git clone "${REPO}" verilator && \
    cd verilator && \
    git checkout "${SOURCE_COMMIT}" && \
    autoconf && \
    ./configure && \
    make -j "$(nproc)" && \
    make install && \
    cd .. && \
    rm -r verilator

# COPY verilator-wrap.sh /usr/local/bin/verilator-wrap.sh

# WORKDIR /work

# ENTRYPOINT [ "/usr/local/bin/verilator-wrap.sh" ]

WORKDIR /tmp
