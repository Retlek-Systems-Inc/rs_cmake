# Copyright (c) 2017 Paul Helter
# add a target to generate API documentation with Doxygen

if(VERILOG_TEST)

    # Currently using verilator for testing.
    find_package(verilator REQUIRED) # 4.022 )
    
    #TODO: Wrap the verilog definitions to allow other build environments?
    
#    include(FetchContent)
#    FetchContent_Declare(
#      verilatorSource 
#      GIT_REPOSITORY    http://git.veripool.org/git/verilator
#      GIT_TAG           v4.0.
#    )
    #FetchContent_MakeAvailable(verilatorSource)

    # Other options later:
#    FetchContent_Declare(
#      icarus 
#      GIT_REPOSITORY   https://github.com/steveicarus/iverilog.git
#      GIT_TAG          TBD
#    )
#    FetchContent_MakeAvailable(verilatorSource)
    
endif(VERILOG_TEST)
