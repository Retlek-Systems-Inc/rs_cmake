# Docker file for installation.

# Copyright (c) 2024 Retlek Systems Inc.

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

LABEL org.opencontainers.image.description="RS CMake Software Dev Local"

CMD [ "/bin/bash" ]

# Build info for local docker usage with vscode
ARG USERNAME=
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Common debugging and support tools
# hadolint ignore=DL3008
RUN apt-get update -y \
    && DEBIAN_FRONTEND=noninteractive \
    apt-get install --no-install-recommends -y \
    bash-completion \
    gdb \
    vim \
    xz-utils \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create the user - check if user_gid already exists.
# See: https://code.visualstudio.com/remote/advancedcontainers/add-nonroot-user#_creating-a-nonroot-user
RUN PREV_GNAME=$(getent group "${USER_GID}" | cut -d: -f1) \
    && if [ -n "${PREV_GNAME}" ]; then \
    groupmod -n "${USERNAME}" "${PREV_GNAME}" \
    && echo "Group ${PREV_GNAME} renamed: ${USERNAME}"; \
    else \
    groupadd --gid "${USER_GID}" "${USERNAME}" \
    && echo "Group added and named: ${USERNAME}"; \
    fi \
    && PREV_UNAME=$(getent passwd "${USER_UID}" | cut -d: -f1) \
    && if [ -n "${PREV_UNAME}" ]; then \
    usermod -l "${USERNAME}" "${PREV_UNAME}" \
    && usermod -g "${USER_GID}" "${USERNAME}" \
    && usermod -d "/home/${USERNAME}" -m "${USERNAME}" \
    && echo "User ${PREV_UNAME} renamed: ${USERNAME}"; \
    else \
    useradd --uid "${USER_UID}" --gid "${USER_GID}" -m "${USERNAME}" \
    && echo "User added and named: ${USERNAME}"; \
    fi \
    && mkdir -p /etc/sudoers.d \
    && echo "${USERNAME} ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/${USERNAME} \
    && chmod 0440 /etc/sudoers.d/${USERNAME} \
    && usermod -a -G dialout "${USERNAME}"

ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8
