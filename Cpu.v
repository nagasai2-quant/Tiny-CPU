module main;
  wire [31:0] rom_data,ins;
  wire [7:0] pc;
  wire [2:0] flags;
  wire [1:0] stkopr;
  wire [7:0] adr,jump_ad;
  wire [23:0] raddr;
  reg rst,clk;
  wire [7:0] operation_out,opcode,dataA,dataB,ramout;
  wire [7:0] dout;
  wire pcen,write_en,ram_write_en,sel,jump_en;
  
  pccounter pcc(clk,pcen,pc,rst,jump_ad,jump_en);
  rom memo(pc,rom_data);
  ram ramem(adr,clk,ram_write_en,dataA,ramout,stkopr);
  instr insta(clk,rom_data,ins);
  control cont(clk,ins,write_en,ram_write_en,pcen,opcode,raddr,adr,sel,flags,jump_ad,jump_en,stkopr);
  operationalx opox(opcode,dataA,dataB,operation_out);
  comparitor comp(dataA,dataB,flags);
  Regfile regf(write_en,clk,raddr,operation_out,ramout,dataA,dataB,sel);

  //Data bits info
  // 8 bits - Opcode noted : opcode / inst[31:24] ;
  // 24 bits - {8 - 8 - 8} (1-> data1 ; 2 -> data2 ; 3 -> destination/jumpadr);

  //Mishcalleous info
  // adr -> ram wrting or ram reading address ;
  // raddr -> operation address data1,data2 ;
  // stkopr -> represents the stack operations as (01 -> Push ; 10 -> pop)

  //Opcodes :
  // 00 -> AND 
  // 01 -> XOR
  // 02 -> OR
  // 03 -> NAND
  // 04 -> ADD
  // 05 -> SUB
  // 06 -> STORE
  // 07 -> LOAD
  // 08 -> JUMP
  // 09 -> JUMP IF EQUAL (JE)
  // 0A -> JUMP IF ABOVE (JA)
  // 0B -> JUMP IF BELOW (JB)
  // 0C -> PUSH
  // 0D -> POP
  // ....
  // AC -> HALT

  initial clk = 0;
  always #5 clk = ~clk;

  initial begin
    $dumpfile("ramemory.vcd");
    $dumpvars(0,main);
    $display("               Data               |    PC    |   Opcode   |         Data        | Flags |    Out    |");
    $monitor(" %32b | %8b |  %8b  | %8b | %8b |  %3b  | %8b ", ins, pc, opcode, dataA, dataB,flags,operation_out);
    
    rst = 1; #10 
    rst = 0; #260
    $finish;
  end;
  
endmodule

// Each instruction is given as -> 8bit_opcode + 8bit_adr1 + 8bit_adr2 + 8bit_dest1 => 32bit

module control(clk,inst,we,wrtenb,pcen,opcode,raddr,adr,sel,flags,jump_ad,jump_en,stkopr);
input clk;
input [2:0] flags;
input [31:0] inst;
output reg [1:0] stkopr;
output reg [7:0] opcode;
output reg [7:0] adr,jump_ad;
output reg [23:0] raddr;
output reg pcen,we,wrtenb,sel,jump_en;

reg [1:0] nxst , pst;

localparam Fetch = 2'b00 , Decode = 2'b01 , Execute = 2'b10 , Writeback = 2'b11;

initial begin 
  pst = Fetch;
  opcode = 0;
  pcen = 0;
  wrtenb = 0;
  we = 0;
  jump_ad = 8'b0;
  stkopr = 2'b00;
end;

always @(*) begin
  nxst = pst;
  case(pst)
  Fetch : nxst = Decode;
  Decode : nxst = Execute;
  Execute : begin 
    if(inst[31:24] > 8'h05) begin  // For Alu operations start from write back and go to fetch 
       nxst = Fetch;
       if(inst[31:24] == 8'hAC) begin
         nxst = Decode;
       end else if(inst[31:24] == 8'h0D) begin
         nxst = Writeback;
       end
    end else begin  // For all other operations like jump , halt ,.etc start from fetch
       nxst = Writeback;
    end
  end
  Writeback : nxst = Fetch;
  endcase;
end;

always @(posedge clk) begin

  case(pst)  
  Fetch : begin
    pcen <= 1'b0;
    we <= 1'b0;
    sel <= 1'b0;
    wrtenb <= 1'b0;
    jump_en <= 1'b0;
    stkopr <= 2'b00;
    //Fetch
  end
    
  Decode : begin
     pcen <= (inst[31:24] != 8'hAC);  // <= only activate the program counter if HALT is not issused
     we <= 1'b0;
     sel <= 1'b0;
     raddr <= (inst[31:24] != 8'hAC ? inst[23:0] : 0); // <= Data dependancy hazard if you use this statement in next state a.k.a 'Execute' 
     //decode 
  end

  Execute : begin
    pcen <= 1'b0;
    case(inst[31:24]) 
    8'h00 : opcode <= inst[31:24];  
    8'h01 : opcode <= inst[31:24];  
    8'h02 : opcode <= inst[31:24];  
    8'h03 : opcode <= inst[31:24];
    8'h04 : opcode <= inst[31:24];
    8'h05 : opcode <= inst[31:24];
    8'h06 : begin                  // STORE
      adr <= inst[7:0];
      wrtenb <= 1'b1;
    end 
    8'h07 : begin                  // LOAD
      adr <= inst[7:0];
      we <= 1'b1;
      sel <= 1'b1;
    end
    8'h08 : begin                  //JUMP 
      jump_ad <= inst[7:0];        //Jump addr
      jump_en <= 1'b1;
    end
    8'h09 : begin                  //JE (jump if equal)
      if(flags == 3'b100) begin
        jump_ad <= inst[7:0];
        jump_en <= 1'b1;
        $display(" JE triggered -> %d",inst[7:0]);
      end
    end
    8'h0A : begin                  //JA (jump if above r equal)
      if(flags == 3'b010) begin
        jump_ad <= inst[7:0];
        jump_en <= 1'b1;
        $display(" JA triggered -> %d",inst[7:0]);
      end
    end
    8'h0B : begin                  //JB (jump if below r equal)
      if(flags == 3'b001) begin
        jump_ad <= inst[7:0];
        jump_en <= 1'b1;
        $display(" JB triggered -> %d",inst[7:0]);
      end
    end
    8'h0C : begin                  //PUSH
      wrtenb <= 1'b1;
      stkopr <= 2'b01;

    end
    8'h0D : begin                  //POP
      wrtenb <= 1'b1;
      stkopr <= 2'b10;
    end

    8'hAC : begin                  //Halt (program termination)
      pcen <= 1'b0;
      opcode <= inst[31:24];
      $display(" Halt Triggered ");
    end
    endcase
    //execute
  end

  Writeback : begin
    pcen <= 1'b0;
    sel <= 1'b0;
    if(inst[31:24] == 8'h0D) begin    //If POP is triggered then write data into registerfile
      sel <= 1'b1;
      wrtenb <= 1'b0;
    end;
    we <= 1'b1;
    //writeback
  end
  endcase
  pst <= nxst;
end;
endmodule

module operationalx(opcode,dataA,dataB,out);
input [7:0] opcode;
input [7:0] dataA,dataB;
output reg [7:0] out;

always @(*) begin
 case(opcode)
 8'h00 : out = dataA & dataB; //AND
 8'h01 : out = dataA ^ dataB; //XOR
 8'h02 : out = dataA | dataB; //OR
 8'h03 : out = ~(dataA & dataB); //NAND
 8'h04 : out = dataA + dataB; //ADD
 8'h05 : out = dataA - dataB; //SUB
 8'hAC : out = out;           // No-operation 
 default : out = 8'h00;
 endcase;
end
endmodule

module instr(clk , insin , insout);
 input clk;
 input [31:0] insin;
 output reg [31:0] insout;

 always @(posedge clk) begin
   insout <= insin;
 end
endmodule

module comparitor(dataA,dataB,flags);
input [7:0] dataA,dataB;
output reg [2:0] flags;

initial begin
  flags = 3'b0;
end;

always @(*) begin
  if(dataA == dataB) begin
    flags = 3'b100; //Equal
  end else if (dataA >= dataB) begin
    flags = 3'b010; //Equal r Greater
  end else if (dataA <= dataB)begin
    flags = 3'b001; //Equal r Lesser
  end;
end
endmodule

module pccounter(clk,pcen,out,rst,jump_ad,jump_en);
input rst,clk,pcen,jump_en;
input [7:0] jump_ad;
output reg [7:0] out;

always @(posedge clk) begin 
  if(rst) begin 
    out <= 8'b0;
  end else if(jump_en) begin
    out <= jump_ad;
    $display(" PC counter jumped to -> %d ",jump_ad);
  end else if(pcen) begin
    out <= (out == 8'hFF ) ? 0 : out + 1;
  end 
end;
endmodule

module rom(addr,data);
input [7:0] addr;
output reg [31:0] data;

reg [31:0] mem [0:255];

initial begin
  mem[0] = 32'h07_00_00_00;
  mem[1] = 32'h07_01_00_01;
  mem[2] = 32'h04_00_01_02;
  mem[3] = 32'h03_02_00_05;
  mem[4] = 32'h0C_05_00_00;
  mem[5] = 32'h0D_00_00_06;
  mem[6] = 32'h09_05_06_08;
  mem[7] = 32'h06_06_00_07;
  mem[8] = 32'hAC_00_00_00;

end;

always @(*) begin
  if (addr < 9)
    data = mem[addr];
  else
    data = 32'b0;
end;

endmodule

module ram(addr,clk,wrtenb,datain,dataout,stkopr);
input [7:0] addr;
input [7:0] datain;
input [1:0] stkopr; // NOP -> 00 ; push - > 01 ; pop -> 10 ; NOP -> 11
input wrtenb,clk;
output reg [7:0] dataout;

reg [7:0] data [0:255];
reg [7:0] stkdata;
reg [7:0] stkpointer;

integer h;

initial begin
 stkdata = 8'h00;

 data[0] = 8'h32;
 data[1] = 8'h01;
 data[2] = 8'hA2;
 data[3] = 8'h39;

 for(h = 4 ; h < 256 ; h = h + 1) begin
  data[h] = 8'b0;
 end;
 stkpointer = 8'hAF;  // Starting stack address
end;

always @(posedge clk) begin
 if(wrtenb) begin
  if(stkopr == 2'b00 || stkopr == 2'b11) begin 
    data [addr] <= datain;
  end
  if(stkopr == 2'b01) begin                      // PUSH
    data[stkpointer] <= datain;
    stkpointer <= stkpointer - 1'b1;
    $display(" Pushed the data : %h -> [%h]",datain,stkpointer);
  end else if(stkopr == 2'b10) begin             // POP
    stkpointer <= stkpointer + 1'b1;
    stkdata <= data[stkpointer + 1'b1];
    $display(" Poped the data : [%h] -> %h",stkpointer + 1'b1,data[stkpointer+1'b1]);
  end;
 end
end;

always @(*) begin
  if(stkopr == 2'b10) begin
   dataout = stkdata;
  end else begin
   dataout = data[addr];
  end;
end;
endmodule;

module Regfile(we,clk,addr,wdata,wregdat,dataA,dataB,sel);
input we,clk,sel;
input [23:0] addr;
input [7:0] wdata,wregdat;
output reg [7:0] dataA , dataB;

reg [7:0] data [0:255];
integer i;

initial begin
  for(i = 0 ; i < 256 ; i = i + 1) begin
   data[i] = 8'b0;
  end;
end;

 
always @(posedge clk) begin
  // Memory operation
  if(we) begin 
    if(sel) begin 
      data [addr[7:0]] <= wregdat; // Data from ram is written into operand_A's location
      $display(" Write Register : R%0h <= %h ",addr[7:0],wregdat); //from ram
    end else begin 
      data [addr[7:0]] <= wdata;  // Data from alu is written into operand_A's location
      $display(" Write Register : R%0h <= %h ",addr[7:0],wdata); //from alu
    end;
  end;
end;

always @(*) begin
  dataA = data[addr[23:16]];
  dataB = data[addr[15:8]];
end
endmodule;
