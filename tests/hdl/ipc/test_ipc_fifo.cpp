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
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

#include "hdl/ipc/Vipc_fifo.h"

#include <systemc>
#include <cstdint>
#include <CppUTest/Utest.h>
#include <CppUTest/UtestMacros.h>
#include <CppUTest/CommandLineTestRunner.h>

#define TEST_DATA_COUNT     10

double sc_time_stamp() {
    return 0;
}

TEST_GROUP(FifoTestGroup) {

};

TEST(FifoTestGroup, DataCount) {
    Vipc_fifo fifo("fifo");

    sc_clock clk("clock");
    sc_signal<bool> reset;
    sc_signal<bool> write;
    sc_signal<bool> read;
    sc_signal<bool> valid;
    sc_signal<bool> empty;
    sc_signal<bool> full;
    sc_signal<bool> overflow;
    sc_signal<std::uint32_t> data_in;
    sc_signal<std::uint32_t> data_out;
    sc_signal<std::uint32_t> data_count;

    fifo.clk_i(clk);
    fifo.reset_i(reset);
    fifo.valid_o(valid);
    fifo.write_i(write);
    fifo.read_i(read);
    fifo.data_in(data_in);
    fifo.data_out(data_out);
    fifo.empty_o(empty);
    fifo.full_o(full);
    fifo.overflow_o(overflow);
    fifo.data_count_out(data_count);

    sc_start(5, SC_NS);

    for (size_t i = 0; i < TEST_DATA_COUNT; i++) {
        write = 1;
        data_in = 1;
        sc_start(1, SC_NS);

        write = 0;
        data_in = 0;
        sc_start(1, SC_NS);
    }

    CHECK_EQUAL(TEST_DATA_COUNT, data_count);
}

int sc_main(int argc, char* argv[]) {
    MemoryLeakWarningPlugin::turnOffNewDeleteOverloads();
    return CommandLineTestRunner::RunAllTests(argc, argv);
}

int main(int argc, char* argv[]) {
    return sc_main(argc, argv);
}
