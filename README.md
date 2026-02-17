# 32-bit MIPS Pipelined Processor

A high-performance, structural VHDL implementation of a **5-stage pipelined MIPS processor**. This design features a full instruction cycle—from fetch to write-back—with dedicated pipeline registers to ensure efficient execution and a modular control unit for instruction decoding.



## Architecture Overview

The processor is split into five distinct stages, separated by intermediate registers (IF/ID, ID/EX, EX/MEM, MEM/WB) to allow parallel instruction processing:

1.  **Instruction Fetch (IF):** Manages the Program Counter (PC) and retrieves instructions from a 64x32-bit ROM. Includes logic for jumps and branches.
2.  **Instruction Decode (ID):** Decodes the instruction, accesses the 32-register File, and performs sign/zero extension for immediates.
3.  **Execute (EX):** The ALU performs arithmetic, logic, and shift operations. It also calculates branch target addresses and evaluates branch conditions (Zero, GTZ).
4.  **Data Memory (MEM):** Handles Load/Store operations using a synchronous RAM module.
5.  **Write Back (WB):** Selects the final data (either from memory or the ALU) to be written back into the Register File.

---

## Instruction Set Support

The processor is capable of executing a variety of instruction types:

| Category | Instructions |
| :--- | :--- |
| **Arithmetic** | `ADD`, `ADDI`, `SUB` |
| **Logic** | `AND`, `OR`, `SLT` (Set Less Than) |
| **Shifts** | `SLL` (Logic Left), `SRL` (Logic Right), `SLLV` (Variable Left Shift) |
| **Memory** | `LW` (Load Word), `SW` (Store Word) |
| **Control** | `BEQ` (Branch if Equal), `BGTZ` (Branch if Greater than Zero), `J` (Jump), `JR` (Jump Register) |

---

## Component Breakdown

* **`test_env.vhd`**: The top-level entity that glues the pipeline together and interfaces with FPGA peripherals.
* **`IFetch.vhd`**: Contains the Instruction Memory (ROM) and PC update logic.
* **`id.vhd`**: Houses the Register File and immediate extension logic.
* **`EX.vhd`**: The Execution unit featuring the ALU and branch address calculation.
* **`uc.vhd`**: The Main Control Unit that generates all control signals based on the opcode.
* **`mem.vhd`**: The Data Memory (RAM) implementation.
* **`SSD.vhd`**: Seven-segment display driver for real-time hardware debugging.
* **`MPG.vhd`**: Mono-pulse generator for debouncing physical buttons.

---

## Hardware Interfacing (FPGA)

This project is designed to be tested on an FPGA board (such as the Basys 3). You can monitor the internal state of the processor using the onboard switches and 7-segment display:

### Display Multiplexer (`sw[7:5]`)
Use these switches to select what is shown on the **Seven Segment Display**:
* `000`: Current Instruction
* `001`: Current PC
* `010`: Read Data 1 (RD1)
* `011`: Read Data 2 (RD2)
* `100`: Extended Immediate
* `101`: ALU Result
* `110`: Memory Data (from RAM)
* `111`: Final Write-Back Data

### Controls
* **`btn[0]`**: Manual Clock (Advance the pipeline by one cycle).
* **`btn[1]`**: System Reset (Clear PC and registers).
* **`leds`**: Provide visual feedback for control signals like `RegWrite`, `MemWrite`, and `Jump`.

---

### How to Run
1.  Add all `.vhd` files to your Vivado/Quartus project.
2.  Set `test_env.vhd` as the Top Level entity.
3.  Assign pins according to your specific FPGA board constraints.
4.  Generate Bitstream and Program the device.
