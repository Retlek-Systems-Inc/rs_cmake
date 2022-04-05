# Copyright (c) 2017 Paul Helter
set -ex

# Base Software properties for ppa lists.
apt-get update -y
apt-get install -y software-properties-common wget gpg

# GCC Arm Embedded processor repository location (added before first update).
add-apt-repository -y ppa:team-gcc-arm-embedded/ppa
apt-get update -y

# Latest CMake
wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | tee /usr/share/keyrings/kitware-archive-keyring.gpg > /dev/null
echo 'deb [signed-by=/usr/share/keyrings/kitware-archive-keyring.gpg] https://apt.kitware.com/ubuntu/ bionic main' | tee /etc/apt/sources.list.d/kitware.list > /dev/null
apt -y update
rm /usr/share/keyrings/kitware-archive-keyring.gpg
apt-get install -y kitware-archive-keyring cmake 

# Build Environment
git build-essential iwyu ninja-build ccache lcov


#Environment items for Documentation
apt-get install -y doxygen graphviz default-jdk python3-sphinx python3-pip


# Latest LLVM (clang*-13)
wget https://apt.llvm.org/llvm.sh && chmod +x llvm.sh
./llvm.sh 13

# For debug with LLVM Clang
apt-get install -y liblldb-13-dev
git clone https://github.com/lldb-tools/lldb-mi
cd lldb-mi
cmake .
cmake --build .
make install
export LLDB_DEBUGSERVER_PATH=/usr/bin/lldb-server-13

# Google style linting
#python3 -m pip install cpplint


# Coverage tool (can pick just one) `gcovr or lcov`
apt-get install -y lcov


apt-get install -y gcc-arm-embedded srecord

# Native compiler.
apt-get install -y g++ protobuf

# Native compiler (For 32-bit on Native machine)
apt-get install gcc-7 g++-7 gcc-7-multilib g++-7-multilib 

#PlantUML Install
pushd ~/.
mkdir java
cd java
wget -O plantuml.jar http://sourceforge.net/projects/plantuml/files/plantuml.jar/download
export PLANTUML_DIR="~/java"
popd

#Documentation using sphinx
python3 -m pip install sphinx_rtd_theme
python3 -m pip install breathe

# Protobuf Install
sudo apt-get install -y protobuf-compiler python-protobuf libprotobuf-dev


