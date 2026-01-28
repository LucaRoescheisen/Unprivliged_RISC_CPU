module divider(
  input clk,
  input [31:0] divisor, //top
  input [31:0] dividend //bottom
  input start,
  output reg [31:0] quotient,
  output reg [31:0] remainder
);


wire [31:0] abs_divisor = divisor[31] ? (-divisor) : divisor;
wire [31:0] abs_dividend = dividend[31] ? (-dividend) : dividend;
reg  [63:0] dividing_space;
reg [5:0] counter;
reg busy;

wire quotient_neg = divisor[31] ^ dividend[31];
wire remainder_neg = dividend[31];
/*
Dividing Space = {Remainder, Dividend}
Process:
Shift the whole dividing space to the left by 1
Remainder = Remainder - Divisor
  if  Remainder < 0 : Restore remainder to previous value : Set LSB of Divident to 0
  if Remainder >= 0 : Set LSB of Dividend to 1
counter += 1
*/
wire [63:0] shifted_dividing_space = dividing_space << 1;
wire [32:0] sub_trial = shifted_space[63:32] - abs_divisor; // Uses 33 bits to catch the carry to determine the sign


always @(posedge clk) begin
  if(!busy) begin
    if (start) begin
      dividing_space = {{0{32}}, abs_dividend};
      counter = 0;
      busy = 1;
    end

    if(quotient_neg) quotient <= -dividing_space[31:0];
    else             quotient <=  dividing_space[31:0];

    if(remainder_neg) remainder <= -dividing_space[63:32];
    else              remainder <=  dividing_space[63:32];

  end else begin

    else begin
      if(sub_trial[32]) begin
        dividing_space[0] <= 0;
        dividing_space[63:32] <= {shifted_space[63:1], 1'b0}; //Since < 0 we restore the whole space but add a 0 at bit 0
      end
      else begin
        dividing_space[0] <= 1;
        dividing_space[63:32] <= {sub_trial[31:0], shifted_space[31:1], 1'b1}; //Update the Remainder, and add a 1 to bit 0
      end
    end

    if(counter == 31) begin
      busy = 0;


    end else begin
      counter <= counter + 1;
    end
  end
end




endmodule