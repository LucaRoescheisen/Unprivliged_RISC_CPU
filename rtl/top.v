module top(
  input clk,
  input reset
);
  //Hazards
  wire stall;
  wire flush;
  //IFID Pipline Registers
  reg [31:0] IF_ID_instr;
  reg [31:0] IF_ID_pc_plus_4;
  reg [31:0] IF_ID_pc;

  //Fetch Wires
  wire [31:0] IF_ID_instr_wire;
  wire pc_src;           //Branches
  wire [31:0] pc_target; //Jump target
  wire [31:0] pc_out_wire;    //Next PC value
  wire [31:0] IF_ID_wire;    //Current PC value


  //**     Fetch Stage     **//
  fetch_stage fetch_stage_mod(
    .clk(clk),
    .reset(reset),
    .stall(stall),
    .flush(flush),
    .pc_src(pc_src),
    .if_instruction(IF_ID_instr_wire),
    .pc_target(pc_target),
    .pc_out(pc_out_wire),
    .pc(IF_ID_wire)
  );

  always @(posedge clk) begin //Handle flush and stalling
    if(flush || reset) begin
      IF_ID_instr <= 32'b0;
      IF_ID_pc_plus_4 <= 32'b0;
      IF_ID_pc <= 32'b0;
    end else begin
      if(stall) begin
        IF_ID_instr <= IF_ID_instr;
        IF_ID_pc_plus_4 <= IF_ID_pc_plus_4;
        IF_ID_pc <= IF_ID_pc;
      end else begin
        IF_ID_instr <= IF_ID_instr_wire;
        IF_ID_pc_plus_4 <= pc_out_wire;
        IF_ID_pc <= IF_ID_wire;
      end
    end
  end
  //**-----------------------**//


  //Decode Registers
  //Writeback
  reg [4:0]  mem_wb_rd_reg;
  reg [4:0] ram_wb_rd_reg;
  reg [31:0]  mem_wb_result_reg;
  reg        mem_wb_write_reg;
  reg [31:0] mem_data_out_reg;
  reg        mem_wb_is_load_reg;
  //ID-EX Registers
  reg [4:0]  id_rs1_addr_reg;
  reg [4:0]  id_rs2_addr_reg;

  reg [31:0] id_ex_pc_reg_plus_4_reg;
  reg [31:0] id_ex_pc_reg;
  reg [31:0] id_ex_rs1_val_reg;
  reg [31:0] id_ex_rs2_val_reg;
  reg        id_ex_reg_write_reg;
  reg [31:0] id_ex_imm_val_reg;
  reg [4:0]  id_ex_alu_op_reg;
  reg [3:0]  id_ex_div_op_reg;
  reg [4:0]  id_ex_rd_addr_reg;
  reg        id_ex_alu_src_reg;
  reg [2:0]  id_ex_branch_type_reg;
  reg        id_ex_is_branch_reg;
  reg        id_ex_jal_jump_reg;
  reg        id_ex_jalr_jump_reg;
  reg        id_ex_decoder_illegal_reg;
  reg        id_ex_is_load_reg;
  reg        id_ex_is_store_reg;
  reg [2:0]  id_ex_load_type_reg;
  reg [2:0]  id_ex_store_type_reg;
  reg        id_ex_div_start_reg;
  reg        id_ex_div_instruction_reg;
  reg        id_ex_is_lui_reg;
  //ID-EX Wires
  wire [4:0]  id_rs1_addr_w;
  wire [4:0]  id_rs2_addr_w;
  wire [31:0] id_rs1_val_w;
  wire [31:0] id_rs2_val_w;
  wire        id_reg_write_w;
  wire [31:0] id_imm_val_w;
  wire [3:0]  id_alu_op_w;
  wire [3:0]  id_div_op_w;
  wire [4:0]  id_rd_addr_w;
  wire        id_alu_src_w;
  wire [2:0]  id_branch_type_w;
  wire        id_is_branch_w;
  wire        id_jal_jump_w;
  wire        id_jalr_jump_w;
  wire        id_decoder_illegal_w;
  wire        id_is_load_w;
  wire        id_is_store_w;
  wire [2:0]  id_load_type_w;
  wire [2:0]  id_store_type_w;
  wire        id_div_start_w;
  wire        id_div_instruction_w;
  wire        id_is_lui_w;

  //**     Decode Stage     **//
  decode_stage decode_stage_mod(
    .clk(clk),
    .IF_ID_instr(IF_ID_instr),
    .IF_ID_pc(IF_ID_pc_plus_4),
    .mem_wb_result(mem_data_out_w),
    .wb_rd(mem_wb_rd_reg),
    .ram_rd_reg(ram_wb_rd_reg),
    .wb_result(mem_wb_result_reg),
    .wb_reg_write(mem_wb_write_reg),
    .wb_is_load_reg(mem_wb_is_load_reg),
    .id_rs1_val(id_rs1_val_w),
    .id_rs2_val(id_rs2_val_w),
    .id_reg_write_reg(id_reg_write_w),
    .id_imm_val(id_imm_val_w),
    .id_alu_op(id_alu_op_w),
    .id_div_op(id_div_op_w),
    .id_rd_addr(id_rd_addr_w),
    .id_rs1_addr(id_rs1_addr_w),
    .id_rs2_addr(id_rs2_addr_w),
    .id_alu_src(id_alu_src_w),
    .id_branch_type(id_branch_type_w),
    .id_is_branch(id_is_branch_w),
    .id_jal_jump(id_jal_jump_w),
    .id_jalr_jump(id_jalr_jump_w),
    .id_decoder_illegal(id_decoder_illegal_w),
    .id_is_load(id_is_load_w),
    .id_is_store(id_is_store_w),
    .id_load_type(id_load_type_w),
    .id_store_type(id_store_type_w),
    .id_div_start(id_div_start_w),
    .id_div_instruction(id_div_instruction_w),
    .id_is_lui(id_is_lui_w)
  );

  always @(posedge clk) begin
    if(reset || flush) begin
      id_ex_reg_write_reg <= 0;
      id_ex_is_load_reg <= 0;
      id_ex_is_store_reg <= 0;
      id_ex_is_branch_reg <= 0;
      id_ex_div_start_reg<= 0;
      id_ex_jal_jump_reg  <= 0;
      id_ex_jalr_jump_reg <= 0;
      id_ex_div_instruction_reg <= 0;
    end
    else if(!stall) begin
      id_ex_pc_reg_plus_4_reg <= IF_ID_pc_plus_4;
      id_ex_pc_reg <= IF_ID_pc;
      id_ex_rs1_val_reg <=id_rs1_val_w;
      id_ex_rs2_val_reg <= id_rs2_val_w;
      id_ex_reg_write_reg <= id_reg_write_w;
      id_ex_imm_val_reg <= id_imm_val_w;
      id_ex_alu_op_reg <= id_alu_op_w;
      id_ex_div_op_reg <= id_div_op_w;
      id_ex_rd_addr_reg <= id_rd_addr_w;
      id_ex_alu_src_reg <= id_alu_src_w;
      id_ex_branch_type_reg <= id_branch_type_w;
      id_ex_is_branch_reg <= id_is_branch_w;
      id_ex_jal_jump_reg <= id_jal_jump_w;
      id_ex_jalr_jump_reg <= id_jalr_jump_w;
      id_ex_decoder_illegal_reg <= id_decoder_illegal_w;
      id_ex_is_load_reg <= id_is_load_w;
      id_ex_is_store_reg <= id_is_store_w;
      id_ex_load_type_reg <= id_load_type_w;
      id_ex_store_type_reg <= id_store_type_w;
      id_ex_div_start_reg <= id_div_start_w;
      id_ex_div_instruction_reg <= id_div_instruction_w;
      id_ex_is_lui_reg <= id_is_lui_w;
      id_rs1_addr_reg <=id_rs1_addr_w;
      id_rs2_addr_reg <=id_rs2_addr_w;
    end

  end
   //**-----------------------**//


  //Execute Registers
  //Writeback

  //EX-MEM Registers
  reg [31:0] ex_mem_result_reg;
  reg [4:0] ex_mem_rd_addr_reg;
  reg ex_mem_reg_write_reg;
  reg ex_mem_is_load_reg;
  reg ex_mem_is_store_reg;
  reg [2:0] ex_mem_load_type_reg;
  reg [2:0] ex_mem_store_type_reg;
  reg [31:0] ex_mem_rs2_val_reg;
  reg [31:0] ex_mem_ram_address_reg;

  //EX-MEM Wires
  wire [31:0] id_ex_result_w;
  wire [31:0] ex_id_pc_target_w;
  wire div_busy_w;
  wire [31:0] ex_ram_address_w;
 //**     Execute Stage     **//
  execute_stage execute_stage_module(
    .clk(clk),
    .reset(reset),
    .id_pc_reg(id_ex_pc_reg),              // Matches your reg name
    .id_pc_4_reg(id_ex_pc_reg_plus_4_reg),     // Matches your reg name
    .id_rs1_val_reg(id_ex_rs1_val_reg),
    .id_rs2_val_reg(id_ex_rs2_val_reg),
    .id_imm_val_reg(id_ex_imm_val_reg),
    .id_alu_src_reg(id_ex_alu_src_reg),
    .id_is_branch_reg(id_ex_is_branch_reg),
    .id_branch_type_reg(id_ex_branch_type_reg),
    .id_jal_jump_reg(id_ex_jal_jump_reg),
    .id_jalr_jump_reg(id_ex_jalr_jump_reg),
    .id_alu_op_reg(id_ex_alu_op_reg),
    .id_div_op_reg(id_ex_div_op_reg),
    .id_div_instruction(id_ex_div_instruction_reg),
    .ex_mem_reg_write_reg(ex_mem_reg_write_reg),
    .ex_mem_rd(ex_mem_rd_addr_reg),
    .mem_wb_rd(mem_wb_rd_reg),
    .id_rs1_addr(id_rs1_addr_reg),
    .id_rs2_addr(id_rs2_addr_reg),
    .ex_mem_result_reg(ex_mem_result_reg),
    .mem_wb_result_reg(mem_wb_result_reg),
    .mem_wb_write_reg(mem_wb_write_reg),
    .ex_result(id_ex_result_w),
    .flush(flush),
    .ex_pc_target(pc_target),      // Feed this back to fetch!
    .ex_ram_address(ex_ram_address_w),
    .divider_busy(div_busy_w)

);
assign pc_src = flush;

 always @(posedge clk) begin
    if(reset) begin
        ex_mem_reg_write_reg <= 0;
        ex_mem_is_store_reg  <= 0;
        ex_mem_is_load_reg   <= 0;
        ex_mem_rd_addr_reg <= 0;
        ex_mem_result_reg <= 0;
    end
    else if(!stall) begin
      ex_mem_result_reg <= id_ex_result_w;
      ex_mem_rd_addr_reg  <= id_ex_rd_addr_reg; // Pass the destination forward
      ex_mem_reg_write_reg <= id_ex_reg_write_reg;
      ex_mem_is_store_reg  <= id_ex_is_store_reg;
      ex_mem_is_load_reg   <= id_ex_is_load_reg;
      ex_mem_load_type_reg <= id_ex_load_type_reg;
      ex_mem_store_type_reg <= id_ex_store_type_reg;
      ex_mem_rs2_val_reg <=  id_ex_rs2_val_reg;
      ex_mem_ram_address_reg <= ex_ram_address_w;
    end

 end

    //**-----------------------**//

  wire mem_busy_w;
  wire [31:0] mem_data_out_w;
  reg [4:0] d_mem_wb_rd_reg;
  reg [31:0] d_mem_wb_result_reg;
  reg d_mem_wb_write_reg;
  reg d_mem_wb_is_load_reg;
  reg [31:0] d_mem_data_out_reg;
   //**     Memory Stage/Writeback     **//
  data_memory ram_unit (
    .clk(clk),
    .load_type(ex_mem_load_type_reg),
    .store_type(ex_mem_store_type_reg),
    .mem_read_en(ex_mem_is_load_reg),
    .mem_write_en(ex_mem_is_store_reg),
    .ram_address(ex_mem_ram_address_reg),
    .data_in(ex_mem_rs2_val_reg),
    .data_out(mem_data_out_w),
    .mem_busy(mem_busy_w)
);

assign stall = div_busy_w; //SETS STALL

 always @(posedge clk) begin
    if(reset) begin
        mem_wb_rd_reg      <= 0;
        mem_wb_result_reg  <= 0;
        mem_wb_write_reg   <= 0;
        mem_data_out_reg   <= 0;
        mem_wb_is_load_reg <= 0;
        // Clean up the old delay regs


    end
    else if(!stall) begin

        mem_wb_rd_reg      <= ex_mem_rd_addr_reg;  // The destination
        mem_wb_result_reg  <= ex_mem_result_reg;   // The ALU result
        mem_wb_write_reg   <= ex_mem_reg_write_reg;
        mem_wb_is_load_reg <= ex_mem_is_load_reg;  // The Mux selector
        mem_data_out_reg   <= mem_data_out_w;
    end
end

  //**-----------------------**//



endmodule