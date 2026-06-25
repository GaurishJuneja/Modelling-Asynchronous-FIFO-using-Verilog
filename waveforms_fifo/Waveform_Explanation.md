# Waveform Simulation Guide

This directory contains the verification waveforms for the Asynchronous Dual-Clock FIFO simulation. The captures are organized chronologically to illustrate the full lifecycle of the FIFO—from power-on reset to complete memory drainage.

---

## 📋 Signal Glossary

When opening any of the waveform files, use this quick reference to understand what each signal row represents:

| Signal Group | Variable Name | Purpose |
| --- | --- | --- |
| **Global Controls** | `wrst_n` / `rrst_n` | Active-low reset switches for the write and read sides. |
| **Write Domain** | `wclk` | The fast clock running the data-entry side (50 MHz). |
|  | `winc` | Write Enable. When high, data is pushed into the FIFO. |
|  | `wdata[7:0]` | The actual 8-bit data byte trying to enter the FIFO. |
|  | `wfull` | The "Stop" sign. Trips high when the FIFO is 100% full. |
| **Clock Crossing** | `wptr` / `rptr` | The internal address pointers converted to Gray Code. |
|  | `rq2_wptr` / `wq2_rptr` | Pointers after they safely cross the clock boundary through the 2-flop synchronizers. |
| **Read Domain** | `rclk` | The slow clock running the data-exit side (14.28 MHz). |
|  | `rinc` | Read Enable. When high, data is pulled out of the FIFO. |
|  | `rdata[7:0]` | The active data byte currently being read out. |
|  | `rempty` | The "Empty" sign. Trips high when there is no data left to read. |
| **Verification** | `verif_wdata[7:0]` | The testbench tracking register used to verify that `rdata` is perfectly correct. |

---

## 📖 The 3-Act Simulation Storyline

* **Phase 1: Initial Write Operations (FIFO_waveform_1 & FIFO_waveform_2)**: The simulation starts by focusing entirely on the write path. The write domain runs at 50 MHz, filling the empty FIFO with data bytes while the read domain finishes its initialization and pointer synchronization.

* **Phase 2: Simultaneous Reading and Writing (FIFO_waveform_3 – FIFO_waveform_6)**: Both clock domains operate at the same time. Because data is written much faster than it is read, the FIFO memory array repeatedly reaches its maximum capacity. This triggers the wfull flag, which automatically pauses the write side to prevent data overflow until the read side clears out space.

* **Phase 3: Final Data Drainage (FIFO_waveform_7 & FIFO_waveform_8)**: The testbench stops generating new data, and the write side goes completely idle. The read domain continues operating on its own to cleanly empty out the remaining data from the memory array. Once the last byte is removed, the rempty flag goes high to safely stop the reader and end the simulation.

## 🔍 Detailed Waveform Breakdown

### FIFO_waveform_1.png (0 ns – 750 ns)

* **What it shows:** Power-on reset initialization and the very first writes.
* **Details:** The simulation starts with both domains in reset. At 100 ns, the write reset (`wrst_n`) goes high. The write clock (`wclk`) begins pounding data bytes (`24`, `81`, `09`...) into the memory array. Because the read domain is still reset, the FIFO is simply collecting data.

### FIFO_waveform_2.png (550 ns – 1300 ns)

* **What it shows:** The reader wakes up and synchronizers filter the data.
* **Details:** The read reset (`rrst_n`) is released at 525 ns. There is a tiny 2-3 cycle gap while the internal flip-flop synchronizers safely pass the write pointer information into the read domain. As soon as it clears, `rempty` drops to 0, `rinc` goes high, and the first byte (`24`) appears on `rdata`.

### FIFO_waveform_3.png (1200 ns – 2000 ns)

* **What it shows:** The FIFO hitting maximum capacity.
* **Details:** Because the write clock is much faster than the read clock, the FIFO fills up to its limit. The `wfull` flag shoots up to 1. The testbench handles this backpressure perfectly by instantly dropping `winc` to 0 and freezing `wdata` to protect against data overflow.

### FIFO_waveform_4.png (1800 ns – 2600 ns)

* **What it shows:** Continuous dynamic interlocking.
* **Details:** This wave captures the steady-state balancing act. The slow reader pulls a byte out, clearing an empty slot. The write side registers this change, drops `wfull` to 0 for a split second, fires another byte in, and hits the "Full" wall again.

### FIFO_waveform_5.png (2500 ns – 3300 ns)

* **What it shows:** Second generation data burst.
* **Details:** The testbench launches its second wave of data entry. Pointers advance in Gray code order on every clock tick, proving that flag generation remains perfectly stable even under non-stop data bus toggling.

### FIFO_waveform_6.png (3200 ns – 4500 ns)

* **What it shows:** The writer finishes its job.
* **Details:** The testbench has written its final assigned verification byte (`0A`). The write enable line (`winc`) drops to 0 and idles permanently. The read domain continues running at 14.28 MHz, chipping away at the data mountain left inside the FIFO.

### FIFO_waveform_7.png (4400 ns – 5800 ns)

* **What it shows:** The autonomous draining phase.
* **Details:** The write domain is completely dead and quiet. The reader runs solo, pulling the remaining data elements out of the memory array one by one. You can see `rdata` tracking `verif_wdata` with absolute precision.

### FIFO_waveform_8.png (5600 ns – 7150 ns)

* **What it shows:** Final data drain and clean shutdown.
* **Details:** The reader pulls the absolute last byte (`C5`) out of the FIFO. The read pointer officially catches up to the write pointer, forcing the `rempty` flag back up to 1. The reader turns off, the simulation padding completes, and the testbench safely exits with a 100% pass rate.
