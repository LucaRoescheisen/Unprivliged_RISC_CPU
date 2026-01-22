module top(
  input clk
);
  reg [31:0] pc = 0; //Program counter (Holds address of current instruction)
  reg [31:0] instr [0:17];
  reg [31:0] current_instr;

  wire [3:0] rs1, rs2, rd;
  wire [31:0] rs1_val, rs2_val;
  wire[31:0] imm;
  wire[31:0] result;
  wire reg_write;
  wire [31:0] pc_jump
  wire [4:0] alu_op;
  wire take_branch;
  initial begin
    $readmemh("D:/u_risc/programs/test.hex", instr);
  end

  always @(posedge clk) begin
    current_instr <= instr[pc >> 2];  //Fetch current instruction
    pc <= take_branch ? (pc + imm) : (pc + 4); //Increment program counter, by 4 bytes ass each instruction is 32-bit
  end

  regfile reg_file_module(
    .clk(clk),
    .rs1(rs1),
    .rs2(rs2),
    .rd(rd),
    .result(result),
    .reg_write(reg_write),
    .rs1_val(rs1_val),
    .rs2_val(rs2_val)
  );

  wire alu_src;
  wire [2:0] b_type;
  decoder decoder_module(
    .instr(current_instr),
    .rd(rd),
    .rs1(rs1),
    .rs2(rs2),
    .imm(imm),
    .alu_op(alu_op),
    .reg_write(reg_write),
    .alu_src(alu_src),
    .b_type.(b_type)
  );


  wire [31:0] alu_b = alu_src ? imm : rs2_val;
  alu alu_module(
    .a(rs1_val),
    .b(alu_b),
    .alu_op(alu_op),
    .result(result)
  );

  branch_unit branch_unit_module(
    .b_type(b_type),
    .imm(imm),
    .rs1_val(rs1_val),
    .rs2_val(rs2_val),
    .take_branch(take_branch)
  );


endmodule