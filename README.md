# Tiny-CPU
A simple 4 Bit CPU built using Verilog HDL , following Harvard Architecture by performing operation from ROM and seperate RAM for Data related operations

**Supports Various Functions as :**
AND - performs AND operation on 2 operands
OR - performs OR operation on 2 operands
XOR - performs XOR operation on 2 operands
NAND - performs NAND operation on 2 operands
LOAD - Loads a value from RAM to Register
STORE - Stores a value from Register to RAM
JMP - Jumps to a particular location
BLT - Branches to a location if operand it less than mentioned value
BEQ - Branches to a location if operand it equal to the mentioned value
BGT - Branches to a location if operand it greater than mentioned value

**Architecture :** 

**Program Counter
      |
      V
Instruction Memory (ROM)
      |
      V
Instruction Register
      |
      V
 Control Unit (FSM)
      |
      V
Register  <->  RAM
      |
      V
     ALU
      |
      V 
   WriteBack**
      

**Features :**
Harvard Architecture
Fetch - Decode - Execute Cycle
FSM Based Control Unit
Register and RAM for Memory Handling
Program Counter
Instruction Register
Conditional Branching
Unconditional Jump


**Future Improvements :**
1. Adding more feature as MOV , Interrupt , Halt , Call , etc.
2. Pipelining to speed up the process.
3. Adding Arithmetic Operations like ADD ,SUB.
4. Interrupt Handling
5. Stack pointer
