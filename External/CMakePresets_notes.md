For Configure Presets:

The `Bootstrap` is used to initialize with an initial .deps/rs_cmake-src before any further updates can be done.

Use:

```bash
cmake --preset bootstrap
```

first and then this will allow all presets to be setup properly.

The included presets are for canned sets of build types and examples.

Add your own configurePresets, build, test, workflow presets as needed eg:

```json

    "configurePresets": [
        {
            "name": "arm-none-gcc",
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
    ]
    ...
```

For build presets not all are defined or supported.

The following are not supported:
- native-clang-msan (build, test, workflow) - issue with stdlib library not being built for msan.
- native-clang-coverage - is not usable - requires llvm-cov to be configured and setup.  Not done yet.
see CMake - [CTestCoverageCollectGCOV](https://cmake.org/cmake/help/latest/module/CTestCoverageCollectGCOV.html#module:CTestCoverageCollectGCOV)
- native-gcc-msan isn't 

For test presets these are a copy of the build presets without the static analysis checks because those are all done at build time.
If new build presets are provided and you require additional test presets copy and paste and modify the necessary inherits.
