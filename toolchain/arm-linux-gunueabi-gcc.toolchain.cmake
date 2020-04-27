include(CMakeForceCompiler)

set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR ARM)
set(TOOLCHAIN_TRIPPLE arm-linux-gnueabi)

#find_program(TOOLCHAIN_C   NAMES ${TOOLCHAIN_PREFIX}-gcc )
#get_filename_component(TOOLCHAIN_DIR ${TOOLCHAIN_C} DIRECTORY)

set(CMAKE_C_COMPILER_TARGET ${TOOLCHAIN_TRIPPLE}-gcc)
set(CMAKE_CXX_COMPILER_TARGET ${TOOLCHAIN_TRIPPLE}-g++)


#set(CMAKE_C_FLAGS_INIT   "-B${TOOLCHAIN_DIR}")
#set(CMAKE_CXX_FLAGS_INIT "-B${TOOLCHAIN_DIR}")

# Assuming toolchain installed in /usr/
SET(CMAKE_FIND_ROOT_PATH "/usr/${TOOLCHAIN_TRIPPLE}" )
SET(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
SET(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
SET(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)