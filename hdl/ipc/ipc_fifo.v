/*!
 * @copyright Copyright (c) 2014, Tymoteusz Blazejczyk - www.tymonx.com
 * All rights reserved.
 *
 * @license Redistribution and use in source and binary forms, with or without
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

module ipc_fifo(
    input clk_i,
    input reset_i,
    input write_i,
    input [DATA_WIDTH-1:0] data_in,
    input read_i,
    output reg [DATA_WIDTH-1:0] data_out,
    output reg ready_o,
    output reg overflow_o,
    output full_o,
    output empty_o,
    output [ADDR_WIDTH-1:0] data_count_out
);

    parameter CAPACITY = 256;
    parameter DATA_INIT = 0;
    parameter DATA_WIDTH = 8;
    parameter ADDR_WIDTH = $clog2(CAPACITY);

    localparam MEMORY_SIZE = 2**ADDR_WIDTH;
    localparam [ADDR_WIDTH-1:0] DATA_COUNT_INC = 1;
    localparam [ADDR_WIDTH-1:0] WRITE_INC = 1;
    localparam [ADDR_WIDTH-1:0] READ_INC = 1;

    reg [ADDR_WIDTH-1:0] write_pointer = 0;
    reg [ADDR_WIDTH-1:0] read_pointer = 0;
    reg [ADDR_WIDTH-1:0] data_count = 0;
    reg [DATA_WIDTH-1:0] memory[0:MEMORY_SIZE-1];

    initial begin: init
        integer i;
        for (i=0; i<MEMORY_SIZE; i=i+1) begin
            memory[i] = 0;
        end
        data_out = DATA_INIT[DATA_WIDTH-1:0];
        ready_o = 1'b0;
        overflow_o = 1'b0;
    end

    assign data_count_out = data_count;
    assign empty_o = |data_count;
    assign full_o = &data_count;

    always @(posedge clk_i) begin
        // Data output is ready and valid:
        ready_o <= read_i;
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
            data_count <= 0;
            read_pointer <= 0;
            write_pointer <= 0;
            data_out <= DATA_INIT[DATA_WIDTH-1:0];
            ready_o <= 1'b0;
            overflow_o <= 1'b0;
        end
    end

endmodule
