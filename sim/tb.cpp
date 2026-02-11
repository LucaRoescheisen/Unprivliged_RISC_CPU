#include "Vtop_verilator.h"
#include "verilated.h"
#include <iostream>



int main(int argc, char **argv) {
  Verilated::commandArgs(argc, argv);
  Vtop_verilator* dut = new Vtop_verilator;
  dut->clk = 0;
  dut->reset = 1;
      for (int i = 0; i < 10; i++) {  // simulate 10 cycles
        dut->clk = !dut->clk;        // toggle clock
        dut->eval();                 // evaluate DUT

        if (i == 1) dut->reset = 0;  // deassert reset after first half-cycle

        std::cout << "Cycle " << i << ", clk=" << (int)dut->clk << ", pc=" << (int)dut->pc_out << std::endl;
    }

  delete dut;
  return 0;

}