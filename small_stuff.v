// Definitions for small, low-level modules
// regfile, decoder2to4, mux2to1, sll2, signext16to32, DFF

// register file
module regfile(input clk,
    input we3,
    input[4:0] a1, a2, a3,
    input[31:0] wd3,
    output[31:0] rd1, rd2
);

  reg[31:0] registers[31:0];

//  assign rd1 = registers[a1];
//  assign rd2 = registers[a2];
  assign rd1 = (a1) ? registers[a1] : 0;
  assign rd2 = (a2) ? registers[a2] : 0;

  always @(posedge clk) begin
    if (we3)
      registers[a3] <= wd3;
  end
endmodule

// 2:4 decoder module
module decoder2to4(
    input [1:0] in,
    output [3:0] out
);
    assign out[0] = ~in[0] & ~in[1];
    assign out[1] =  in[0] & ~in[1];
    assign out[2] = ~in[0] &  in[1];
    assign out[3] =  in[0] &  in[1]; 
endmodule

// 2:1 multiplexer
module mux2to1#(parameter width=32)
(
    input switch,
    input[width-1:0] x0, x1,
    output[width-1:0] y
);
    assign y = switch ? x1 : x0;
endmodule

// 4:1 multiplexer
module mux4to1#(parameter width=32)
(
    input [1:0] sel,
    input [width-1:0] x0, x1, x2, x3,
    output [width-1:0] y
);

  assign y = (sel[1]) ?
              ((sel[0]) ? x3 : x2) :
              ((sel[0]) ? x1 : x0); 
endmodule

// left-shift by 2
module sll2(input [31:0] in, output [31:0] out);
  assign out = in << 2;
endmodule

// sign extend 16-bit value to 32-bits
module signext16to32(input [15:0] in, output [31:0] out);
  assign out = (in[15]) ? {16'hFFFF, in} : {16'h0000, in};
endmodule

// D flip-flop with reset
module DFF#(parameter width=32)
(
    input clk, rst,
    input [width-1:0] d,
    output reg[width-1:0] q 
);
  always @(posedge clk, posedge rst) begin
    if (rst)
      q <= 0;
    else
      q <= d;
  end
endmodule

// D flip-flop with reset and enable
module DFFenb#(parameter width=32)
(
    input clk, rst, enb,
    input [width-1:0] d,
    output reg[width-1:0] q 
);
  always @(posedge clk, posedge rst) begin
    if (enb) begin
      if (rst)
        q <= 0;
      else
        q <= d;
    end
  end
endmodule