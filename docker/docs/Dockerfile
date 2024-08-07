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

LABEL org.opencontainers.image.description="RS CMake Documentation Dev"

ENV PLANTUML_DIR="/java"

# Documentation dev tools
#hadolint ignore=DL3008
RUN apt-get update -y \
    && DEBIAN_FRONTEND=noninteractive \
    apt-get install --no-install-recommends -y \
    doxygen \
    openjdk-21-jre-headless \
    graphviz \
    default-jdk \
    python3 \
    python3-breathe \
    python3-venv \
    python3-sphinx \
    python3-sphinxcontrib.plantuml \
    python3-sphinx-rtd-theme \
    python3-pip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# nmp install -g less clean-css
ARG PLANTUML_VERSION="1.2024.6"
ARG PLANTUML_FILE="plantuml-${PLANTUML_VERSION}.jar"
#hadolint ignore=DL3013
RUN mkdir -p ${PLANTUML_DIR} \
    && wget --progress=dot:giga "https://github.com/plantuml/plantuml/releases/download/v${PLANTUML_VERSION}/${PLANTUML_FILE}" -O ${PLANTUML_DIR}/plantuml.jar

# TODO add in later if needed.
# && python3 -m pip install --break-system-packages --upgrade pip setuptools wheel \
# && python3 -m pip install --break-system-packages --no-cache-dir \
# sphinx-fontawesome \
# sphinx-toolbox

WORKDIR /tmp
