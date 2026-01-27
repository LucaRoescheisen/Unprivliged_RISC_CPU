module fsm(
  input clk,
  input reset,
  input decoder_illegal,
  input div_busy,
  input mem_busy,
  input is_load_store,
  output reg [2:0] state
);

reg [2:0] next_state;

localparam FETCH      = 3'b000,
           DECODE     = 3'b001,
           EXECUTE    = 3'b010,
           WRITE_BACK = 3'b011, //when saved to regfile
           MEM_WAIT   = 3'b100,
           TRAP       = 3'b101;

always @(posedge clk) begin
  if(reset) state <= FETCH;
  else      state <= next_state;
end


always @(*) begin
  next_state = state;
  case(state)
    FETCH      : next_state = DECODE;
    DECODE     : next_state = decoder_illegal ? TRAP : EXECUTE ;
    EXECUTE    : begin
                  if(div_busy) next_state = EXECUTE;
                  else if(is_load_store) next_state = MEM_WAIT; //Generated on lw or sw
                  else next_state = WRITE_BACK;
                 end
    MEM_WAIT   : next_state = mem_busy ? MEM_WAIT : WRITE_BACK;
    WRITE_BACK : next_state = FETCH;
    TRAP       : next_state = FETCH;
    default    : next_state = FETCH;
  endcase

end

endmodule