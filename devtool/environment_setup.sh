# Copyright (c) 2017 Paul Helter
set -ex

# Base Software properties for ppa lists.
apt-get update -y
apt-get install -y software-properties-common wget

# GCC Arm Embedded processor repository location (added before first update).
add-apt-repository -y ppa:team-gcc-arm-embedded/ppa
apt-get update -y

# Environment setup for latest cmake: see : https://apt.kitware.com/
#wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | sudo apt-key add -
#For Ubuntu Bionic Beaver (18.04):
#sudo apt-add-repository 'deb https://apt.kitware.com/ubuntu/ bionic main'
#sudo apt-get update
#sudo apt-get install kitware-archive-keyring
#sudo apt-key --keyring /etc/apt/trusted.gpg del C1F34CDD40CD72DA

#Environment items for Cmake, build, documentation, linting.
apt-get install -y cmake clang-format-8 clang-tidy-8 iwyu
apt-get install -y doxygen graphviz default-jdk python3-sphinx python3-pip
apt-get install -y ninja-build ccache

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


