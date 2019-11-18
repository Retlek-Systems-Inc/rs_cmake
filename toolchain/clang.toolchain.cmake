
find_program(CLANG_C 
    NAMES
        clang
        clang-8
        clang-7
        clang-6.0
        clang-5.0
        clang-4.0
        clang-3.9
)

find_program(CLANG_CXX
    NAMES
        clang++
        clang++-8
        clang++-7
        clang++-6.0
        clang++-5.0
        clang++-4.0
        clang++-3.9
)        

set(CMAKE_C_COMPILER ${CLANG_C})
set(CMAKE_CXX_COMPILER ${CLANG_CXX})
