module fetch_stage(
    input clk,
    input reset,
    input stall,
    input pc_src, //1 If Branch
    output [31:0] if_instruction,
    input [31:0] pc_target,
    output [31:0] pc_out,
    output reg [31:0] pc //Program counter (Holds address of current instruction)
);


  wire [31:0] pc_4 = pc +4;
  wire [31:0] pc_next = pc_src ? (pc_target) : pc_4;
  assign pc_out = pc_4;
  /*
  The reason why we output pc+4 is to when a jump occurs that when we jump back
  we dont jump to the same instruction (infinite loop), instead we go to the next instruciton
  */

  reg [31:0] instr [0:17];
  assign if_instruction = instr[pc >> 2];

  initial begin
    $readmemh("D:/u_risc/programs/test.hex", instr);
  end

  always @(posedge clk) begin

    if(reset) begin
      pc <= 32'h00000000;
      $display("yooo");
    end
    else begin
      if(stall) begin
       pc <= pc;
      end else begin
        pc <= pc_next;
      end
    end
  end

endmodule


module decode_stage(
  input clk,
  input [31:0] IF_ID_instr,
  input [31:0] IF_ID_pc,

  //Writeback
  input [31:0] mem_wb_result,
  input [4:0]  wb_rd,          // Which register to write to
  input [31:0] wb_result,      // The data to write
  input        wb_reg_write,   // The enable signal from WB
  input        wb_is_load_reg,
  //ID-EX Registers
  output [31:0] id_rs1_val,
  output [31:0] id_rs2_val,
  output        id_reg_write_reg,
  output [31:0] id_imm_val,
  output [4:0]  id_alu_op,
  output [4:0]  id_div_op,
  output [4:0]  id_rd_addr,
  output [4:0]  id_rs1_addr,
  output [4:0]  id_rs2_addr,
  //Control Signals
  output        id_alu_src, // Determines whether to use rs2 or imm value
  output [2:0]  id_branch_type,
  output        id_is_branch,
  output        id_jal_jump,
  output        id_jalr_jump,
  output        id_decoder_illegal,
  output        id_is_load,
  output        id_is_store,
  output [2:0]  id_load_type,
  output [2:0]  id_store_type,
  output        id_div_start,
  output        id_div_instruction,
  output        id_is_lui

);
  wire [4:0] rs1_wire;
  wire [4:0] rs2_wire;
  wire [4:0] rd_wire;
  assign id_rd_addr = rd_wire;

  wire [31:0] wb_final_data = (wb_is_load_reg) ? mem_wb_result : wb_result;



  (* dont_touch = "true" *)
  decoder decoder_module(
    .instr(IF_ID_instr),
    .rd(rd_wire),
    .rs1(rs1_wire),
    .rs2(rs2_wire),
    .imm(id_imm_val),
    .alu_op(id_alu_op),
    .reg_write(id_reg_write_reg),
    .alu_src(id_alu_src),
    .b_type(id_branch_type),
    .is_branch(id_is_branch),
    .jal_jump(id_jal_jump),
    .jalr_jump(id_jalr_jump),
    .decoder_illegal(id_decoder_illegal),
    .is_load(id_is_load),
    .is_store(id_is_store),
    .load_type(id_load_type),
    .store_type(id_store_type),
    .div_op(id_div_op),
    .div_start(id_div_start),
    .is_div_instruction(id_div_instruction),
    .is_lui(id_is_lui)
  );


  (* dont_touch = "true" *)
  regfile reg_file_module(
    .clk(clk),
    .rs1(rs1_wire),
    .rs2(rs2_wire),
    .rd(wb_rd),
    .result(wb_final_data),
    .reg_write(wb_reg_write),
    .rs1_val(id_rs1_val),
    .rs2_val(id_rs2_val)
  );

endmodule



module execute_stage(
  input clk,
  input [31:0] id_pc_reg,
  input [31:0] id_pc_4_reg,
  // Data from ID/EX Registers
  input [31:0] id_rs1_val_reg,
  input [31:0] id_rs2_val_reg,
  input [31:0] id_imm_val_reg,
  // Control from ID/EX Registers
  input id_alu_src_reg,
  input id_is_branch_reg,
  input [2:0] id_branch_type_reg,
  input id_jal_jump_reg,
  input id_jalr_jump_reg,

  input [4:0] id_alu_op_reg,
  input [3:0] id_div_op_reg,
  input       id_div_instruction,

  // Outputs to EX/MEM Register
  output [31:0] ex_result,
  output        ex_jump_branch_taken,
  output [31:0] ex_pc_target,
  //Control
  output divider_busy
);

  wire [31:0] div_result, alu_result;
  wire [31:0] alu_b = id_alu_src_reg ? id_imm_val_reg : id_rs2_val_reg;
  wire [31:0] result = id_div_instruction ? div_result : alu_result;

  wire div_busy;
  assign divider_busy = div_busy;
  wire divider_trigger = id_div_instruction && !div_busy;

  wire take_branch;
  wire [31:0] target_pc_imm   = id_pc_reg + id_imm_val_reg; // For JAL and Branches
  wire [31:0] target_rs1_imm  = (id_rs1_val_reg + id_imm_val_reg) & ~32'h1; //For JALR
  assign ex_jump_branch_taken = id_jal_jump_reg || id_jalr_jump_reg || (id_is_branch_reg && take_branch);
  assign ex_pc_target = (id_jalr_jump_reg) ? target_rs1_imm : target_pc_imm;

  //Result Handling
  assign ex_result = (id_jal_jump_reg || id_jalr_jump_reg) ? id_pc_4_reg: result;

wire [31:0] forward_val_a;
wire [31:0] forward_val_b;


  (* dont_touch = "true" *)
  alu alu_module(
    .a(id_rs1_val_reg),
    .b(alu_b),
    .alu_op(id_alu_op_reg),
    .result(alu_result)
  );


  (* dont_touch = "true" *)
    divider divider_module(
    .clk(clk),
    .divisor(id_rs1_val_reg),
    .dividend(id_rs2_val_reg),
    .start(divider_trigger),
    .div_op(id_div_op_reg),
    .result(div_result),
    .busy(div_busy)
  );


  (* dont_touch = "true" *)
  branch_unit branch_unit_module(
    .is_branch(id_is_branch_reg),
    .b_type(id_branch_type_reg),
    .rs1_val(id_rs1_val_reg),
    .rs2_val(id_rs2_val_reg),
    .take_branch(take_branch)
  );

endmodule




