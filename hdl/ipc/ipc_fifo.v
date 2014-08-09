/*!
 * @copyright Copyright (c) 2014, Tymoteusz Blazejczyk - www.tymonx.com
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * * Redistributions of source code must retain the above copyright notice, this
 *   list of conditions and the following disclaimer.
 *
 * * Redistributions in binary form must reproduce the above copyright notice,
 *   this list of conditions and the following disclaimer in the documentation
 *   and/or other materials provided with the distribution.
 *
 * * Neither the name of hdl-xlibcores nor the names of its
 *   contributors may be used to endorse or promote products derived from
 *   this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/*!
 * @note Source linted by Verilator 3.862
 * @note Source documented by Doxverilog 2.8
 *
 * @brief
 * IPC FIFO module
 */
module ipc_fifo(
    //% Main clock
    input clk_i,
    //% Synchronous reset data count, data output and status flags
    input reset_i,
    //% Strobe used to write data
    input write_i,
    //% Data to be written
    input [DATA_WIDTH-1:0] data_in,
    //% Strobe used to read data
    input read_i,
    //% Data that is read. Output is registered. Monitor valid_o after read
    output reg [DATA_WIDTH-1:0] data_out,
    //% When data output is valid
    output reg valid_o,
    //% When trying to write data when FIFO was full. Deassigned after reset
    output reg overflow_o,
    //% When FIFO reach maximum capacity. Write operation will be blocked
    output full_o,
    //% When FIFO has no data. Read operation will be blocked
    output empty_o,
    //% Actual data count in FIFO. 0 means that FIFO is empty
    output [ADDR_WIDTH-1:0] data_count_out
);

    //% Expected capacity. Value rounded to the nearest power of two
    parameter CAPACITY = 256;
    //% Data output value after reset state
    parameter DATA_INIT = 0;
    //% Data input/output width
    parameter DATA_WIDTH = 8;
    //% Memory capacity calculated using address bus width
    parameter ADDR_WIDTH = $clog2(CAPACITY);

    //% Memory size based on bus address width
    localparam MEMORY_SIZE = 2**ADDR_WIDTH;
    //% Data counter that will be incremented by this value
    localparam [ADDR_WIDTH-1:0] DATA_COUNT_INC = 1;
    //% Write pointer that will be incremented by this value
    localparam [ADDR_WIDTH-1:0] WRITE_INC = 1;
    //% Read pointer that will be incremented by this value
    localparam [ADDR_WIDTH-1:0] READ_INC = 1;

    //% Write pointer that indicates memory location where data will be saved
    reg [ADDR_WIDTH-1:0] write_pointer = 0;
    //% Read pointer that indicates memory location where data will be read
    reg [ADDR_WIDTH-1:0] read_pointer = 0;
    //% Actual data count
    reg [ADDR_WIDTH-1:0] data_count = 0;
    //% Main memory for inter process communication that contains data
    reg [DATA_WIDTH-1:0] memory[0:MEMORY_SIZE-1];

    initial begin: init
        //% Temporary value used for initialization loops
        integer i;
        for (i=0; i<MEMORY_SIZE; i=i+1) begin
            memory[i] = 0;
        end
        data_out = DATA_INIT[DATA_WIDTH-1:0];
        valid_o = 1'b0;
        overflow_o = 1'b0;
    end

    assign data_count_out = data_count;
    assign empty_o = |data_count;
    assign full_o = &data_count;

    /*!
     * @brief Main FIFO process
     */
    always @(posedge clk_i) begin: fifo
        // Data output is valid after successful read:
        valid_o <= 1'b0;
        // Detect overflow:
        if (write_i && full_o) begin
            overflow_o <= 1'b1;
        end
        // Write data to FIFO:
        if (write_i && !full_o) begin
            memory[write_pointer] <= data_in;
            write_pointer <= write_pointer + WRITE_INC;
        end
        // Read data from FIFO:
        if (read_i && !empty_o) begin
            valid_o <= 1'b1;
            data_out <= memory[read_pointer];
            read_pointer <= read_pointer + READ_INC;
        end
        // Monitoring data count in FIFO:
        if (write_i && !read_i && !full_o) begin
            data_count <= data_count + DATA_COUNT_INC;
        end
        else if (read_i && !write_i && !empty_o) begin
            data_count <= data_count - DATA_COUNT_INC;
        end
        else begin
            data_count <= data_count;
        end
        // Reset:
        if (reset_i) begin
            valid_o <= 1'b0;
            data_out <= DATA_INIT[DATA_WIDTH-1:0];
            data_count <= 0;
            read_pointer <= 0;
            write_pointer <= 0;
            overflow_o <= 1'b0;
        end
    end

endmodule
