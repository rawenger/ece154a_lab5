// alu.v
// author: Ryan Wenger
// ECE 154A Lab 4

module alu(
    input [31:0] a, b,
    input [2:0] f,
    output [31:0] y,
    output zero
);
    
    wire [31:0] and_out, or_out, add_out, cmp_out;
    andgate AND(.a(a), .b(b), .y(and_out));
    orgate OR(.a(a), .b(b), .y(or_out));
    adder ADD(.a(a), .b(f[2] ? (~b + 1'b1) : b), .y(add_out));
    comparator SLT(.a(a), .b(b), .y(cmp_out));
    
    wire [31:0] aluout;
    mux4to1 mux(f[1:0], and_out, or_out, add_out, cmp_out, aluout);
    assign y = (f === 3'b011) ? y : aluout;
    assign zero = (y === 32'b0);
endmodule

// 32-bit AND gate
module andgate#(parameter width=32)
  (
    input [width - 1:0] a, b,
    output [width - 1:0] y
    );
    assign y = a & b;
endmodule

// 32-bit OR gate
module orgate#(parameter width=32)
  (
    input [width - 1:0] a, b,
    output [width - 1:0] y
    );
    assign y = a | b;
endmodule

// 32-bit adder
module adder(
    input [31:0] a, b,
    output [31:0] y
    );
    assign y = a + b;
endmodule

// 32-bit comparator
module comparator(
    input [31:0] a, b,
    output [31:0] y
    );
//    assign y = a - b > 32'b1; for some reason this doesn't work...?
    wire [31:0] diff;
    assign diff = a + (~b + 1'b1);
    assign y = {30'b0, diff[31]};
endmodule

//module ALU (
//    input [31:0] a, b, 
//    input [2:0] f,
//    output reg [31:0] y,
//    output zero
//);
//    wire [31:0] BB ;
//    wire [31:0] S ;
//    wire   cout ;
//
//    assign BB = (f[2]) ? ~b : b ;
//    assign {cout, S} = f[2] + a + BB ;
//    always @ * begin
//        case (f[1:0])
//            2'b00 : y <= a & BB ;
//            2'b01 : y <= a | BB ;
//            2'b10 : y <= S ;
//            2'b11 : y <= {31'd0, S[31]};
//        endcase
//    end
//
//    assign zero = (y == 0) ;
//
//endmodule