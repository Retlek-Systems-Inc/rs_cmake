For Configure Presets:

    // Can change later but assuming that using the rs_cmake docker images that have a copy rs_cmake in there
```json
    "toolchainFile": "$ENV{CMAKE_ENV_DEPS_PATH}/rs_cmake-src/toolchain/gcc.toolchain.cmake",
```

After the native you can add your own configurePresets:

```json
        {
            "name": "device",
            "description": "Device configuration for all device specific builds",
            "hidden": false,
            "generator": "Ninja Multi-Config",
            "binaryDir": "${sourceDir}/build_device",
            "toolchainFile": "${sourceDir}/third_party/aarch64-poky-linux-gnu.toolchain.cmake",
            "cacheVariables": {
                "STATIC_ANALYSIS": "OFF",
                "BUILD_FOR_DEVICE": "ON"
            }
        }
```


For build presets not all are defined, just debug and release & relWithDebInfo for specific tests.
Some of the runs will only run with clang or gcc.


For test presets these are a copy of the build presets without the static analysis checks because those are all done at build time.

If new build presets are provided and you require additional test presets copy and paste and modify the necessary inherits.