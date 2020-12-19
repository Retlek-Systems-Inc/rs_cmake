find_program(GCC_C 
    NAMES
        gcc
        gcc-11
        gcc-10
        gcc-9
        gcc-8
        gcc-7
        gcc-6
        gcc-5
        gcc-4
)

find_program(GCC_CXX
    NAMES
        g++
        g++-11
        g++-10
        g++-9
        g++-8
        g++-7
        g++-6
        g++-5
        g++-4
)        

set(CMAKE_C_COMPILER_ID GNU )
set(CMAKE_C_COMPILER ${GCC_C})
set(CMAKE_CXX_COMPILER_ID GNU )
set(CMAKE_CXX_COMPILER ${GCC_CXX})
