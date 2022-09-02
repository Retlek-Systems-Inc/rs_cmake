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

# hadolint ignore=DL3007
FROM registry.gitlab.com/retleksystems/env/cmake/sw-dev:latest

ENV PLANTUML_DIR="~/java"

# Documentation dev tools
#hadolint ignore=DL3008
RUN DEBIAN_FRONTEND=noninteractive \
    apt-get install --no-install-recommends -y \
        doxygen \
        graphviz \
        default-jdk \
        python3-sphinx \
        python3-pip \
        graphviz \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p ${PLANTUML_DIR} \
    && wget -O ${PLANTUML_DIR}/plantuml.jar -progress=dot:giga http://sourceforge.net/projects/plantuml/files/plantuml.jar/download \
    && export PLANTUML_DIR=${PLANTUML_DIR} \
    && python3 -m pip install --no-cache-dir sphinx_rdt_theme==v1.0.0 \
    && python3 -m pip install --no-cache-dir breathe==4.34.0

WORKDIR /tmp