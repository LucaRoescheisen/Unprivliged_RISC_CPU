module branch_unit(
  input b_type,
  input imm,
  input [31:0] rs1_val,
  input [31:0] rs2_val,
  output take_branch
);

  always (*) begin
    take_branch = 1'b0;
    case(b_type)
      3'b000: begin
        if(rs1_val == rs2_val) take_branch = 1'b1;
      end
      default: take_branch = 1'b0;
    endcase
  end



endmodule