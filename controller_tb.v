// lab 5 controller FSM testbench
module controller_tb();
  reg clk;
  reg reset;
  wire pcwrite;
  wire memwrite;
  wire irwrite, regwrite;
  wire alusrca, branch;
  wire iord, memtoreg;
  wire regdst;
  wire [1:0] alusrcb;
  wire [1:0] pcsrc, aluop;
  // instantiate device to be tested
  main_decoder dut (clk, reset, pcwrite, memwrite, irwrite,
      regwrite, alusrca, branch, iord, memtoreg,
      regdst, alusrcb, pcsrc, aluop);
      
  // instruction memory
  reg [31:0] instructions [63:0];
  initial begin
    $readmemh("memfile.dat", RAM);
  end
  
  // initialize test
  initial
  begin
    reset <= 1; # 2; reset <= 0;
  end
  // generate clock to sequence tests
  always
  begin
    clk <= 1; # 5; clk <= 0; # 5;
  end
  
endmodule