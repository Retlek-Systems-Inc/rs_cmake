# Docker file for installation.

# Copyright (c) 2023 Retlek Systems Inc.

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
FROM ghcr.io/Retlek-Systems-Inc/rs_cmake/sw-dev:latest

# Based off: https://github.com/espressif/esp-idf/blob/v4.4.3/tools/docker/Dockerfile

# Default tools for building esp-idf
# hadolint ignore=DL3008,DL3013
RUN apt-get update -y \
  && DEBIAN_FRONTEND=noninteractive \
  apt-get install --no-install-recommends -y \
  apt-utils \
  bison \
  ca-certificates \
  ccache \
  check \
  curl \
  flex \
  git \
  git-lfs \
  gperf \
  lcov \
  libffi-dev \
  libncurses-dev \
  libpython2.7 \
  libusb-1.0-0-dev \
  make \
  ninja-build \
  python3 \
  python3-pip \
  unzip \
  wget \
  xz-utils \
  zip \
  && apt-get autoremove -y \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  && update-alternatives --install /usr/bin/python python /usr/bin/python3 10 \
  && python -m pip install --no-cache-dir --upgrade \
  pip \
  virtualenv

# To build the image for a branch or a tag of IDF, pass --build-arg IDF_CLONE_BRANCH_OR_TAG=name.
# To build the image with a specific commit ID of IDF, pass --build-arg IDF_CHECKOUT_REF=commit-id.
# It is possibe to combine both, e.g.:
#   IDF_CLONE_BRANCH_OR_TAG=release/vX.Y
#   IDF_CHECKOUT_REF=<some commit on release/vX.Y branch>.
# Use IDF_CLONE_SHALLOW=1 to peform shallow clone (i.e. --depth=1 --shallow-submodules)
# Use IDF_INSTALL_TARGETS to install tools only for selected chip targets (CSV)

ARG IDF_CLONE_URL=https://github.com/espressif/esp-idf.git
#ARG IDF_CLONE_BRANCH_OR_TAG=master
ARG IDF_CLONE_BRANCH_OR_TAG=v4.4.3
ARG IDF_CHECKOUT_REF=
ARG IDF_CLONE_SHALLOW=
#ARG IDF_INSTALL_TARGETS=all
ARG IDF_INSTALL_TARGETS=esp32

ENV IDF_PATH=/opt/esp/idf
ENV IDF_TOOLS_PATH=/opt/esp

# hadolint ignore=DL3003
RUN echo IDF_CHECKOUT_REF=$IDF_CHECKOUT_REF IDF_CLONE_BRANCH_OR_TAG=$IDF_CLONE_BRANCH_OR_TAG \
  && git clone --recursive \
  ${IDF_CLONE_SHALLOW:+--depth=1 --shallow-submodules} \
  ${IDF_CLONE_BRANCH_OR_TAG:+-b $IDF_CLONE_BRANCH_OR_TAG} \
  $IDF_CLONE_URL $IDF_PATH \
  && git config --global --add safe.directory $IDF_PATH \
  && git config --global --add safe.directory $IDF_PATH/components/openthread/openthread \
  && if [ -n "$IDF_CHECKOUT_REF" ]; then \
  cd $IDF_PATH \
  && if [ -n "$IDF_CLONE_SHALLOW" ]; then \
  git fetch origin --depth=1 --recurse-submodules ${IDF_CHECKOUT_REF}; \
  fi \
  && git checkout $IDF_CHECKOUT_REF && \
  git submodule update --init --recursive; \
  fi

# Install all the required tools
# hadolint ignore=SC2046
RUN update-ca-certificates --fresh \
  && $IDF_PATH/tools/idf_tools.py --non-interactive install required --targets=${IDF_INSTALL_TARGETS} \
  && $IDF_PATH/tools/idf_tools.py --non-interactive install cmake \
  && $IDF_PATH/tools/idf_tools.py --non-interactive install-python-env \
  && eval $($IDF_PATH/tools/idf_tools.py export --prefer-system) \
  && rm -rf $IDF_TOOLS_PATH/dist

# Ccache is installed, enable it by default
ENV IDF_CCACHE_ENABLE=1

RUN  printf "\
  #!/usr/bin/env bash \n\
  set -e\n\
  . \$IDF_PATH/export.sh\n\
  exec \"\$@\"" > /opt/esp/entrypoint.sh

ENTRYPOINT [ "/opt/esp/entrypoint.sh" ]
CMD [ "/bin/bash" ]
