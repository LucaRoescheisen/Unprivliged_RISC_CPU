module data_memory(
  input clk,
  input mem_read_en,
  input mem_write_en,
  input [31:0] addr,
  output [31:0] data_in,
  output [31:0] data_out,
  output mem_busy
);

reg [31:0] ram [0:1023];

always @(posedge clk) begin
  if(mem_write_en) begin
    mem_busy <= 1
    ram[addr[11:2]] <= data_in; //Removes bit 0 and 1 to byte align to 4. Since every word(4 bytes) is 1 word
  end
end

always @(posedge clk) begin
  if(mem_read_en) begin
    data_out = ram[addr[11:2]]
  end
end

always @(posedge clk) begin
  if(mem_read_en || mem_write_en) begin
    mem_busy <= 1'b1;
  end
  else begin
    mem_busy <= 1'b0;
  end

end


endmodule