# Asynchronous FIFO Design in Verilog

## Overview

This project implements a parameterizable **Asynchronous FIFO (First-In-First-Out)** in Verilog. The design enables safe data transfer between two independent clock domains using Gray-code pointers and clock-domain crossing (CDC) synchronization techniques.

Asynchronous FIFOs are widely used in digital systems whenever data must be transferred between circuits operating at different clock frequencies. Common applications include:

* Processor-to-peripheral communication
* Network interfaces
* High-speed data acquisition systems
* SoC interconnects
* FPGA and ASIC designs involving multiple clock domains

The design is fully synthesizable and verified using a self-checking Verilog testbench.

---

## What is an Asynchronous FIFO?

A FIFO stores data in the order it is written and retrieves it in the same order.

Unlike a synchronous FIFO, where read and write operations share the same clock, an asynchronous FIFO uses:

* **Write Clock (`wr_clk`)**
* **Read Clock (`rd_clk`)**

These clocks operate independently and may have different frequencies.

### Conceptual Block Diagram

<img width="344" height="154" alt="fifo" src="https://github.com/user-attachments/assets/d618c2a4-4012-4c78-9959-a1eb393c5633" />



Data is written into the FIFO using the write clock and read out using the read clock while maintaining data integrity across clock domains.

---

## Key Design Features

* Parameterizable data width and FIFO depth
* Independent read and write clock domains
* Gray-code read/write pointers
* Two-stage synchronizers for CDC
* Full flag generation
* Empty flag generation
* Synthesizable RTL implementation
* Self-checking testbench
* GTKWave-based waveform verification

---

## Design Architecture

The FIFO is divided into multiple modules to improve readability, modularity, and reusability.

<img width="768" height="434" alt="asynchronous-fifo" src="https://github.com/user-attachments/assets/ce9edbe0-de1d-491c-a9a4-59e9238a8e37" />

### Design Flow

1. Data enters through the write interface.
2. Write pointer advances using the write clock.
3. Pointer information is converted to Gray code.
4. Gray-coded pointers are synchronized across clock domains.
5. Read pointer advances using the read clock.
6. Full and Empty conditions are generated using synchronized pointer values.

---

# Repository Structure

```text
async_fifo/
│
├── src_fifo/
│   ├── fifo_memory.v
│   ├── r_pointer_empty.v
│   ├── sync_r2w.v
│   ├── sync_w2r.v
│   ├── top.v
│   └── w_ptr_full.v
│
├── tb_fifo/
│   └── tb.v
│
├── waveforms_fifo/
│   ├── FIFO_Waveform_1.png
│   ├── FIFO_Waveform_2.png
│   ├── FIFO_Waveform_3.png
│   ├── FIFO_Waveform_4.png
│   ├── FIFO_Waveform_5.png
│   ├── FIFO_Waveform_6.png
│   ├── FIFO_Waveform_7.png
│   ├── FIFO_Waveform_8.png
│   └── Waveform_Explanation.md
│
└── README.md
```

---

# Source File Description

## fifo_memory.v

Implements the FIFO storage array.

### Responsibilities

* Stores incoming data words
* Handles write operations
* Handles read operations
* Provides data interface between read and write domains

---

## w_ptr_full.v

Write-side control logic.

### Responsibilities

* Maintains write pointer
* Generates Gray-code write pointer
* Detects FIFO full condition
* Prevents writes when FIFO is full

---

## r_pointer_empty.v

Read-side control logic.

### Responsibilities

* Maintains read pointer
* Generates Gray-code read pointer
* Detects FIFO empty condition
* Prevents reads when FIFO is empty

---

## sync_r2w.v

Read-pointer synchronizer.

### Responsibilities

* Transfers Gray-coded read pointer into the write clock domain
* Uses a two-flop synchronizer
* Reduces metastability risk

---

## sync_w2r.v

Write-pointer synchronizer.

### Responsibilities

* Transfers Gray-coded write pointer into the read clock domain
* Uses a two-flop synchronizer
* Enables safe CDC operation

---

## top.v

Top-level integration module.

### Responsibilities

* Instantiates all FIFO submodules
* Connects memory, pointers, and synchronizers
* Provides external FIFO interface

---

# Testbench

## tb.v

A self-checking verification environment used to validate FIFO functionality.

### Verification Objectives

* Reset behavior
* Data integrity
* Full condition detection
* Empty condition detection
* Simultaneous read and write operations
* Pointer wraparound behavior
* Clock-domain crossing functionality

The testbench automatically reports PASS/FAIL status based on verification results.




---

# Waveform Verification

The repository includes waveform captures generated using GTKWave.

Location:

```text
waveforms_fifo/
```

Files:

```text
FIFO_Waveform_1.png
FIFO_Waveform_2.png
...
FIFO_Waveform_8.png
```

Detailed signal descriptions and waveform interpretations can be found in:

```text
waveforms_fifo/Waveform_Explanation.md
```

The waveform set demonstrates:

* FIFO reset operation
* Data write transactions
* Data read transactions
* Full flag assertion
* Empty flag assertion
* Pointer synchronization
* Simultaneous read/write behavior
* FIFO wraparound operation

---

<img width="1616" height="407" alt="FIFO_Waveform_1" src="https://github.com/user-attachments/assets/a81ada7e-a585-4648-af5d-b9d5a1d8e688" />
A sample waveform has been attached (FIFO_Waveform_1.png).

# Simulation

Simulation was performed using:

* Icarus Verilog
* GTKWave

### Compile

```bash
iverilog -I src_fifo -o sim tb_fifo/tb.v src_fifo/*.v
```

### Run

```bash
vvp sim
```

### Open Waveforms

```bash
gtkwave async_fifo1_tb.vcd
```

---

# CDC Technique Used

To safely transfer information between clock domains, the design uses:

### Gray-Code Pointers

Only one bit changes between successive Gray-code values, reducing the chance of synchronization errors during clock-domain crossing.

### Two-Flop Synchronizers

Each Gray-coded pointer passes through a two-stage synchronizer before being used in the opposite clock domain.

This combination is a widely adopted industry approach for asynchronous FIFO implementation.

---

# Learning Outcomes

This project demonstrates practical understanding of:

* Verilog RTL design
* Clock Domain Crossing (CDC)
* Gray-code counters
* FIFO architectures
* Synchronizer design
* Digital verification methodology
* GTKWave debugging and analysis
* Modular hardware design practices

---

# Author
Gaurish Juneja

