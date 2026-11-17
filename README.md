

# SRAM Built-In Self-Test (MBIST) Controller Using Verilog HDL

## Project Overview
This project implements and verifies an SRAM Built-In Self-Test (MBIST) controller using Verilog HDL. The controller uses the March C- algorithm to test a behavioral 16 × 8 SRAM memory and detect memory faults.

The project demonstrates normal SRAM testing and fault detection through an intentionally faulty SRAM model.

## Objectives
- Design an FSM-based MBIST controller.
- Implement the March C- memory testing algorithm.
- Develop behavioral SRAM models.
- Verify normal memory operation.
- Demonstrate fault detection using fault injection.

## Architecture
The project consists of:
- MBIST Controller: Controls the memory test sequence.
- SRAM Model: Represents a 16 × 8 SRAM.
- Faulty SRAM Model: Introduces an intentional memory fault.
- Testbenches: Verify normal operation and fault detection.

## March C- Algorithm
The controller performs the following operations:

1. ↑ (w0)
2. ↑ (r0, w1)
3. ↑ (r1, w0)
4. ↓ (r0, w1)
5. ↓ (r1, w0)
6. ↑ (r0)

Here, ↑ represents ascending address order and ↓ represents descending address order. `r` means read and `w` means write.

## Tools and Technologies
- Verilog HDL
- Icarus Verilog
- GTKWave
- OSS CAD Suite
- Visual Studio Code

## Simulation Results

### Normal SRAM Test
The controller successfully completes the March C- test on the normal SRAM model.

Expected result:
- `done = 1`
- `error = 0`
- PASS

### Fault Injection Test
An intentional fault is introduced into the faulty SRAM model. The controller detects the resulting data mismatch.

Expected result:
- `done = 1`
- `error = 1`
- Fault detected

## Project Structure
```text
SRAM-MBIST-Verilog/
├── rtl/
│   ├── mbist_controller.v
│   ├── sram_model.v
│   └── sram_model_faulty.v
├── tb/
│   ├── mbist_tb.v
│   └── mbist_fault_tb.v
├── sim/
│   ├── mbist_wave.vcd
│   └── mbist_fault_wave.vcd
├── docs/
│   ├── SRAM_MBIST_Project_Report.pdf
│   ├── normal_simulation.png
│   └── fault_detection.png
└── README.md
```

## Project Scope
This is a simulation-based academic project using behavioral SRAM models. It demonstrates the design and verification of an MBIST controller and does not represent a physical SRAM implementation.

## Author
Lakshya

**Project:** VLSI Design Mini Project

## How to Run the Simulation

### Prerequisites
Install:
- Icarus Verilog
- GTKWave

### 1. Clone the repository
```bash
git clone https://github.com/YOUR_USERNAME/SRAM-MBIST-Verilog.git
cd SRAM-MBIST-Verilog
```

### 2. Run the normal SRAM test
```bash
iverilog -g2012 -o mbist_test.vvp rtl/sram_model.v rtl/mbist_controller.v tb/mbist_tb.v
vvp mbist_test.vvp
```

### 3. Run the fault injection test
```bash
iverilog -g2012 -o mbist_fault_test.vvp rtl/sram_model_faulty.v rtl/mbist_controller.v tb/mbist_fault_tb.v
vvp mbist_fault_test.vvp
```

### 4. View waveforms
```bash
gtkwave sim/mbist_wave.vcd
gtkwave sim/mbist_fault_wave.vcd
```

**Note:** Run the commands from the project root directory. Ensure the module names and file paths match the uploaded source files.

