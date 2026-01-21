module top(
  input clk
);

  reg test;
  always @(posedge clk) begin
    test <= clk;
  end


endmodule