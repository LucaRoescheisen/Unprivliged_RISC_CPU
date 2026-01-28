module divider(
  input clk,
  input [31:0] divisor, //top
  input [31:0] dividend, //bottom
  input start,
  input [2:0] div_op,
  output reg [31:0] result,
  output reg busy
);

initial begin
  busy = 0;
end

reg [31:0] quotient;
reg [31:0] remainder;

wire is_unsigned = (div_op == 3'b101 || div_op == 3'b111);
reg  [63:0] dividing_space;
reg [5:0] counter;

wire [31:0] useable_divisor  = (!is_unsigned && divisor[31])  ? -divisor  : divisor;
wire [31:0] useable_dividend = (!is_unsigned && dividend[31]) ? -dividend : dividend;
reg quotient_neg;
reg remainder_neg;
/*
Dividing Space = {Remainder, Dividend}
Process:
Shift the whole dividing space to the left by 1
Remainder = Remainder - Divisor
  if  Remainder < 0 : Restore remainder to previous value : Set LSB of Divident to 0
  if Remainder >= 0 : Set LSB of Dividend to 1
counter += 1
*/
wire [63:0] shifted_space = dividing_space << 1;
wire [32:0] sub_trial = shifted_space[63:32] - useable_divisor; // Uses 33 bits to catch the carry to determine the sign


always @(*) begin
  case (div_op)
    3'b101, 3'b100: result = quotient;
    3'b110, 3'b111: result = remainder;
    default:        result = 32'b0;
  endcase
end

always @(*) begin
    if(quotient_neg && !is_unsigned) quotient = -dividing_space[31:0];
    else             quotient =  dividing_space[31:0];

    if(remainder_neg && !is_unsigned) remainder = -dividing_space[63:32];
    else          remainder =  dividing_space[63:32];
end


always @(posedge clk) begin
  if(!busy) begin
    if (start) begin
      dividing_space <= {32'd0, useable_dividend};
      counter <= 0;
      busy <= 1;
      quotient_neg <= divisor[31] ^ dividend[31];
      remainder_neg <= dividend[31];
    end
  end else begin
    if(counter == 30) begin
      busy = 0;
    end else begin
      counter <= counter + 1;
      if(sub_trial[32]) begin
        dividing_space <= {shifted_space[63:1], 1'b0}; //Since < 0 we restore the whole space but add a 0 at bit 0
      end
      else begin
        dividing_space[63:0] <= {sub_trial[31:0], shifted_space[31:1], 1'b1}; //Update the Remainder, and add a 1 to bit 0
      end
    end
  end
end

endmodule