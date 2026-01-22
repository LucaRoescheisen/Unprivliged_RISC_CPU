module regfile(
  input clk,
  input[3:0] rs1,
  input[3:0] rs2,
  input[3:0] rd,
  input[31:0] result,
  input reg_write,
  output  [31:0] rs1_val,
  output  [31:0] rs2_val
);
/*
x1 : Return Address Register
x2 : Standard Stack Pointer
x5 : Alternative Link Register (some programs use this instead of x1)


*/
localparam XLEN = 32;

reg [XLEN-1:0] int_regs [0:32];         //x0 to x32

always @(posedge clk) int_regs[0] <= 0; //Forces x0 to be always 0

assign rs1_val = int_regs[rs1];
assign rs2_val = int_regs[rs2];


always @(posedge clk) begin
  if (reg_write) begin
    int_regs[rd] <= result;

  end

end

endmodule