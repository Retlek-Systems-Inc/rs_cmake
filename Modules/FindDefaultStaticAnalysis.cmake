# Copyright (c) 2017 Paul Helter
# add a target to generate API documentation with Doxygen

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
      if(NOT CLANG_TIDY)
            message(WARNING "Could not find clang_tidy, must be installed to check for clang tidy issues.")
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
    
    #Google style checks:
    #set(CMAKE_CXX_CPPLINT )
    
    find_program(INCLUDE_WHAT_YOU_USE iwyu)
    if( NOT INCLUDE_WHAT_YOU_USE)
        message(WARNING "Could not find include-what-you-use iwyu, must be installed to perform static checks.")
    else()
         set(CMAKE_CXX_INCLUDE_WHAT_YOU_USE iwyu -Xiwyu --verbose=3)
         set(CMAKE_C_INCLUDE_WHAT_YOU_USE iwyu -Xiwyu --verbose=3)
#         set(CMAKE_LINK_WHAT_YOU_USE TRUE)
    endif()
endif(STATIC_ANALYSIS)
