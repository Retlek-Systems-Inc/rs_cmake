# CMake Build Environment

This directory provides the ability to compile and test code cross compiler using:

* GoogleTest
* Sanitizers (Linux only)
* Integration of clang-tidy and clang-format
* Doxygen Documentation generation
* Cross Compiling for ARM
* Verilog to C++ Compiler

## First Steps

Install and initialize on Ubuntu Linux Environment perform:

```bash
cmake/environment_setup.sh
git submodule init
git submodule update
```

* To build - first create a build directory:

```bash
mkdir build
cd build
```

* For Native Linux Compile environment:

```bash
cd build
cmake -G"Ninja Multi-Config" ..
cmake --build . --config Debug
```

## Alternative builds.

* For Clang Compile

```bash
cd build
cmake -G"Ninja Multi-Config" -DCMAKE_C_COMPILER=clang-14 -DCMAKE_CXX_COMPILER=clang++-14 ..
cmake --build . --config Debug
```

* For Cross Compile using GCC, note that tests are turned off for these.

```bash
cd build
cmake -G"Ninja Multi-Config" -DBUILD_TEST=OFF -DCMAKE_TOOLCHAIN_FILE=cmake/toolchain/arm-gcc.toolchain.cmake ..
cmake --build . --config Release
```

*Output is in TBD: - will sort this out later.*

**For Cross Compile with CLANG - *( WORK IN PROGRESS )**

```bash
cd build
cmake -G"Ninja Multi-Config" -DBUILD_TEST=OFF -DCMAKE_TOOLCHAIN_FILE=cmake/toolchain/arm-clang.toolchain.cmake ..
cmake --build . --config Release
```

## Code Cleanup

Code cleanup is performed with clang-tidy.  Reporting of clang tidy results is performed with the compile.  
It is run if clang-tidy is installed and the STATIC_ANALYSIS=ON (default on for native builds, and off for cross compiled builds).

To clean-up the code automatically with CLANG_TIDY, you can modify the .clang-tidy file and then perform the following to fix any issues.
Note: Not all issues are fixable by clang-tidy so some of the reported errors/warnings may need to be cleaned up manually.

```bash
cd build
cmake -G"Ninja Multi-Config" -DCLANG_TIDY_FIX=1 ..
cmake --build . --config Debug
```


## Running Tests

Tests are performed with googletest in the native platform (not via cross compile)

For Linux environment the following can be run:

```bash
cd build
cmake --build . --config Debug
```

Performing `ninja test` runs all of the unit tests under the CTest framework.  This will all gtest `TestTarget` executables one after another and give pass-fail per `TestTarget`

To perform an independent test and see the more detailed test results for each test suite, perform:

```bash
cd build
cmake --build . --config Debug
test/UnitTest_<target>
```

Once compiled each test resides in `build/test/UnitTest_<target>`.

### Running Tests with coverage

```bash
# Note must be run with GCC.
cd build
cmake -G"Ninja Multi-Config" ..
# This will generate the code coverage directory.
cmake --build . --config Coverage --target code-coverage
# This will display the code coverage.
firefox code-coverage/index.html
```

All of the HTML output of code coverage resides in `build/code-coverage`.

### Running Tests with Clang Tidy

* For Clang Tidy - Just checks

```bash
cd build
cmake -G"Ninja Multi-Config" -DSTATIC_ANALYSIS=ON -DUSE_CLANG_TIDY=ON ../.
cmake --build . --config Debug
```

* For Clang Tidy - Fixes

```bash
cd build
cmake -G"Ninja Multi-Config" -DSTATIC_ANALYSIS=ON -DUSE_CLANG_TIDY=ON -DCLANG_TIDY_FIX=ON ../.
cmake --build . --config Debug
```

### Running Tests with Sanitizers

[] TODO: Need to remove googletest and other third-party compiled library from sanitizer list.

* For Address Sanitizer - run on suite of tests:

```bash
cd build
cmake -G"Ninja Multi-Config" -DCMAKE_C_COMPILER=clang-14 -DCMAKE_CXX_COMPILER=clang++-14 ..
cmake --build . --config Asan --target test
```

* For Thread Sanitizer - run on suite of tests:

```bash
cd build
cmake -G"Ninja Multi-Config" -DCMAKE_C_COMPILER=clang-14 -DCMAKE_CXX_COMPILER=clang++-14 ..
cmake --build . --config Tsan --target test
```

For Memory Sanitizer - run on suite of tests:

```bash
cd build
cmake -G"Ninja Multi-Config" -DCMAKE_C_COMPILER=clang-14 -DCMAKE_CXX_COMPILER=clang++-14 ..
cmake --build . --config Msan --target test
```

For Undefined Behavior Sanitizer - run on suite of tests:

```bash
cmake -G"Ninja Multi-Config" -DCMAKE_C_COMPILER=clang-14 -DCMAKE_CXX_COMPILER=clang++-14 ..
cmake --build . --config Ubsan --target test
```

For Valgrind - run on suite of tests:
**[] TODO:  Haven't gotten this to run yet.**

```bash
```
 
## Creating documentation

To create documentation perform the following:

```bash
cd build
ninja doc

# to view:
firefox doc/html/index.html
```

Be sure to check the warnings - missing definitions.

## Windows Builds with Microsoft Visual Studio 2019 (or higher) or Visual Code with WSL2

### Install

Install Microsoft Visual Studio 2019 with following options:

* Python Development
* Desktop development with C++
* Linux development with C++

Install LLVM Tools

* linux - then install llvm tools:  https://apt.llvm.org/
* windows - then https://llvm.org/builds/

Update VSCode to use clang-format:
* [Clang Format](https://marketplace.visualstudio.com/items?itemName=xaver.clang-format)
And configure to where clang-format is installed.

### Running

Select `Project->CMake Settings for <project>`
Add a Configuration - `Mingw64-Debug`
Select the link CMakeSettings.json`
Build Options:

```json
{
    "MINGW64_ROOT": "C:\\msys64\\mingw64",
    "BIN_ROOT": "${env.MINGW64_ROOT}\\..\\usr\\bin",
    "FLAVOR": "x86_64-w64-mingw32",
    "TOOLSET_VERSION": "7.3.0",
    "PATH": "${env.MINGW64_ROOT}\\bin;${env.MINGW64_ROOT}\\..\\usr\\local\\bin;${env.MINGW64_ROOT}\\..\\usr\\bin;${env.MINGW64_ROOT}\\..\\bin;${env.PATH}",
    "INCLUDE": "${env.INCLUDE};${env.MINGW64_ROOT}\\include\\c++\\${env.TOOLSET_VERSION};${env.MINGW64_ROOT}\\include\\c++\\${env.TOOLSET_VERSION}\\tr1;${env.MINGW64_ROOT}\\include\\c++\\${env.TOOLSET_VERSION}\\${env.FLAVOR}",
    "environment": "mingw_64"
}
```

## Continuous Integration/Deployment Setup

### DockerHub & Bitbucket pipelines setup

DockerHub configuration:

* Goto:  DockerHub and setup an account for yourself
* Goto: Menu - User -> Account Settings
  * Select Security and add 2 Personal Access tokens
  * One Read,Write,Modify <RWM_TOKEN> - this will be for the rs-cmake repo which creates the docker images
    * One Read only <RO_TOKEN> - this will be for accessing the docker images from other repos that only require
      consuming the docker image.

Bitbucket configuration:

* Goto the rs-cmake repo and select left hand menu Repository Settings
  * Left hand Menu - under PIPELINES - select Repository Variables and add secure variables:
  * DOCKERHUB_PASSWORD - <RWM_TOKEN> - Read/write/modify access token
* Then go to workspace variables link on that page and add secure variables:
  * DOCKERHUB_USER - username for docker hub.
  * DOCKERHUB_PASSWORD - <RO_TOKEN> - Read only access token

This will ensure that the docker hub username and read-only password is available to all repos
and the docker hub password for read/write/modify is only available to the rs_cmake repo.