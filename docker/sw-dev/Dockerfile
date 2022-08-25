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

# Default GCC, latest cmake and ninja-build, clang (14)
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
    lcov \
    cppcheck \
    cpplint \
    iwyu \
    build-essential \
    clang-14 \
    clang-format-14 \
    clang-tidy-14 \
    clang-tools-14\
    clangd-14 \
    libc++-14-dev \
    libc++abi-14-dev \
    libc++abi1-14 \
    libclang-14-dev \
    libclang-common-14-dev \
    libclang-cpp14 \
    libclang-cpp14-dev \
    libclang1-14 \
    libclc-14 \
    libclc-14-dev \
    libfuzzer-14-dev \
    liblld-14 \
    liblld-14-dev \
    liblldb-14 \
    liblldb-14-dev \
    libllvm-14-ocaml-dev \
    libllvm14 \
    libmlir-14 \
    libmlir-14-dev \
    libomp-14-dev \
    libomp-14-doc \
    libomp5-14 \
    libunwind-14 \
    libunwind-14-dev \
    lld-14 \
    lldb-14 \
    llvm-14 \
    llvm-14-dev \
    llvm-14-linker-tools \
    llvm-14-runtime \
    llvm-14-tools \
    mlir-14-tools \
    python3-clang-14 \
    python3-lldb-14 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp
