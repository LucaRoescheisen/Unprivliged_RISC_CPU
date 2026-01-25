module decoder(
  input [31:0] instr,
  output reg [3:0] rd,
  output reg [3:0] rs1,
  output reg [3:0] rs2,
  output reg [31:0] imm,
  output reg [4:0] alu_op,
  output reg reg_write,
  output reg alu_src,
  output reg [2:0] b_type,
  output reg is_branch,
  output reg jal_jump,
  output reg jalr_jump,
  output reg decoder_illegal,
  output reg is_load,
   output reg is_store
);

  initial begin
    jal_jump = 0;
    jalr_jump = 0;
  end

  //Check Type:
always @(*) begin //Anytime the input signal changes
  rd = 0; rs1 = 0; rs2 = 0; imm = 0;        //Prevent latches
  alu_op = 0; reg_write = 0; is_branch = 0;
  alu_src = 0; b_type = 0; jalr_jump = 0;
  jal_jump = 0;



  case(instr[6:0])     //Identify OP code
    7'b0110011: begin //ALU R-Type
      rd  = instr[11:7];
      rs1 = instr[19:15];
      rs2 = instr[24:20];
      reg_write = 1;
    end
    7'b0010011: begin  //ALU I-Type
      rd  = instr[11:7];
      rs1 = instr[19:15];
      imm = {{20{instr[31]}}, instr[31:20]};
      reg_write = 1;
    end
    7'b1100011: begin  //ALU B-Type
      rs1 = instr[19:15];
      rs2 = instr[24:20];
      imm = { {20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0 }; //Add 1'b0 to shift right (2x's jump value)
      reg_write = 0;
      is_branch = 1;
    end
    7'b1101111: begin  //J-Type format : JAL
      rd = instr[11:7];
      imm = { {11{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0 };
      jal_jump = 1'b1;
      reg_write = 1;
    end

    7'b1100111: begin // I-Type format : JALR
      rd = instr[11:7];
      rs1 = instr[19:15];
      imm = {{20{instr[31]}}, instr[31:20]};
      jalr_jump = 1'b1;
      reg_write = 1;
    end

    7'b0000011: begin // I-type : LOAD
      is_load = 1'b0;

    end

    7'b0100011 begin //S-Type : STORE
      is_store = 1'b0;
    end

    default begin
      is_load = 1'b0;
      is_store = 1'b0;
      reg_write = 1'b0;
      is_branch = 1'b0;
      jal_jump  = 1'b0;
      jalr_jump = 1'b0;
      rs1 = 4'bx;
      rs2 = 4'bx;
      imm = 31'bx;

      decoder_illegal = 1;
    end
  endcase

   case(instr[6:0])  //Check OP Code again
    7'b0110011 : begin // R-Type
      case(instr[14:12]) //func3
        3'b000 : begin
          case(instr[31:25])
            7'b0000000: alu_op = 5'b00000; //ADD
            7'b0100000: alu_op = 5'b00001; //SUB
          endcase
        end
        3'b100 : alu_op = 5'b00010; //XOR
        3'b110 : alu_op = 5'b00011; //OR
        3'b111 : alu_op = 5'b00100; //AND
        3'b001 : alu_op = 5'b00101; //LEFT SHIFT LOGICAL
        3'b101: begin
          case(instr[31:25])
            7'b0000000: alu_op = 5'b00110; //RIGHT SHIFT LOGICAL
            7'b0100000: alu_op = 5'b00111; //RIGHT SHIFT ARITHMETIC
          endcase
        end
        3'b010 : alu_op = 5'b01000;  //LESS THAN
        3'b011 : alu_op = 5'b01001;  //GREATER THAN
      endcase
    end


    7'b0010011: begin //I-Type
      case(instr[14:12])
        3'b000 : alu_op = 5'b01010;  //ADD IMMEDIATE
        3'b100 : alu_op = 5'b01011;  //XOR IMMEDIATE
        3'b110 : alu_op = 5'b01100;  //OR IMMEDIATE
        3'b111 : alu_op = 5'b01101;  //AND IMMEDIATE
        3'b001 : alu_op = 5'b01110;  //SHIFT LEFT LOGICAL IMMEDIATE (rd=rs1<<imm[0:4])
        3'b101 :  begin
          case(imm[11:5])
            7'b0000000 : alu_op = 5'b01111; //SHIFT RIGHT LOGICAL IMMEDIATE
            7'b0100000 : alu_op = 5'b10000; //SHIFT RIGHT ARITHMETIC IMMEDIATE
          endcase
        end
        3'b010 : alu_op = 5'b10001;
        3'b011 : alu_op = 5'b10010;
        endcase
    end

    7'b1100011: begin //B-Type
      b_type = instr[14:12];
    end



    default: begin
      alu_op = 5'bx;
      b_type = 3'bx;
    end
  endcase


  case (instr[6:0])
    7'b0110011: alu_src = 0; // R-type
    7'b0010011: alu_src = 1; // I-type
    7'b0000011: alu_src = 1; // LOAD
    7'b0100011: alu_src = 1; // STORE
    7'b1100011: alu_src = 0;// B-TYPE
  endcase
end



endmodule