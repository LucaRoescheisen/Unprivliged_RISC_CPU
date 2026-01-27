module tb_top;
  reg clk = 0;
  reg reset = 0;
  top uut(
    .clk(clk)
  );

  always #5 clk = ~clk;

  initial begin
    $display("Starting simulation");
    reset = 1;
    #1;
    reset = 0;
    #100;
  end

endmodule