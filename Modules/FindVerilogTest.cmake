# @copyright 2017 Retlek Systems Inc.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
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
