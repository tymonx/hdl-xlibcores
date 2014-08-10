HDL-xLibCores
=============

HDL x-library of IP Cores

External tools and libraries
----------------------------

* CMake 2.8
* Verilator
* Systemc 2.3.x
* Doxverilog 1.8 (patched Doxygen 1.8.5 for verilog)

Build
-----

To build all modules in Linux:

    mkdir build
    cd build
    cmake ..
    make

To clean workspace:

    make clean

Documentation
-------------

To generate documentation for verilog modules:

    doxverilog Doxverilog.cfg
