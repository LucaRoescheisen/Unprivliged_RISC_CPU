module data_memory(
  input clk,
  input [2:0] load_type,
  input [2:0] store_type,
  input mem_read_en,
  input mem_write_en,
  input [31:0] ram_address,
  input  [31:0] data_in,
  output reg [31:0] data_out,
  output reg mem_busy
);
/*
addr : [1:0] tells which byte is being accessed (column)
addr : [11:2] which address is being accessed (row)
*/


reg [31:0] ram [0:1023];
integer i;
initial begin
    for (i = 0; i < 1024; i = i + 1) begin
        ram[i] = 32'h0;
    end
end

always @(posedge clk) begin
  if(mem_write_en) begin
        case(store_type)
            3'b000: begin // STORE BYTE
                case(ram_address[1:0])
                    2'b00: ram[ram_address[11:2]][7:0]   <= data_in[7:0];
                    2'b01: ram[ram_address[11:2]][15:8]  <= data_in[7:0];
                    2'b10: ram[ram_address[11:2]][23:16] <= data_in[7:0];
                    2'b11: ram[ram_address[11:2]][31:24] <= data_in[7:0];
                endcase
            end
            3'b001: begin // STORE HALF
                case(ram_address[1])
                    1'b0: ram[ram_address[11:2]][15:0]  <= data_in[15:0];
                    1'b1: ram[ram_address[11:2]][31:16] <= data_in[15:0];
                endcase
            end
            3'b010: begin // STORE WORD
                ram[ram_address[11:2]] <= data_in;
            end
        endcase
    end
end


wire [31:0] current_word = ram[ram_address[11:2]];

always @(posedge clk) begin

  if(mem_read_en) begin
    case(load_type)
      3'b000: //LOAD BYTE
        case(ram_address[1:0])
          2'b00: data_out <= {{24{current_word[7]}} , current_word[7:0]};
          2'b01: data_out <= {{24{current_word[15]}}, current_word[15:8]};
          2'b10: data_out <= {{24{current_word[23]}}, current_word[23:16]};
          2'b11: data_out <= {{24{current_word[31]}}, current_word[31:24]};
        endcase
      3'b001: //LOAD HALF
          case(ram_address[1])
            1'b0: data_out <= {{16{current_word[15]}} , current_word[15:0]};
            1'b1: data_out <= {{16{current_word[31]}}, current_word[31:16]};
          endcase
      3'b010: //LOAD WORD
        data_out <= current_word;
      3'b100: //LOAD BYTE (U)
         case(ram_address[1:0])
          2'b00: data_out <= {24'b0, current_word[7:0]};
          2'b01: data_out <= {24'b0, current_word[15:8]};
          2'b10: data_out <= {24'b0, current_word[23:16]};
          2'b11: data_out <= {24'b0, current_word[31:24]};
        endcase
      3'b101: //LOAD HALF (U)
          case(ram_address[1])
            1'b0: data_out <= {{16{current_word[0]}} , current_word[15:0]};
            1'b1: data_out <= {{16{current_word[0]}}, current_word[31:16]};
          endcase

    endcase

  end
end

always @(posedge clk) begin
    if ((mem_read_en || mem_write_en) && !mem_busy) begin
        mem_busy <= 1'b1;
    end else begin
        mem_busy <= 1'b0;
    end

end


endmodule