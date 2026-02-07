module csr(
 input clk,
 input reset,
 input [1:0] current_privilege,
 input [11:0] csr_addr,
 input [3:0] csr_func,
 input [31:0] csr_w_data,
 input csr_write_enable,
//Trap Handling

 input        trap_sources,
 input [31:0] trap_instr_pc,
 input [31:0] trap_cause,
//Interrupt Handling
input extr_iqr;
input [31:0] current_pc;

//minstret input
input instr_correctly_executed, //NOTE :: REMEBER KEEP LOW FOR STALLS
 output trap_csr_violation;
 output [31:0] csr_r_data,
 output [31:0] next_pc
 output flush_from_interrupt
);
localparam NO_PRIV 1;



//MVENDORID : 0xF11
reg [31:0] mvendorid;
always @(posedge clk) begin
  mvendorid <= 32'b0;
end


//MARCHID: 0xF12
reg [31:0] marchid;
always @(posedge clk) begin
  marchid <= 32'b0;
end


//MIMPID : 0xF13
reg [31:0] mimpid;
always @(posedge clk) begin
  mimpid <= 32'b00000000000000000000000000000001; //Update on architecture changes
end


//MHARTID: 0xF14
reg [31:0] mhartid;
always @(posedge clk) begin
  mhartid <= 32'b0;     //Single-hart system
end


//mstatus: 0x300
reg [31:0] mstatus = 32'b0;
localparam MIE 3,
           MPIE 7,
           MPP_LOW 11,
           MPP_HIGH 12;
/*
  Tracks CPU privilege and interrupt state
  BIT 3     : MIE  : Machine Interrupt Enable
  BIT 7     : MPIE : Machine Previous Interrupt Enable
  BIT 12:11 : MPP  : Machine previous privilege
*/


//misa: 0x301
reg [31:0] misa;
always @(posedge clk) begin
  misa <= 32'b00000000000000000100001000000000; //Set bits for 32I and M-Extension
end


//MIE : 0x304  MRW
reg [31:0] mie = 32'b00000000000000000000100010001000;
/*
  Mask Interrupt Register
    Controls which interrupt sources are enabled
    Software writes to this
    Is not cleared on traps

    BIT 11 : Machine External Interrupt Enable
    BIT  7 : Machine Timer Interrupt Enabe
    BIT  3 : Machine Software Interrupt Enable

*/


//MIE : 0x344  MRW
reg [31:0] mip = 32'b00000000000000000000100010001000;
/*
  Interrupt Pending Bits
    Set by hardware
    Cleared by software

    BIT 11 : External Interrupt Pending
    BIT  7 : Timer Interrupt Pending
    BIT  3 : Software Interrupt Pending

*/

wire is_mret; //(instr == 32'h30200073);

//MTVEC : 0x305 MRW
reg [31:0] mtvec;
//Location of trap handler


//MEPC : 0x341 MRW
reg [31:0] mepc;
//Stored location of line of code that caused the trap

//MCAUSE : 0x342 MRW
reg [31:0] mcause;

//MSCRATCH : 0x340 MRW
reg [31:0] mscratch;
/*
  A temporary storage for trap handler, where you can save something like the stack pointer
  It is handled in software.
*/


//MCYCLE : 0xB00 MRW
reg [31:0] MCYCLEH;
always @(posedge clk) begin
  if (reset) begin
    mcycle <= 0;
  end
  else if (mcycle ==  32'hffffffff)begin
    mcycle <= mcycle;
  end else begin
    mcycle <= mcycle + 1;
  end
end
//MCYCLEH : 0xB80 MRW
reg [31:0] mcycleh;
always @(posedge clk) begin
  if(reset) begin
    mcycleh <= 0;
  end
  else if (mcycle ==  32'hffffffff)begin
    mcycleh <= mcycleh + 1;
  end else begin
    mcycleh <= mcycleh;
  end

end



//MINSTRET : 0xB02 MRW
reg [31:0] minstret;
always @(posedge clk) begin
  if(reset) begin
    minstret <= 0;
  end
  else if (instr_correctly_executed && minstret != 32'hffffffff)begin
    minstret <= minstret + 1;
  end else begin
    minstret <= minstret;
  end

end
//counts number of instructions executed by cpu



//MINSTRETH : 0xB82 MRW
reg [31:0] minstreth;
always @(posedge clk) begin
  if(reset) begin
    minstreth <= 0;
  end
  else if (instr_correctly_executed && minstret ==  32'hffffffff)begin
    minstreth <= minstreth + 1;
  end else begin
    minstreth <= minstreth;
  end

end
//counts number of instructions executed by cpu

wire is_trap = trap_sources;
wire take_interrupt = mstatus[3] && mie[11] && mip[11]; //global enabled && source enable && source pending
always @(posedge clk or posedge reset) begin
  if(reset) begin
    mstatus <= 32'b0;
    mepc <= 32'b0;
  end
  else if(is_trap) begin
    mepc <= trap_instr_pc;
    mcause <= {1'b0, trap_cause[30:0]};
    mstatus[`MPP_HIGH:`MPP_LOW] <= current_privilege; // saves old current_privilege
    current_privilege <= 1'b11 //swtich to machine mode to give OS highest current_privilege to access CSRs
    mstatus[`MIE] <=  1'b0; //disables interrupts
    next_pc <= mtvec; //mtvec is declared from  the Trap Handler in OS
  end
  else if (take_interrupt) begin//Interrupts are enabled!
    mcause <= {1'b1, trap_cause[30:0]};                     //Machine interrupt
    mepc <= current_pc + 4;
    mcause <= current_pc + 4;

    mstatus[`MPP_HIGH:`MPP_LOW]  <= current_privilege;
    mstatus[`MPIE] <=  mstatus[`MIE];
    mstatus[`MIE] <=  1'b0;
    next_privilege <= 1'b11; //Machine
    next_pc <= mtvec;
    flush_from_interrupt <= 1;

  end
  else if (is_mret) begin            //Interrupt Handled
    next_privilege <= mstatus[`MPP_HIGH:`MPP_LOW];
    mstatus[`MIE] <= mstatus[`MPIE]; //Save the previous interrupt bit
    mstatus[`MPIE] <= 1'b1;           //Enable interrupts
    next_pc <= mpec;                 //Move program counter to position specified by the trap handler
    flush_from_interrupt <= 1;       //Flush pipeline
  end
  else begin
    if(csr_write_enable) begin
      if(current_privilege == 2'b11) begin //Make sure we are in machine mode for read and write operations
         csr_r_data <= mstatus;
        case(csr_addr)
          12'h300: begin //MSTATUS
            case(csr_func)
              3'b001: mstatus <= csr_w_data;//CSSRW Atomic read-write
              3'b010: mstatus <= csr_w_data | mstatus;//CSSRS
              3'b011: mstatus <= ~csr_w_data & mstatus;//CSSRC
              3'b100: mstatus <= csr_imm;//CSSRWI
              3'b101: mstatus <= csr_imm | csr_w_data;//CSSRI
              3'b110: mstatus <= ~csr_imm & csr_w_data; //CSRRCI
            endcase
          end
            12'h305: begin //MTVEC
            case(csr_func)
              3'b001: mtvec <= csr_w_data;//CSSRW Atomic read-write
              3'b010: mtvec <= csr_w_data | mtvec;//CSSRS
              3'b011: mtvec <= ~csr_w_data & mtvec;//CSSRC
              3'b100: mtvec <= csr_imm;//CSSRWI
              3'b101: mtvec <= csr_imm | csr_w_data;//CSSRI
              3'b110: mtvec <= ~csr_imm & csr_w_data; //CSRRCI
            endcase
          end
          12'h305: begin //MSCRATCH
            case(csr_func)
              3'b001: mscratch <= csr_w_data;//CSSRW Atomic read-write
              3'b010: mscratch <= csr_w_data | mscratch;//CSSRS
              3'b011: mscratch <= ~csr_w_data & mscratch;//CSSRC
              3'b100: mscratch <= csr_imm;//CSSRWI
              3'b101: mscratch <= csr_imm | csr_w_data;//CSSRI
              3'b110: mscratch <= ~csr_imm & csr_w_data; //CSRRCI
            endcase
          end
        endcase
      end
      else begin
        trap_csr_violation <= 1;
        trap_pc <= current_pc;
      end
    end
  end
end



endmodule