/* decoders.v
 * ECE 154A Lab 5
 * author: Ryan Wenger
 */

// Controller FSM states
//`define FETCH     'h5010 // 0 
//`define DECODE    'h0030 // 1
//`define MEM_ADR   'h0420 // 2
//`define MEM_READ  'h0520 // 3
//`define MEM_WB    'h0ca0 // 4
//`define MEM_WRITE 'h25a0 // 5
//`define R_EXEC    'h0482 // 6
//`define ALU_WB    'h0c40 // 7
//`define BR_EXEC   'h0645 // 8
//`define ADDI_EXEC 'h0464 // 9
//`define ADDI_WB   'h0c24 // 10
//`define JMP_EXEC  'h4428 // 11


// control words
`define FETCH     'h5010 // 0 
`define DECODE    'h0030 // 1
`define MEM_ADR   'h0420 // 2
`define MEM_READ  'h0100 // 3
`define MEM_WB    'h0880 // 4
`define MEM_WRITE 'h2100 // 5
`define R_EXEC    'h0402 // 6
`define ALU_WB    'h0840 // 7
`define BR_EXEC   'h0645 // 8
`define ADDI_EXEC 'h0420 // 9
`define ADDI_WB   'h0800 // 10
`define JMP_EXEC  'h4428 // 11

module main_decoder(
  input clk, rst,
  input[5:0] op,
  output pcwrite,
  output memwrite,
  output irwrite, regwrite,
  output alusrca, branch, 
  output iord, memtoreg,
  output regdst,
  output [1:0] alusrcb,
  output [1:0] pcsrc, aluop
);
  reg[15:0] ctrl;
  assign {pcwrite, memwrite, irwrite, regwrite, alusrca,
          branch, iord, memtoreg, regdst, alusrcb, 
          pcsrc, aluop} = ctrl[14:0];
  
  integer state;
  always @(posedge rst) begin
    state <= 0;
    ctrl <= `FETCH;
  end

  always @(posedge clk) begin
    case (state)
      0: state <= 1;
      1: 
        casex (op)
          6'b000000: state <= 6; // R-type
          6'b000010: state <= 11; // j
          6'b000100: state <= 8; // beq
          6'b001000: state <= 9; // addi
          6'b10x011: state <= 2; // lw, sw
          default: state <= 'hxxxxxxxx; // invalid
        endcase
      2: 
        case (op)
          6'b100011: state <= 3; // lw
          6'b101011: state <= 4; // sw
          default: state <= 'hxxxxxxxx; // invalid
        endcase
      3: state <= 4;
      4: state <= 5;
      5: state <= 0;
      6: state <= 7;
      7: state <= 0;
      8: state <= 0;
      9: state <= 10;
      10: state <= 0;
      11: state <= 0;
      default: state <= 'hxxxxxxxx;
    endcase
  end
  
  always @(state) begin
    case (state)
      0: ctrl <= `FETCH;
      1: ctrl <= `DECODE;
      2: ctrl <= `MEM_ADR;
      3: ctrl <= `MEM_READ;
      4: ctrl <= `MEM_WB;
      5: ctrl <= `MEM_WRITE;
      6: ctrl <= `R_EXEC;
      7: ctrl <= `ALU_WB;
      8: ctrl <= `BR_EXEC;
      9: ctrl <= `ADDI_EXEC;
      10: ctrl <= `ADDI_WB;
      11: ctrl <= `JMP_EXEC;
    endcase
  end
//  always @(posedge clk) begin
//    case (ctrl)
//      `FETCH: ctrl <= `DECODE;
//      `DECODE: 
//        casex (op)
//          6'b000000: ctrl <= `R_EXEC; // R-type
//          6'b000010: ctrl <= `JMP_EXEC; // j
//          6'b000100: ctrl <= `BR_EXEC; // beq
//          6'b001000: ctrl <= `ADDI_EXEC; // addi
//          6'b10x011: ctrl <= `MEM_ADR; // lw, sw
//          default: ctrl <= 'hxxxxxxxx; // invalid
//        endcase
//      `MEM_ADR: 
//        case (op)
//          6'b100011: ctrl <= `MEM_READ; // lw
//          6'b101011: ctrl <= `MEM_WB; // sw
//          default: ctrl <= 'hxxxxxxxx; // invalid
//        endcase
//      `MEM_READ: ctrl <= `MEM_WB;
//      `MEM_WB: ctrl <= `FETCH;
//      `MEM_WRITE: ctrl <= `FETCH;
//      `R_EXEC: ctrl <= `ALU_WB;
//      `ALU_WB: ctrl <= `FETCH;
//      `BR_EXEC: ctrl <= `FETCH;
//      `ADDI_EXEC: ctrl <= `ADDI_WB;
//      `ADDI_WB: ctrl <= `FETCH;
//      `JMP_EXEC: ctrl <= `FETCH;
//      default: ctrl <= 'hxxxxxxxx;
//    endcase
//  end
endmodule    

module alu_decoder(input[5:0] funct,
  input[1:0] aluop,
  output[2:0] alucontrol
);

  reg [2:0] ctrl;
  assign alucontrol = ctrl;

  always @(aluop, funct) begin
    case (aluop)
      2'b00:
        ctrl <= 3'b010; // add for I-types
      2'b01:
        ctrl <= 3'b110; // sub for I-types (beq, bne)
      2'b11:
        ctrl <= 3'b001; // or for I-types
      default: // R-types 
      case (funct)
        6'b100000:
          ctrl <= 3'b010; // add
        6'b100010:
          ctrl <= 3'b110; // sub
        6'b100100:
          ctrl <= 3'b000; // and
        6'b100101:
          ctrl <= 3'b001; // or
        6'b101010:
          ctrl <= 3'b111; // slt
        default:
          ctrl <= 3'bxxx; // ???
      endcase
    endcase
  end
endmodule