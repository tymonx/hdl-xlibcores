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
#include <gtest/gtest.h>

#define TEST_DATA_COUNT     10

Vipc_fifo fifo("fifo");

sc_clock fifo_clk("clock");
sc_signal<bool> fifo_reset;
sc_signal<bool> fifo_write;
sc_signal<bool> fifo_read;
sc_signal<bool> fifo_valid;
sc_signal<bool> fifo_empty;
sc_signal<bool> fifo_full;
sc_signal<bool> fifo_overflow;
sc_signal<std::uint32_t> fifo_data_in;
sc_signal<std::uint32_t> fifo_data_out;
sc_signal<std::uint32_t> fifo_data_count;

class FifoTest : public ::testing::Test {
    protected:
        FifoTest() {}
        virtual ~FifoTest() {}
        virtual void SetUp() {
            fifo_write = 0;
            fifo_read = 0;
            fifo_data_in = 0;

            fifo_reset = 1;
            sc_start(1, SC_NS);
            fifo_reset = 0;
        }
        virtual void TearDown() {}
};

TEST_F(FifoTest, InitAfterReset)  {
    EXPECT_TRUE(fifo_empty);
    EXPECT_FALSE(fifo_full);
    EXPECT_FALSE(fifo_overflow);
    EXPECT_EQ(0, fifo_data_out);
}

TEST_F(FifoTest, DataCount) {
    EXPECT_EQ(0, fifo_data_count);

    for (size_t i = 0; i < TEST_DATA_COUNT; i++) {
        fifo_write = 1;
        fifo_data_in = 1;
        sc_start(1, SC_NS);

        EXPECT_EQ(i, fifo_data_count);

        fifo_write = 0;
        fifo_data_in = 0;
        sc_start(1, SC_NS);

        EXPECT_EQ(i+1, fifo_data_count);
    }

    EXPECT_EQ(TEST_DATA_COUNT, fifo_data_count);
}

int sc_main(int argc, char* argv[]) {
    /* Binding signals to SystemC module */
    fifo.clk_i(fifo_clk);
    fifo.reset_i(fifo_reset);
    fifo.valid_o(fifo_valid);
    fifo.write_i(fifo_write);
    fifo.read_i(fifo_read);
    fifo.data_in(fifo_data_in);
    fifo.data_out(fifo_data_out);
    fifo.empty_o(fifo_empty);
    fifo.full_o(fifo_full);
    fifo.overflow_o(fifo_overflow);
    fifo.data_count_out(fifo_data_count);

    /* Run unit tests */
    ::testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}
