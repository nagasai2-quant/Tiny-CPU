module main;
  wire [19:0] rom_data,ins;
  wire [3:0] addr;
  wire [2:0] flags;
  wire [3:0] adr,jump_ad;
  wire [11:0] raddr;
  reg rst,clk;
  wire [3:0] out,opcode,dataA,dataB,wreg;
  wire [3:0] dout;
  wire pcen,we,wrtenb,sel,jump_en;
  
  pccounter pcc(clk,pcen,addr,rst,jump_ad,jump_en);
  rom memo(addr,rom_data);
  ram ramem(adr,clk,wrtenb,dataA,wreg);
  instr insta(clk,rom_data,ins);
  control cont(clk,ins,we,wrtenb,pcen,opcode,raddr,adr,sel,flags,jump_ad,jump_en);
  operationalx opox(opcode,dataA,dataB,out);
  comparitor comp(dataA,dataB,flags);
  Regfile regf(we,clk,raddr,out,wreg,dataA,dataB,sel);

  //Data bits info
  // 4 bits - Opcode noted : opcode / inst[19:16] ;
  // 12 bits - {4 - 4 - 4} (1-> data1 ; 2 -> data2 ; 3 -> saving) addr noted : 'raddr' ;
  // 4 bits - Ram addr noted : 'adr' OR jump addr ;

  //Mishcalleous info
  // adr -> ram wrting or ram reading address ;
  // raddr -> operation address data1,data2,writing output ;

  //Opcodes :
  // 0000 -> AND 
  // 0001 -> XOR
  // 0010 -> OR
  // 0011 -> NAND
  // 0100 -> STORE
  // 0101 -> LOAD
  // 0110 -> JUMP
  // 0111 -> BRANCH (Equal)
  // 1000 -> BRANCH (Greater)
  // 1001 -> BRANCH (Lesser)

  initial clk = 0;
  always #5 clk = ~clk;

  initial begin
    $dumpfile("ramemory.vcd");
    $dumpvars(0,main);
    $display("         Data         |  PC  | Opcode |     Data    | Flags |  Out  |");
    $monitor(" %20b | %4b |  %4b  | %4b | %4b |  %3b  | %4b ", ins, addr, opcode, dataA, dataB,flags,out);
    
    rst = 1; #10 
    rst = 0; #180
    $finish;
  end;
  
endmodule

module control(clk,inst,we,wrtenb,pcen,opcode,raddr,adr,sel,flags,jump_ad,jump_en);
input clk;
input [2:0] flags;
input [19:0] inst;
output reg [3:0] opcode;
output reg [3:0] adr,jump_ad;
output reg [11:0] raddr;
output reg pcen,we,wrtenb,sel,jump_en;

reg [1:0] nxst , pst;

localparam Fetch = 2'b00 , Decode = 2'b01 , Execute = 2'b10 , Writeback = 2'b11;

initial begin 
  pst = Fetch;
  opcode = 0;
  pcen = 0;
  wrtenb = 0;
  we = 0;
  jump_ad = 4'b0;
end;

always @(*) begin
  nxst = pst;
  case(pst)
  Fetch : nxst = Decode;
  Decode : nxst = Execute;
  Execute : begin 
    if(inst[19:16] > 4'b0011) begin
       nxst = Fetch;
    end else begin
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
    //Fetch
  end
    
  Decode : begin
     pcen <= 1'b1;
     we <= 1'b0;
     sel <= 1'b0;
     raddr <= inst[15:4]; // <= Data dependancy hazard if you use this statement in next state a.k.a 'Execute' 
     //decode 
  end

  Execute : begin
    pcen <= 1'b0;
    we <= 1'b0;
    sel <= 1'b0;
    wrtenb <= 1'b0;
    jump_en <= 1'b0;
    case(inst[19:16]) 
    4'b0000 : opcode <= inst[19:16];  
    4'b0001 : opcode <= inst[19:16];  
    4'b0010 : opcode <= inst[19:16];  
    4'b0011 : opcode <= inst[19:16];  
    4'b0100 : begin
      adr <= inst[3:0];
      wrtenb <= 1'b1;
    end 
    4'b0101 : begin                  // LOAD
      adr <= inst[3:0];
      we <= 1'b1;
      sel <= 1'b1;
      wrtenb <= 1'b0;
      raddr <= inst[15:4];
    end
    4'b0110 : begin                  //JUMP 
      jump_ad <= inst[3:0];          //Jump addr
      jump_en <= 1'b1;
    end
    4'b0111 : begin                  //BEQ
      if(flags == 3'b100) begin
        jump_ad <= inst[3:0];
        jump_en <= 1'b1;
        $display(" BEQ triggered -> %d",inst[3:0]);
      end
    end
    4'b1000 : begin                  //BGT
      if(flags == 3'b010) begin
        jump_ad <= inst[3:0];
        jump_en <= 1'b1;
        $display(" BGT triggered -> %d",inst[3:0]);
      end
    end
    4'b1001 : begin                  //BLT
      if(flags == 3'b001) begin
        jump_ad <= inst[3:0];
        jump_en <= 1'b1;
        $display(" BLT triggered -> %d",inst[3:0]);
      end
    end

    4'b1111 : begin
      pcen <= 1'b0;
    end
    endcase
    //execute
  end

  Writeback : begin
    pcen <= 1'b0;
    sel <= 1'b0;
    we <= 1'b1;
    //writeback
  end
  endcase
  pst <= nxst;
end;
endmodule

module operationalx(opcode,dataA,dataB,out);
input [3:0] opcode;
input [3:0] dataA,dataB;
output reg [3:0] out;

always @(*) begin
 case(opcode)
 4'b0000 : out = dataA & dataB; //AND
 4'b0001 : out = dataA ^ dataB; //XOR
 4'b0010 : out = dataA | dataB; //OR
 4'b0011 : out = ~(dataA & dataB); //NAND
 endcase;
end
endmodule

module instr(clk , insin , insout);
 input clk;
 input [19:0] insin;
 output reg [19:0] insout;

 always @(posedge clk) begin
   insout <= insin;
 end
endmodule

module comparitor(dataA,dataB,flags);
input [3:0] dataA,dataB;
output reg [2:0] flags;

initial begin
  flags = 0;
end;

always @(*) begin
  if(dataA == dataB) begin
    flags = 3'b100; //Equal
  end else if (dataA > dataB) begin
    flags = 3'b010; //Greater
  end else begin
    flags = 3'b001; //Lesser
  end;
end
endmodule

module pccounter(clk,pcen,out,rst,jump_ad,jump_en);
input rst,clk,pcen,jump_en;
input [3:0] jump_ad;
output reg [3:0] out;

always @(posedge clk) begin 
  if(rst) begin 
  out <= 4'b0;
  end else if(jump_en) begin
  out <= jump_ad;
  $display(" PC counter jumped to -> %d ",jump_ad);
  end else if(pcen) begin
  out <= out + 1;
  end 
end;
endmodule

module rom(addr,data);
input [3:0] addr;
output reg [19:0] data;

reg [19:0] mem [0:15];

initial begin
  mem[0] = 20'b0101_0000_0000_0000_0000;
  mem[1] = 20'b0101_0000_0000_0001_0001;
  mem[2] = 20'b1001_0000_0001_0000_0101;
  mem[3] = 20'b0100_0000_0000_0000_0100;
  mem[4] = 20'b0000_0000_0000_0000_0000;
  mem[5] = 20'b0100_0001_0000_0000_0101;
  mem[6] = 20'b0110_0000_0000_0000_0110;

end;

always @(*) begin
  if (addr < 7)
    data = mem[addr];
  else
    data = 20'b0;
end
endmodule

module ram(addr,clk,wrtenb,datai,dataout);
input [3:0] addr;
input [3:0] datai;
input wrtenb,clk;
output reg [3:0] dataout;

reg [3:0] data [0:15];
integer h;

initial begin
 data[0] = 4'b0101;
 data[1] = 4'b1010;
 data[2] = 4'b1001;
 data[3] = 4'b0110;

 for(h = 4;h < 16;h = h + 1) begin
  data[h] = 4'b0;
end;
end;

always @(posedge clk) begin
 if(wrtenb) begin
 data [addr] <= datai;
 $display(" Write RAM : R%0d <= %d",addr,datai);
 end;
end;

always @(*) begin
 dataout = data[addr]; 
end
endmodule

module Regfile(we,clk,addr,wdata,wregdat,dataA,dataB,sel);
input we,clk,sel;
input [11:0] addr;
input [3:0] wdata,wregdat;
output reg [3:0] dataA , dataB;

reg [3:0] data [0:15];
integer i;

initial begin
  for(i = 0 ; i < 16 ; i = i + 1) begin
   data[i] = 4'b0;
  end;
end;

always @(posedge clk) begin
  if(we) begin
   if(sel) begin 
    data [addr[3:0]] <= wregdat;
    $display(" Write Register : R%0d <= %d ",addr[3:0],wregdat); //from ram
   end else begin 
    data [addr[3:0]] <= wdata;
    $display(" Write Register : R%0d <= %d ",addr[3:0],wdata); //from alu
   end;
  end;
end;

always @(*) begin
  dataA = data[addr[11:8]];
  dataB = data[addr[7:4]];
end
endmodule
