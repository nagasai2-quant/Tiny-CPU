# Tiny-CPU
A simple 8 Bit CPU built using Verilog HDL , following Harvard Architecture by performing operation from ROM and seperate RAM for Data related operations

**Supports Various Functions as :**
1. AND - performs AND operation on 2 operands
2. OR - performs OR operation on 2 operands
3. XOR - performs XOR operation on 2 operands
4. NAND - performs NAND operation on 2 operands
5. ADD - performs Arithmetic Addition operation on 2 operands
6. SUB - performs Arithmetic Subtraction operation on 2 operands
7. LOAD - Loads a value from RAM to Register
8. STORE - Stores a value from Register to RAM
9. JMP - Jumps to a particular location (Unconditional jump)
10. JBE - Jump to a location if operand it less than or equal to mentioned value
11. JE - Jump to a location if operand it equal to the mentioned value
12. JAE - Jump to a location if operand it greater than or equal to mentioned value
13. HALT - Terminate the Program

**Architecture :** 

_Program Counter -  >
Instruction Memory (ROM) - >
Instruction Register - >
 Control Unit (FSM) - >
 [ Register  <->  RAM ]
     - > 
     ALU
      - > 
   WriteBack_
      

**Features :**
1. Harvard Architecture
2. Fetch - Decode - Execute Cycle
3. FSM Based Control Unit
4. Register and RAM for Memory Handling
5. Program Counter
6. Instruction Register
7. Conditional Branching
8. Unconditional Jump
9. Stack operations (Push , Pop)

**Future Improvements :**
1. Adding more feature as MOV , Interrupt , Call , etc.
2. Adding a C++ Assembler which converts ALP into the machine code , which helps performing coding.
3. Pipelining to speed up the process.
4. Interrupt Handling.
