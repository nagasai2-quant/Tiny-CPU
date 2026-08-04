# Tiny-CPU
A simple 4 Bit CPU built using Verilog HDL , following Harvard Architecture by performing operation from ROM and seperate RAM for Data related operations

**Supports Various Functions as :**
1. AND - performs AND operation on 2 operands
2. OR - performs OR operation on 2 operands
3. XOR - performs XOR operation on 2 operands
4. NAND - performs NAND operation on 2 operands
5. LOAD - Loads a value from RAM to Register
6. STORE - Stores a value from Register to RAM
7. JMP - Jumps to a particular location
8. BLT - Branches to a location if operand it less than mentioned value
9. BEQ - Branches to a location if operand it equal to the mentioned value
10. BGT - Branches to a location if operand it greater than mentioned value

**Architecture :** 
_
**Program Counter -  >
Instruction Memory (ROM) - >
Instruction Register - >
 Control Unit (FSM) - >
 [ Register  <->  RAM ]
     - > 
     ALU
      - > 
   WriteBack**_
      

**Features :**
1. Harvard Architecture
2. Fetch - Decode - Execute Cycle
3. FSM Based Control Unit
4. Register and RAM for Memory Handling
5. Program Counter
6. Instruction Register
7. Conditional Branching
8. Unconditional Jump


**Future Improvements :**
1. Adding more feature as MOV , Interrupt , Halt , Call , etc.
2. Pipelining to speed up the process.
3. Adding Arithmetic Operations like ADD ,SUB.
4. Interrupt Handling
5. Stack pointer
