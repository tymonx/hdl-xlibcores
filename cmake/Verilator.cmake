# Copyright (c) 2014, Tymoteusz Blazejczyk - www.tymonx.com
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
#
# * Neither the name of hdl-xlibcores nor the names of its
#   contributors may be used to endorse or promote products derived from
#   this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

macro(verilator_create)
    find_path(VERILATOR_INCLUDE_DIR verilated.h
        PATH_SUFFIXES verilator/include
        HINTS /usr/local/share)

    set(VERILATOR_SOURCE_LIST
        verilated.cpp
        verilated_save.cpp
        verilated_vcd_c.cpp
        verilated_vcd_sc.cpp
    )

    set(VERILATOR_SOURCES "")
    foreach(src ${VERILATOR_SOURCE_LIST})
        set(VERILATOR_SOURCES ${VERILATOR_SOURCES}
            ${VERILATOR_INCLUDE_DIR}/${src})
    endforeach()

    add_library(verilator SHARED ${VERILATOR_SOURCES})
endmacro()

macro(verilator_add verilog_module verilog_sources)
    # Redirect verilog C++ files to source subdirectory
    string(
        REGEX REPLACE "${CMAKE_SOURCE_DIR}/" ""
        VERILOG_OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}
    )

    set(VERILOG_OUTPUT_DIR "${CMAKE_SOURCE_DIR}/src/${VERILOG_OUTPUT}")

    set(VERILATOR_INCS "")
    set(VERILATOR_ARGS "")

    # Additional includes
    if(${ARGC} GREATER 2)
        foreach(inc ${ARGV2})
            set(VERILATOR_INCS ${VERILATOR_INCS} -I${inc})
        endforeach()
    endif()

    # Verilator additional arguments
    if(${ARGC} GREATER 3)
        set(VERILATOR_ARGS "${ARGV3}")
    endif()

    set(VERILOG_OUTPUT_SOURCES "")
    foreach(source ${verilog_sources})
        set(VERILOG_OUTPUT_SOURCES ${VERILOG_OUTPUT_SOURCES}
            ${VERILOG_OUTPUT_DIR}/${source})
    endforeach()

    add_custom_command(
        OUTPUT ${VERILOG_OUTPUT_SOURCES}
        COMMAND ${CMAKE_COMMAND} -E make_directory ${VERILOG_OUTPUT_DIR}
        COMMAND verilator ${VERILATOR_ARGS} ${VERILATOR_INCS}
            -Wall
            -Mdir ${VERILOG_OUTPUT_DIR}
            --sc ${verilog_module}.v
        COMMAND ${CMAKE_COMMAND} -E remove ${VERILOG_OUTPUT_DIR}/*.mk
        COMMAND ${CMAKE_COMMAND} -E remove ${VERILOG_OUTPUT_DIR}/*.d
        COMMAND ${CMAKE_COMMAND} -E remove ${VERILOG_OUTPUT_DIR}/*.dat
        MAIN_DEPENDENCY ${verilog_module}.v
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        COMMENT "Generating SystemC module ${verilog_module}"
    )

    add_library(V${verilog_module} STATIC ${VERILOG_OUTPUT_SOURCES})
endmacro()
