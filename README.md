HDL-xLibCores
=============

HDL x-library of IP Cores

External tools and libraries
----------------------------

* CMake 2.8
* Verilator 3.862
* SystemC 2.3.1
* Google C++ Testing Framework gtest-1.7.0
* Doxverilog 2.8 (patched Doxygen 1.8.5 for verilog)

Build
-----

To build all modules in Linux:

    mkdir build
    cd build
    cmake ..
    make

To clean workspace:

    make clean

Test
----

Library use unit testing and testbenches to valid correct module behavior.
Run all test on Linux after doing build step:

    make test

To run particular test e.g. on Fifo module:

    ./tests/hdl/ipc/test_ipc_fifo

Documentation
-------------

To generate documentation for verilog modules:

    doxverilog Doxverilog.cfg
