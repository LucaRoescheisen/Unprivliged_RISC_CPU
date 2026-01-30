module regfile(
  input clk,
  input[3:0] rs1,
  input[3:0] rs2,
  input[4:0] rd,
  input[31:0] result,
  input reg_write,
  output  [31:0] rs1_val,
  output  [31:0] rs2_val
);
/*
x1 : Return Address Register never write to THIS!!!!!
x2 : Standard Stack Pointer
x5 : Alternative Link Register (some programs use this instead of x1)


*/

localparam XLEN = 32;

(* dont_touch = "true" *) reg [XLEN-1:0] int_regs [0:32];         //x0 to x32
integer i;
initial begin
    for (i = 0; i < 32; i = i + 1) begin
        int_regs[i] = 32'b0;
    end
end

assign rs1_val = int_regs[rs1];
assign rs2_val = int_regs[rs2];


always @(posedge clk) begin
  if (reg_write && rd != 0) begin
    int_regs[rd] <= result;
  end

end

endmodule