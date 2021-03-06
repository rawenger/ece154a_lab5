//-------------------------------------------------------
// Multicycle MIPS processor
//------------------------------------------------

module mips(input        clk, reset,
            output [31:0] adr, writedata,
            output        memwrite,
            input [31:0] readdata);

  wire        zero, pcen, irwrite, regwrite,
               alusrca, iord, memtoreg, regdst;
  wire [1:0]  alusrcb, pcsrc;
  wire [2:0]  alucontrol;
  wire [5:0]  op, funct;

  controller c(clk, reset, op, funct, zero,
               pcen, memwrite, irwrite, regwrite,
               alusrca, iord, memtoreg, regdst, 
               alusrcb, pcsrc, alucontrol);
  datapath dp(clk, reset, 
              pcen, irwrite, regwrite,
              alusrca, iord, memtoreg, regdst,
              alusrcb, pcsrc, alucontrol,
              op, funct, zero,
              adr, writedata, readdata);
endmodule

// Todo: Implement controller module
module controller(input       clk, reset,
                  input [5:0] op, funct,
                  input       zero,
                  output       pcen, memwrite, irwrite, regwrite,
                  output       alusrca, iord, memtoreg, regdst,
                  output [1:0] alusrcb, pcsrc,
                  output [2:0] alucontrol
);

  wire [1:0] aluop;
  wire branch;
  wire pcwrite;
  
  
  alu_decoder aludec(funct, aluop, alucontrol);
  
  main_decoder maindec(clk, reset, op, pcwrite, memwrite, irwrite,
      regwrite, alusrca, branch, iord, memtoreg, regdst, alusrcb,
      pcsrc, aluop);
   
  wire bandz;
  andgate#(1) bnz(zero, branch, bandz);
  orgate#(1) pcw(bandz, pcwrite, pcen);
   
endmodule

// Todo: Implement datapath
module datapath(input        clk, reset,
                input        pcen, irwrite, regwrite,
                input        alusrca, iord, memtoreg, regdst,
                input [1:0]  alusrcb, pcsrc, 
                input [2:0]  alucontrol,
                output [5:0]  op, funct,
                output        zero,
                output [31:0] adr, writedata, 
                input [31:0] readdata
);

  wire [31:0] pc, pcnext, pcjump;
  wire [4:0] writereg;
  wire [31:0] signimm, signimmsh;
  wire [27:0] immsh;
  
  wire [31:0] srca, srcb, aluout;
  
  wire [31:0] rd1, rd2, wd3;
  
  wire [31:0] aluresult;
  
  wire [31:0] instr, data;

  wire [31:0] a;
  
  assign op = instr[31:26];
  assign funct = instr[5:0];
  
  // memory data
  mux2to1 adr_sel(iord, pc, aluout, adr);
  DFFenb instrFF(clk, reset, irwrite, readdata, instr);
  DFF dataFF(clk, reset, readdata, data);
  
  // PC logic
  assign pcjump = {pc[31:28], immsh};
  sll2 signsh(signimm, signimmsh);
  sll2#(26,28) sh(instr[25:0], immsh);
  mux4to1 pc_sel(pcsrc, aluresult, aluout, 
          pcjump, 0, pcnext);
  DFFenb pcFF(clk, reset, pcen, pcnext, pc);

  // register file logic
  regfile regs(clk, regwrite, instr[25:21], instr[20:16],
                writereg, wd3, rd1, rd2);
  mux2to1 #(5) a3_sel(regdst, instr[20:16], instr[15:11],
                      writereg);
  
  mux2to1 wd3_sel(memtoreg, aluout, data, wd3);
  signext16to32 signextimm(instr[15:0], signimm);
  DFF aFF(clk, reset, rd1, a);
  DFF bFF(clk, reset, rd2, writedata);

  // ALU logic
  mux4to1 srcb_sel(alusrcb, writedata, 32'd4, signimm, signimmsh, srcb);
  mux2to1 srca_sel(alusrca, pc, a, srca);
  alu alu(srca, srcb, alucontrol, aluresult, zero);
  DFF aluFF(clk, reset, aluresult, aluout);
  
endmodule