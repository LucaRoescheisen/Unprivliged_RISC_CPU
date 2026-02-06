#include "Vtop.h"
#include "verilated.h"
#include <iostream>



int main(int argc, char **argv) {
  Verilated::commandArgs(argc, argv);
  Vtop* dut = new Vtop;
  dut->clk = 0;
  dut->reset = 1;


  delete dut;
  return 0;

}