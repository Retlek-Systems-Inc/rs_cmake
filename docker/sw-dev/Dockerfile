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

FROM ubuntu:20.04

# Default GCC, latest cmake and ninja-build
RUN apt-get update -y \
    && DEBIAN_FRONTEND=noninteractive \
    apt-get install --no-install-recommends -y \
    software-properties-common \
    wget \
    gpg \
    && wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null \
    | gpg --dearmor - | tee /usr/share/keyrings/kitware-archive-keyring.gpg > /dev/null \
    && echo 'deb [signed-by=/usr/share/keyrings/kitware-archive-keyring.gpg] https://apt.kitware.com/ubuntu/ focal main' \
    | sudo tee /etc/apt/sources.list.d/kitware.list >/dev/null \
    && apt-get update -y \
    && DEBIAN_FRONTEND=noninteractive \
    apt-get install --no-install-recommends -y \
    kitware-archive-keyring \
    cmake \
    iwyu \
    ninja-build \
    ccache \
    lcov

# Documentation dev tools
# RUN DEBIAN_FRONTEND=noninteractive \
#         apt-get install --no-install-recommends -y \
#             doxygen \
#             graphviz \
#             default-jdk \
#             python3-sphinx \
#             python3-pip \
#             graphviz \
#     && pushd ~/. \
#     && mkdir java \
#     && cd java \
#     && wget -O plantuml.jar http://sourceforge.net/projects/plantuml/files/plantuml.jar/download \
#     && export PLANTUML_DIR="~/java" \
#     && popd \
#     && python3 -m pip install sphinx_rdt_theme \
#     && python3 -m pip install breathe

# Clang 13 + Tools + debugger (may upgrade later)
RUN wget https://apt.llvm.org/llvm.sh && chmod +x llvm.sh \
    && ./llvm.sh 13 \
    && DEBIAN_FRONTEND=noninteractive \
    apt-get install --no-install-recommends -y \
    libldb-13-dev \
    && git clone https://github.com/lldb-tools/lldb-mi \
    && cd lldb-mi \
    && cmake . \
    && cmake --build . \
    && make install \
    && export LLDB_DEBUGSERVER_PATH=/usr/bin/lldb-server-13

WORKDIR /tmp
