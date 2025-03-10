Retlek Systems CMake Build Environment
======================================

This directory provides the ability to compile and test code cross compiler using:

-  GoogleTest
-  Sanitizers (Linux only)
-  Integration of clang-tidy and clang-format
-  Doxygen Documentation generation
-  Cross Compiling for ARM
-  Verilog to C++ Compiler

First Steps
-----------

Install and initialize on Ubuntu Linux Environment perform:

If you would like to create your own dockerfile - please use ``docker/sw-dev/Dockerfile`` as a base for this definition.
All `Pre generated Docker images <https://github.com/orgs/Retlek-Systems-Inc/packages?repo_name=rs_cmake>`_ are provided for use with this repo.

For Native Linux Compile environment:

Create a simple CMakeLists.txt file for your code in your repo - see `base.cmake <https://github.com/Retlek-Systems-Inc/rs_cmake/blob/main/docker/sw-dev/base.cmake>`_ as an example.
Copy the `External/.devcontainer <https://github.com/Retlek-Systems-Inc/rs_cmake/tree/main/External/.devcontainer>`_ for VSCode + Docker support.

Extensive use of ``CMakePresets.json`` is used to identify and create workflows for common builds and analysis.

Initialize the directory with rs_cmake and other common modules:

.. code:: bash

   cmake --preset=bootstrap

This will download the common rs_cmake and dependencies into a .deps directory for sharing among the various build directories.

Alternative builds.
-------------------

For a list of various presets defined use:

.. code:: bash

    cmake --list-presets            # for configure presets
    cmake --list-presets=build      # for build presets
    cmake --list-presets=test       # for test presets

    # Example:
    cmake --list-presets=workflow   # for workflow presets
    Available workflow presets:
        "native-clang-debug"    - Native Clang Debug
        "native-clang-release"  - Native Clang Release
        "native-gcc-debug"      - Native Gnu Debug
        "native-gcc-release"    - Native Gnu Release
        "analysis-clang-tidy"   - Static Analysis Clang Tidy
        "analysis-cpp-check"    - Static Analysis Cpp Check
        "analysis-cpp-lint"     - Static Analysis Cpp Lint
        "asan"                  - Sanitize Address Workflow
        "tsan"                  - Sanitize Thread Workflow
        "ubsan"                 - Sanitize Undefined Behavior Workflow
        "msan"                  - Sanitize Memory Workflow
        "coverage"              - Coverage Workflow
        "device-relWithDebInfo" - Device Debug
        "device-release"        - Device Release


A Workflow will execute the configure/build/test flow all in one and possibly run post build commands for creating reports etc.

For Clang Configure/Build/Test

.. code:: bash

    cmake --workflow --preset=native-clang-[debug|release]

For Cross Compile using GCC, note that tests are automatically turned off for any cross-compiled code since
many cross compiler devices are not setup to fully support GoogleTest.

Be sure to identify the appropriate configurePreset for device toolchainFile file either from the project directory OR one from the ``.deps/rs_cmake-src/toolchain`` directory

.. code:: json

    {
        "configurePresets": {
            ...
            {
                "name": "device",
                "description": "Device configuration for all device specific builds",
                "hidden": true,
                "generator": "Ninja Multi-Config",
                "binaryDir": "${sourceDir}/build_device",
                "toolchainFile": "${sourceDir}/.deps/rs_cmake-src/toolchain/arm-none-eabi-gcc.toolchain.cmake",
                "cacheVariables": {
                    "STATIC_ANALYSIS": "OFF",
                    "BUILD_FOR_DEVICE": "ON"
                }
            }
        }
    }

Once this is defined running:

.. code:: bash
    cmake --workflow --preset=device-[relWithDebInfo|release]

will compile that specific device preset workflow.
    

Code Cleanup
------------

Code cleanup is performed with clang-tidy. Reporting of clang tidy results is performed with the compile.
It is run if clang-tidy is installed and the STATIC_ANALYSIS=ON (default on for native builds, and off for cross compiled builds).

To clean-up the code automatically with CLANG_TIDY, you can modify the .clang-tidy file and then perform the following to fix any issues.

.. note::

    Not all issues are fixable by clang-tidy so some of the reported errors/warnings may need to be cleaned up manually.

.. code:: bash

    cmake --workflow --preset=analysis-clang-tidy

It is also good practice to run LLVM ``scan-build`` on the test suite as well and this can be done on the static analysis builds using:

.. code:: bash

    scan-build-18 -o reports/scan-build -k --status-bugs -internal-stats --keep-empty cmake --workflow --preset=analysis-cpp-check

Running Tests
-------------

Tests are performed with googletest in the native platform (not via cross compile)

For Linux environment the following can be run:

.. code:: bash

    cmake --workflow --preset=native-clang-release
    # Once run through once all the builds and the unit tests will be performed.  Can run additional tests like:
    cmake --workflow --pretest=native-clang-release # To run again - but compilation will already have taken place.
    #OR
    ctest --preset=native-clang-debug-unit-test
    #OR to run 1000 iterations (see CMakePresets.json for definition) of the unit tests.
    ctest --preset=native-clang-release-stress-test

Performing ``ninja test`` runs all of the unit tests under the CTest framework.
This will run all gtest ``TestTarget`` executables one after another and give pass-fail per ``TestTarget``

To perform an independent test and see the more detailed test results for each test suite, perform:

.. code:: bash

    cmake --workflow --preset=native-clang-release
    build/test/Release/UnitTest_<target> is the command line location for the various builds.

Once compiled each test resides in ``build/test/UnitTest_<target>``.

Running Tests with coverage
~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code:: bash

    cmake --workflow --preset=coverage
    # To view the results:
    firefox build_gcc/code-coverage/index.html

All of the HTML output of code coverage resides in
``build_gcc/code-coverage``.

Running Analysis tests
~~~~~~~~~~~~~~~~~~~~~~

For Clang Tidy - Just checks

.. code:: bash

   cmake --workflow --preset=analysis-clang-tidy

For Clang Tidy - Fixes

.. code:: bash

   cd build
   cmake -G"Ninja Multi-Config" -DSTATIC_ANALYSIS=ON -DUSE_CLANG_TIDY=ON -DCLANG_TIDY_FIX=ON ../.
   cmake --build . --config Debug

Running Tests with Dynamic Sanitizers
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The sanitizer tests are only run with clang at the moment.  No testing of GNU compiler and sanitizers is performed.
Since these are dynamic sanitizers, it is suggested to disable static analysis for these specific tests to speed up the
compile time exection.

First Configure the cmake build directory with clang and multi-config:

For Address Sanitizer - run on suite of tests:

.. code:: bash

    cmake --workflow --preset=asan

For Thread Sanitizer - run on suite of tests:

.. code:: bash

    cmake --workflow --preset=tsan

For Memory Sanitizer - run on suite of tests:

.. code:: bash

    cmake --workflow --preset=msan

For Undefined Behavior Sanitizer - run on suite of tests:

.. code:: bash

    cmake --workflow --preset=ubsan

For Control Flow Integrity Sanitizer - run on suite of tests:

.. code:: bash

    cmake --workflow --preset=cfisan

For Valgrind - run on suite of tests:

[] TODO: Haven't gotten this to run yet.


Creating documentation
----------------------

To create documentation perform the following:

.. code:: bash

    cmake --preset=native-clang
    cd build
    ninja doc

    # to view:
    firefox doc/html/index.html

Be sure to check the warnings - missing definitions.

Development Environment with VSCode and WSL2 or VSCode on Linux
---------------------------------------------------------------

Install
~~~~~~~

* `VSCode <https://code.visualstudio.com/download>`_
* `Docker <https://docs.docker.com/get-docker/>`_
* `Git <https://git-scm.com/>`_

Windows Environment
~~~~~~~~~~~~~~~~~~~

* `WSL2 <https://learn.microsoft.com/en-us/windows/wsl/install>`_
* `Docker Desktop <https://www.docker.com/products/docker-desktop/>`_
* `USB for WSL2 (usbipd-win) <https://github.com/dorssel/usbipd-win/releases>`_
  * `How to setup USB with WSL2 <https://devblogs.microsoft.com/commandline/connecting-usb-devices-to-wsl/>`_
* `Authenticating to ghcr.io with personal access token <https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry#authenticating-with-a-personal-access-token-classic>`_

If you would like to use the provided docker images in this repo, you can by copying the ``External/.devcontainer`` files into your project and modify accordingly.

Update VSCode to use clang-format: \* `Clang
Format <https://marketplace.visualstudio.com/items?itemName=xaver.clang-format>`__
And configure to where clang-format is installed.

Docker One-time Setup
~~~~~~~~~~~~~~~~~~~~~

.. warning::

    Only Done once to allow access. May need to perform periodically depending on when keys are set to expire.


Open ``Docker Desktop`` and then open ``VSCode``.
Make Sure you have ``Docker Desktop`` running in the background in Windows before you start running VSCode or any of the following steps.

Inside VSCode:
* Change to using WSL2 - ``Ctrl-Shift-P`` and type ``WSL: Connect to WSL`` if your default WSL image is one of the ones defined above, or ``WSL: Connect to WSL using Distro...`` and select ``Ubuntu-22.04``
* install `Dev Containers <https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers>`_  This will allow the .devcontainer directory to automatically setup your docker images.
* Open up a Terminal - Navigate to Menu ``Terminal -> New Terminal``

.. note::

    The container registry is currently using github ``ghcr.io`` so some additional setup is necessary.

Using your github account perform the following to authenticate to the Container registry.
`Authenticating to the Container registry <https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry#authenticating-to-the-container-registry>`_
and `Authenticating with a personal access token (classic) <https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry#authenticating-with-a-personal-access-token-classic>`_

.. note::

    When creating the Personal Access Token (PAT) - ensure it is a ``classic`` and then under the checkboxes select **ONLY** : ``read:packages`` for the token.  This will give you the minimal access to ghcr.io that you require.

Make sure you run the following commands in the VSCode WSL2 terminal, as mentioned in the above ``Open up a terminal``.

.. code:: bash

    export CR_PAT=<YOUR_TOKEN>
    docker logout ghcr.io
    echo ${CR_PAT} | docker login ghcr.io -u <GitHub USERNAME> --password-stdin

You should then see:

.. code:: bash

    > Login Succeeded


Running
~~~~~~~

Selecting via VSCode you can use ``Ctrl-Shift-P`` Type: ``CMake: Select Variant`` to select the appropriate variant.
Once the appropriate variant is selected:
``Ctrl-Shift-P`` Type: ``CMake: Build`` to build the project
``Ctrl-Shift-P`` Type: ``CMake: Run Test`` to run the full suite of tests


Continuous Integration/Deployment Setup
---------------------------------------

Building Docker
~~~~~~~~~~~~~~~

See ``.github/publish_docker.yml`` but for building and debugging locally:

.. code:: bash

   cd docker/sw-dev
   docker build .
