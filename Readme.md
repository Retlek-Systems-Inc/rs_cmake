# CMake Typical Build Environment

This directory provides the ability to compile and test code cross compiler using:
* GoogleTest
* Sanitizers (Linux only)
* Integration of clang-tidy and clang-format
* Doxygen Documentation generation
* Cross Compiling for ARM

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
cmake -G Ninja ..
ninja
```

## Alternative builds.

* For Clang Compile

```bash
cd build
cmake -G Ninja -DCMAKE_TOOLCHAIN_FILE=../cmake/toolchain/clang.toolchain.cmake ..
ninja
```

* For Cross Compile using GCC, note that tests are turned off for these.

```bash
cd build
cmake -G Ninja -DBUILD_TEST=OFF -DCMAKE_TOOLCHAIN_FILE=cmake/toolchain/arm-gcc.toolchain.cmake ..
ninja
```

*Output is in TBD: - will sort this out later.*

**For Cross Compile with CLANG - *( WORK IN PROGRESS )**

```bash
cd build
cmake -G Ninja -DBUILD_TEST=OFF -DCMAKE_TOOLCHAIN_FILE=cmake/toolchain/arm-clang.toolchain.cmake ..
ninja
```

## Code Cleanup

Code cleanup is performed with clang-tidy.  Reporting of clang tidy results is performed with the compile.  
It is run if clang-tidy is installed and the STATIC_ANALYSIS=ON (default on for native builds, and off for cross compiled builds).

To clean-up the code automatically with CLANG_TIDY, you can modify the .clang-tidy file and then perform the following to fix any issues.
Note: Not all issues are fixable by clang-tidy so some of the reported errors/warnings may need to be cleaned up manually.

```bash
cd build
cmake -G Ninja -DCLANG_TIDY_FIX=1 ..
ninja
```


## Running Tests

Tests are performed with googletest in the native platform (not via cross compile)

For Linux environment the following can be run:

```bash
cd build
ninja
ninja test
```

Performing `ninja test` runs all of the unit tests under the CTest framework.  This will all gtest `TestTarget` executables one after another and give pass-fail per `TestTarget`

To perform an independent test and see the more detailed test results for each test suite, perform:

```bash
cd build
ninja
test/UnitTest_<target>
```

Once compiled each test resides in `build/test/UnitTest_<target>`.

### Running Tests with coverage

```bash
cd build
cmake -G Ninja -DCMAKE_BUILD_TYPE=COVERAGE ..
ninja
# This will generate the code coverage directory.
ninja code-coverage
# This will display the code coverage.
firefox code-coverage/index.html
```

All of the HTML output of code coverage resides in `build/code-coverage`.


### Running Tests with Sanitizers.

[] TODO: Need to remove googletest and other third-party compiled library from sanitizer list.

* For Address Sanitizer - run on suite of tests:

```bash
cd build
cmake -G Ninja -DCMAKE_BUILD_TYPE=ASAN -DCMAKE_TOOLCHAIN_FILE=cmake/toolchain/clang.toolchain.cmake ..
ninja
ninja test
```

* For Thread Sanitizer - run on suite of tests:

```bash
cd build
cmake -G Ninja -DCMAKE_BUILD_TYPE=TSAN -DCMAKE_TOOLCHAIN_FILE=cmake/toolchain/clang.toolchain.cmake ..
ninja
ninja test
```

For Memory Sanitizer - run on suite of tests:

```bash
cd build
cmake -G Ninja -DCMAKE_BUILD_TYPE=MSAN -DCMAKE_TOOLCHAIN_FILE=cmake/toolchain/clang.toolchain.cmake ..
ninja
ninja test
```
For Undefined Behavior Sanitizer - run on suite of tests:

```bash
cd build
cmake -G Ninja -DCMAKE_BUILD_TYPE=UBSAN -DCMAKE_TOOLCHAIN_FILE=cmake/toolchain/clang.toolchain.cmake ..
ninja
ninja test
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
