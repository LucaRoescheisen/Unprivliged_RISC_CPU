module top(
  input clk,
  input reset
);
  (* dont_touch = "true" *) reg [31:0] pc = 0; //Program counter (Holds address of current instruction)

  reg [31:0] instr [0:17];
  wire [31:0] current_instr;
  reg [31:0] IR;

  wire [3:0] rs1, rs2, rd;
  wire [31:0] rs1_val, rs2_val;
  wire[31:0] imm;
  wire[31:0] alu_result;
  reg[31:0] alu_output_reg;
  wire reg_write;
  wire [31:0] pc_jump;
  wire [4:0] alu_op;
  wire take_branch;
  wire is_branch;

  //PC Handling
  wire [31:0] pc_4 = pc +4;
  wire [31:0] pc_imm = pc + imm;
  wire [31:0] jalr_target = (rs1_val + imm) & ~1;// Forces bit alignment by settings 1's to 0
  wire jal_jump;
  wire jalr_jump;
  wire [31:0] pc_branch = take_branch ? (pc_imm) : pc_4;
  wire [31:0] pc_next = (jalr_jump) ? jalr_target : (jal_jump || take_branch) ? pc_imm : pc_4;

  //Result Handling
  wire [31:0] reg_write_data;
  assign reg_write_data = (jal_jump || jalr_jump) ? (pc + 4) : alu_output_reg; //OR alu_result

  //FSM CONTROLS
  wire [2:0] state; //FSM current state
  wire mem_busy;
  wire div_busy;
  wire is_load_store;
  wire decoder_illegal;


localparam FETCH      = 3'b000,
           DECODE     = 3'b001,
           EXECUTE    = 3'b010,
           WRITE_BACK = 3'b011, //when saved to regfile
           MEM_WAIT   = 3'b100,
           TRAP       = 3'b101;


  initial begin
    $readmemh("D:/u_risc/programs/test.hex", instr);
  end


  assign current_instr = instr[pc >> 2];  //Fetch current instruction
  always @(posedge clk) begin
    if(state ==FETCH) begin
      IR <= current_instr;
    end
  end

  always @(posedge clk) begin //Update PC
    if(state == WRITE_BACK)
      pc <= pc_next;//Increment program counter, by 4 bytes ass each instruction is 32-bit
  end

  always @(posedge clk) begin
    if (state == EXECUTE) begin
      alu_output_reg <= alu_result;
    end
  end
  wire is_load, is_store;
  wire mem_read_en = (state ==EXECUTE || state == MEM_WAIT) && is_load;
  wire mem_write_en = (state ==EXECUTE || state == MEM_WAIT) && is_store;
  assign is_load_store = mem_read_en || mem_write_en;

  wire [31:0] ram_address_store;
  wire [31:0] ram_data_in;
  wire [31:0] ram_data_out;
  wire [2:0 ] load_type;
  wire [2:0 ] store_type;
  wire [31:0] ram_address_load;
  assign ram_address_store = rs1_val + imm;
  assign ram_data_in = rs2_val;
  (* dont_touch = "true" *)
  data_memory data_memory_module(
    .clk(clk),
    .load_type(load_type),
    .store_type(store_type),
    .mem_read_en(mem_read_en),
    .mem_write_en(mem_write_en),
    .ram_address_store(ram_address_store),
    .ram_address_load(ram_address_load),
    .data_in(ram_data_in),
    .data_out(ram_data_out),
    .mem_busy(mem_busy)
  );


  (* dont_touch = "true" *)
  regfile reg_file_module(
    .clk(clk),
    .rs1(rs1),
    .rs2(rs2),
    .rd(rd),
    .result(reg_write_data),
    .reg_write(reg_write),
    .state(state),
    .rs1_val(rs1_val),
    .rs2_val(rs2_val)
  );

  wire alu_src;
  wire [2:0] b_type;
  (* dont_touch = "true" *)
  decoder decoder_module(
    .instr(IR),
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
    .jalr_jump(jalr_jump),
    .decoder_illegal(decoder_illegal),
    .is_load(is_load),
    .is_store(is_store),
    .load_type(load_type),
    .store_type(store_type)
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



  (* dont_touch = "true" *)
  fsm fsm_module(
    .clk(clk),
    .reset(reset),
    .decoder_illegal(decoder_illegal),
    .div_busy(div_busy),
    .mem_busy(mem_busy),
    .is_load_store(is_load_store),
    .state(state)
  );


endmodule