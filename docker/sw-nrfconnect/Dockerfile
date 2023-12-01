FROM registry.gitlab.com/retleksystems/env/cmake/sw-dev:v0.2.4 as base

ARG USERNAME=mw_dev
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && apt update \
    && apt install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

ARG arch=amd64
ARG crossarch=arm-zephyr-eabi
ARG ZEPHYR_TOOLCHAIN_VERSION=0.16.4
ARG ZEPHYR_TOOLCHAIN_ARCHIVE_FORMAT=xz
ARG WEST_VERSION=1.0.0
# These are the legacy utils, see https://github.com/NordicPlayground/nrf-docker/issues/68
ARG NRF_UTIL_VERSION=6.1.7
ARG NORDIC_COMMAND_LINE_TOOLS_VERSION="10-23-2/nrf-command-line-tools-10.23.2"

ENV DEBIAN_FRONTEND=noninteractive
ENV UDEV=on

# System dependencies
WORKDIR /workdir
RUN mkdir /workdir/.cache
RUN sudo chown -R $USERNAME:$USERNAME /workdir 

RUN sudo apt-get -y update && \
    sudo apt-get -y upgrade && \
    sudo apt-get -y install \
        cmake \
        libsdl2-dev \
        g++ \
        pkg-config \
        wget \
        python3-pip \
        python3-venv \
        ninja-build \
        gdb \
        gperf \
        git \
        unzip \
        libncurses5 libncurses5-dev \
        libyaml-dev libfdt1 \
        libusb-1.0-0-dev udev \
        device-tree-compiler \
        xz-utils \
        file \
        ruby && \
    case $arch in \
    "amd64") \
        apt-get -y install gcc-multilib \
        ;; \
    esac && \
    apt-get -y clean && apt-get -y autoremove

#
# Latest PIP & Python dependencies
#
RUN python3 -m pip install pip && \
    python3 -m pip install pipx && \
    python3 -m pipx ensurepath && \
    python3 -m pip install setuptools && \
    python3 -m pip install 'cmake>=3.20.0' wheel && \
    python3 -m pip install "west==${WEST_VERSION}" && \
    python3 -m pip install pc_ble_driver_py && \
    # Newer PIP will not overwrite distutils, so upgrade PyYAML manually
    python3 -m pip install --ignore-installed PyYAML

#
# Isolated command line tools
# No nrfutil 6+ release for arm64 (M1/M2 Macs) and Python 3, yet: https://github.com/NordicSemiconductor/pc-ble-driver-py/issues/227
#

RUN mkdir /opt/nrfutil && cd /opt/nrfutil && \
    wget https://developer.nordicsemi.com/.pc-tools/nrfutil/x64-linux/nrfutil && \
    chmod +x ./nrfutil
RUN sudo chown -R $USERNAME:$USERNAME /opt/nrfutil/*

#
# Nordic command line tools
# Releases: https://www.nordicsemi.com/Products/Development-tools/nrf-command-line-tools/download
#
RUN NCLT_BASE=https://nsscprodmedia.blob.core.windows.net/prod/software-and-other-downloads/desktop-software/nrf-command-line-tools/sw/versions-10-x-x && \
    echo "Host architecture: $arch" && \
    case $arch in \
        "amd64") \
            NCLT_URL="${NCLT_BASE}/${NORDIC_COMMAND_LINE_TOOLS_VERSION}_linux-amd64.tar.gz" \
            ;; \
        "arm64") \
            NCLT_URL="${NCLT_BASE}/${NORDIC_COMMAND_LINE_TOOLS_VERSION}_linux-arm64.tar.gz" \
            ;; \
    esac && \
    echo "NCLT_URL=${NCLT_URL}" && \
    # Releases: https://www.nordicsemi.com/Software-and-tools/Development-Tools/nRF-Command-Line-Tools/Download
    if [ ! -z "$NCLT_URL" ]; then \
        mkdir tmp && cd tmp && \
        mkdir /opt/SEGGER && \
        wget -qO - "${NCLT_URL}" | tar --no-same-owner -xz && \
        # Install included JLink
        tar xzf ./JLink_*.tgz -C /opt/SEGGER && \
        mv /opt/SEGGER/JLink* /opt/SEGGER/JLink && \
        # Install nrf-command-line-tools
        cp -r ./nrf-command-line-tools /opt && \
        ln -s /opt/nrf-command-line-tools/bin/nrfjprog /usr/local/bin/nrfjprog && \
        ln -s /opt/nrf-command-line-tools/bin/mergehex /usr/local/bin/mergehex && \
        cd .. && rm -rf tmp ; \
    else \
        echo "Skipping nRF Command Line Tools (not available for $arch)" ; \
    fi

RUN chmod -R u+s /opt/nrf-command-line-tools/bin/ && \
    chown -R $USERNAME:$USERNAME /opt/SEGGER/JLink/*

# Add the user to the dialout group - needed to access the USB serial device for UART
RUN usermod -a -G dialout $USERNAME

# Change user so the remaining items are not installed by root
USER $USERNAME

#
# Zephyr Toolchain
# Releases: https://github.com/zephyrproject-rtos/sdk-ng/releases
#
RUN echo "Host architecture: $arch" && \
    echo "Target architecture: ${crossarch}" && \
    echo "Zephyr Toolchain version: ${ZEPHYR_TOOLCHAIN_VERSION}" && \
    case $arch in \
        "amd64") \
            ZEPHYR_MINIMAL_BUNDLE_URL="https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v${ZEPHYR_TOOLCHAIN_VERSION}/zephyr-sdk-${ZEPHYR_TOOLCHAIN_VERSION}_linux-x86_64_minimal.tar.${ZEPHYR_TOOLCHAIN_ARCHIVE_FORMAT}" \
            ;; \
        "arm64") \
            ZEPHYR_MINIMAL_BUNDLE_URL="https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v${ZEPHYR_TOOLCHAIN_VERSION}/zephyr-sdk-${ZEPHYR_TOOLCHAIN_VERSION}_macos-aarch64_minimal.tar.${ZEPHYR_TOOLCHAIN_ARCHIVE_FORMAT}" \
            ;; \
        *) \
            echo "Unsupported host architecture: \"${arch}\"" >&2 && \
            exit 1 ;; \
    esac && \
    echo "Install Zephyr SDK from ZEPHYR_MINIMAL_BUNDLE_URL=${ZEPHYR_MINIMAL_BUNDLE_URL}" && \
    case $ZEPHYR_TOOLCHAIN_ARCHIVE_FORMAT in \
        "gz") \
            wget -qO - "${ZEPHYR_MINIMAL_BUNDLE_URL}" | tar xz;; \
        *) \
            wget -qO - "${ZEPHYR_MINIMAL_BUNDLE_URL}" | tar xJ;; \
    esac && \
    mv /workdir/zephyr-sdk-${ZEPHYR_TOOLCHAIN_VERSION} /workdir/zephyr-sdk && cd /workdir/zephyr-sdk && \
    case $arch in \
        "arm64") \
            ./setup.sh -t aarch64-zephyr-elf -c \
            ;; \
        *) \
            yes | ./setup.sh -t ${crossarch} \
            ;; \
    esac

# Download sdk-nrf and west dependencies to install pip requirements
FROM base
ARG sdk_nrf_revision=v2.5.0
RUN \
    mkdir nrfconnect && cd nrfconnect && \
    west init -m https://github.com/nrfconnect/sdk-nrf --mr ${sdk_nrf_revision} && \
    west update --narrow -o=--depth=1 && \
    echo "Installing requirements: zephyr/scripts/requirements.txt" && \
    python3 -m pip install -r zephyr/scripts/requirements.txt && \
    # Install only the requirements needed for building firmware, not documentation
    echo "Installing requirements: nrf/scripts/requirements-base.txt" && \
    python3 -m pip install -r nrf/scripts/requirements-base.txt && \
    echo "Installing requirements: nrf/scripts/requirements-build.txt" && \
    python3 -m pip install -r nrf/scripts/requirements-build.txt && \
    echo "Installing requirements: bootloader/mcuboot/scripts/requirements.txt" && \
    python3 -m pip install -r bootloader/mcuboot/scripts/requirements.txt

ENV WORK_PATH=/tmp
ENV CMAKE_ENV_DEPS_PATH=${WORK_PATH}/cmake_env_deps
ENV CMAKE_ENV_BASE_PATH=${WORK_PATH}/base

WORKDIR ${WORK_PATH}

# Now create DEPS directory with pre-downloaded git repos
RUN mkdir -p ${CMAKE_ENV_DEPS_PATH} \
    && mkdir -p ${CMAKE_ENV_BASE_PATH}

COPY base.cmake ${CMAKE_ENV_BASE_PATH}/CMakeLists.txt
COPY arm-zephyr-eabi-gcc.toolchain.cmake ${CMAKE_ENV_BASE_PATH}/arm-zephyr-eabi-gcc.toolchain.cmake

RUN sudo chown -R $USERNAME:$USERNAME /tmp
RUN  cmake -G "Ninja Multi-Config" -B${CMAKE_ENV_BASE_PATH}/build --toolchain ${CMAKE_ENV_BASE_PATH}/arm-zephyr-eabi-gcc.toolchain.cmake  -DFETCHCONTENT_BASE_DIR=${CMAKE_ENV_DEPS_PATH} ${CMAKE_ENV_BASE_PATH}

RUN mkdir /workdir/project
WORKDIR /workdir/project

ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8
ENV XDG_CACHE_HOME=/workdir/.cache
ENV ZEPHYR_TOOLCHAIN_VARIANT=zephyr
ENV ZEPHYR_SDK_INSTALL_DIR=/workdir/zephyr-sdk
ENV ZEPHYR_BASE=/workdir/nrfconnect/zephyr
ENV PATH="${ZEPHYR_SDK_INSTALL_DIR}:${PATH}"
ENV PATH="${ZEPHYR_SDK_INSTALL_DIR}/arm-zephyr-eabi/bin:${PATH}"
ENV PATH="${ZEPHYR_BASE}/scripts:${PATH}"
ENV PATH="/opt/SEGGER/JLink:${PATH}"
ENV PATH="/opt/nrfutil:${PATH}"
