module tb_top;
  reg clk = 0;

  top uut(
    .clk(clk)
  );

  always #5 clk = ~clk;

  initial begin
    $display("Starting simulation");
    #100;
  end

endmodule