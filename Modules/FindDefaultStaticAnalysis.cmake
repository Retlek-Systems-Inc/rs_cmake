# Copyright (c) 2017 Paul Helter
# https://blog.kitware.com/static-checks-with-cmake-cdash-iwyu-clang-tidy-lwyu-cpplint-and-cppcheck/

option(STATIC_ANALYSIS "Use Static Analysis tools." OFF)

if(STATIC_ANALYSIS)
    # This is used to add targets like third-party libraries that we want to bypass static analysis.
    add_custom_target(BypassStaticAnalysis)

    option(USE_CLANG_TIDY "Use Clang Tidy to view any inefficiencies or good practices." ON)

    if (USE_CLANG_TIDY)
      find_program(CLANG_TIDY 
        NAMES
            clang-tidy
            clang-tidy-8
            clang-tidy-7
            clang-tidy-6.0
            clang-tidy-4.0
      )
      message(STATUS "CLANG_TIDY = ${CLANG_TIDY}")
      if(NOT CLANG_TIDY)
            message(WARNING "Could not find clang_tidy, must be installed to perform static checks.")
        else()
            option(CLANG_TIDY_FIX "Perform fixes for Clang-Tidy" OFF)

            set(CMAKE_C_CLANG_TIDY ${CLANG_TIDY} "-format-style=file")
            set(CMAKE_CXX_CLANG_TIDY ${CLANG_TIDY} "-format-style=file")

            if (CLANG_TIDY_FIX)
                list(APPEND CMAKE_C_CLANG_TIDY   "-fix")
                list(APPEND CMAKE_CXX_CLANG_TIDY "-fix")
            else()
            endif()
        endif()
    endif()
    # Clang-Tidy None file for build dir /_deps - anything third-party or grabbed from elsewhere don't do clang tidy on.
    configure_file( "${CMAKE_CURRENT_LIST_DIR}/StaticAnalysis/.clang-tidy.none.in"
                    "${CMAKE_BINARY_DIR}/_deps/.clang-tidy" COPYONLY )
    
    # CppCheck - http://cppcheck.sourceforge.net/
    option(USE_CPPCHECK "Use CPP check to view any inefficiencies or good practices." OFF)
    if (USE_CPPCHECK)
        find_program(CPPCHECK
        NAMES
            cppcheck
            CppCheck
        )
        if(NOT CPPCHECK)
            message(WARNING "Could not find cppcheck, must be installed to perform static checks.")
        else()
            set(CMAKE_CXX_CPPCHECK ${CPPCHECK} "--std=c++11")
        endif()
    endif(USE_CPPCHECK)
                
    #Google style checks:
    # https://github.com/cpplint/cpplint
    option(USE_CPPLINT "Use CPP Lint to view any inefficiencies or good practices." OFF)
    if (USE_CPPLINT)
        find_program(CPPLINT
          NAMES
            cpplint
        )
        if(NOT CPPLINT)
            message(WARNING "Could not find clang_tidy, must be installed to perform static checks.")
        else()
            set(CMAKE_CXX_CPPLINT ${CPPLINT} "--linelength=200")
        endif()
    endif(USE_CPPLINT)

    # Include what you use
    option(USE_IWYU "Use Include What You Use static analysis." OFF)
    if (USE_IWYU)
        find_program(INCLUDE_WHAT_YOU_USE 
          NAMES 
            iwyu
            include-what-you-use
        )
        if( NOT INCLUDE_WHAT_YOU_USE)
            message(WARNING "Could not find include-what-you-use iwyu, must be installed to perform static checks.")
        else()
             set(CMAKE_CXX_INCLUDE_WHAT_YOU_USE include-what-you-use -Xiwyu --verbose=3)
             set(CMAKE_C_INCLUDE_WHAT_YOU_USE include-what-you-use -Xiwyu --verbose=3)
        endif()
    endif(USE_IWYU)
endif(STATIC_ANALYSIS)
