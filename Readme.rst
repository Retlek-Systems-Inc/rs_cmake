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

.. code:: bash

   cmake/environment_setup.sh
   git submodule init
   git submodule update

-  To build - first create a build directory:

.. code:: bash

   mkdir build
   cd build

-  For Native Linux Compile environment:

.. code:: bash

   cd build
   cmake -G"Ninja Multi-Config" ..
   cmake --build . --config Debug

Alternative builds.
-------------------

For Clang Compile

.. code:: bash

   cd build
   cmake -G"Ninja Multi-Config" -DCMAKE_C_COMPILER=clang-18 -DCMAKE_CXX_COMPILER=clang++-18 ..
   cmake --build . --config Debug

For Cross Compile using GCC, note that tests are automatically turned off for any cross-compiled code since
many cross compiler devices are not setup to fully support GoogleTest.

.. code:: bash

   cd build
   cmake -G"Ninja Multi-Config" -DBUILD_TEST=OFF -DCMAKE_TOOLCHAIN_FILE=cmake/toolchain/arm-gcc.toolchain.cmake ..
   cmake --build . --config Release

For Cross Compile with CLANG

.. note::

   Work in Progress

.. code:: bash

   cd build
   cmake -G"Ninja Multi-Config" -DBUILD_TEST=OFF -DCMAKE_TOOLCHAIN_FILE=cmake/toolchain/arm-clang.toolchain.cmake ..
   cmake --build . --config Release

Code Cleanup
------------

Code cleanup is performed with clang-tidy. Reporting of clang tidy results is performed with the compile.
It is run if clang-tidy is installed and the STATIC_ANALYSIS=ON (default on for native builds, and off for cross compiled builds).

To clean-up the code automatically with CLANG_TIDY, you can modify the .clang-tidy file and then perform the following to fix any issues.

.. note::
  Not all issues are fixable by clang-tidy so some of the reported errors/warnings may need to be cleaned up manually.

.. code:: bash

   cd build
   cmake -G"Ninja Multi-Config" -DCLANG_TIDY_FIX=1 ..
   cmake --build . --config Debug


Running Tests
-------------

Tests are performed with googletest in the native platform (not via cross compile)

For Linux environment the following can be run:

.. code:: bash

   cd build
   cmake --build . --config Debug
   cmake --build . --config Debug --target test


Performing ``ninja test`` runs all of the unit tests under the CTest framework.
This will run all gtest ``TestTarget`` executables one after another and give pass-fail per ``TestTarget``

To perform an independent test and see the more detailed test results for each test suite, perform:

.. code:: bash

   cd build
   cmake --build . --config Debug
   test/UnitTest_<target>

Once compiled each test resides in ``build/test/UnitTest_<target>``.

Running Tests with coverage
~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code:: bash

   # Note must be run with GCC.
   cd build
   cmake -G"Ninja Multi-Config" ..
   # This will generate the code coverage directory.
   cmake --build . --config Coverage --target code-coverage
   # This will display the code coverage.
   firefox code-coverage/index.html

All of the HTML output of code coverage resides in
``build/code-coverage``.

Running Tests with Clang Tidy
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

For Clang Tidy - Just checks

.. code:: bash

   cd build
   cmake -G"Ninja Multi-Config" -DSTATIC_ANALYSIS=ON -DUSE_CLANG_TIDY=ON ../.
   cmake --build . --config Debug

-  For Clang Tidy - Fixes

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

.. code:: bash

   cd build
   cmake -G"Ninja Multi-Config" -DSTATIC_ANALYSIS=OFF -DCMAKE_C_COMPILER=clang-18 -DCMAKE_CXX_COMPILER=clang++-18 ..

For Address Sanitizer - run on suite of tests:

.. code:: bash

   cmake --build . --config Asan --target test

For Thread Sanitizer - run on suite of tests:

.. code:: bash

   cmake --build . --config Tsan --target test

For Memory Sanitizer - run on suite of tests:

.. code:: bash

   cmake --build . --config Msan --target test

For Undefined Behavior Sanitizer - run on suite of tests:

.. code:: bash

   cmake --build . --config Ubsan --target test

For Control Flow Integrity Sanitizer - run on suite of tests:

.. code:: bash

   cmake --build . --config Cfisan --target test

For Valgrind - run on suite of tests:

[] TODO: Haven't gotten this to run yet.


Creating documentation
----------------------

To create documentation perform the following:

.. code:: bash

   cd build
   cmake --build . --config Ubsan --target doc
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
