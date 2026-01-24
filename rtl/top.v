module top(
  input clk
);
  (* dont_touch = "true" *) reg [31:0] pc = 0; //Program counter (Holds address of current instruction)

  reg [31:0] instr [0:17];
  wire [31:0] current_instr;

  wire [3:0] rs1, rs2, rd;
  wire [31:0] rs1_val, rs2_val;
  wire[31:0] imm;
  wire[31:0] alu_result;
  wire reg_write;
  wire [31:0] pc_jump;
  wire [4:0] alu_op;
  wire take_branch;
  wire is_branch;

  wire [31:0] pc_4 = pc +4;
  wire [31:0] pc_imm = pc + imm;
  wire [31:0] jalr_target = (rs1_val + imm) & ~1;// Forces bit alignment by settings 1's to 0
  wire jal_jump;
  wire jalr_jump;
  wire [31:0] pc_branch = take_branch ? (pc_imm) : pc_4;
  wire [31:0] pc_next = (jalr_jump) ? jalr_target : (jal_jump || take_branch) ? pc_imm : pc_4;

  wire [31:0] reg_write_data;
  assign reg_write_data = (jal_jump || jalr_jump) ? (pc + 4) : alu_result;

  initial begin
    $readmemh("D:/u_risc/programs/test.hex", instr);
  end


  assign current_instr = instr[pc >> 2];  //Fetch current instruction
  always @(posedge clk) begin
    pc <= pc_next;//Increment program counter, by 4 bytes ass each instruction is 32-bit
  end

  (* dont_touch = "true" *)
  regfile reg_file_module(
    .clk(clk),
    .rs1(rs1),
    .rs2(rs2),
    .rd(rd),
    .result(reg_write_data),
    .reg_write(reg_write),
    .rs1_val(rs1_val),
    .rs2_val(rs2_val)
  );

  wire alu_src;
  wire [2:0] b_type;
  (* dont_touch = "true" *)
  decoder decoder_module(
    .instr(current_instr),
    .rd(rd),
    .rs1(rs1),
    .rs2(rs2),
    .imm(imm),
    .alu_op(alu_op),
    .reg_write(reg_write),
    .alu_src(alu_src),
    .b_type(b_type),
    .is_branch(is_branch),
    .jal_jump(jal_jump),
    .jalr_jump(jalr_jump)
  );


  wire [31:0] alu_b = alu_src ? imm : rs2_val;
  (* dont_touch = "true" *)
  alu alu_module(
    .a(rs1_val),
    .b(alu_b),
    .alu_op(alu_op),
    .result(alu_result)
  );

  (* dont_touch = "true" *)
  branch_unit branch_unit_module(
    .is_branch(is_branch),
    .b_type(b_type),
    .rs1_val(rs1_val),
    .rs2_val(rs2_val),
    .take_branch(take_branch)
  );


endmodule