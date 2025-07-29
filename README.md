# Dual-Port-RAM-Architectures

1. Simple Dual Port RAM

✅ Features:
- Parameterized depth and width
- Dual independent ports (Port A and Port B)
- Separate read and write addresses, enables, and clocks
- Fully synthesizable and suitable for FPGA/ASIC design

2. Dual Port RAM - Banked Architecture

✅ Features:
- Banked Architecture:	RAM is divided into multiple independent banks
- Port Affinity:	Each port tries to access its own bank by default
- Arbitration Logic:	When both ports target the same bank, a priority scheme kicks in
- Priority Rule:	Lower port number has higher priority (Port 0 > Port 1 > Port 2 …)
- Parametric Design:	Supports NUM_BANKS, DATA_WIDTH, ADDR_WIDTH


✅ Benefits:
Bank parallelism improves throughput
Arbitration ensures safe simultaneous access
Priority logic gives you predictable resolution 

3. Dual Port RAM - Burst Transaction

✅ Features:
- Burst Mode: Supports burst reads/writes up to configurable burst_len
- Auto-increment: Address auto-increments during burst
- Pipelined Access:	Address generation and memory access separated
- Fully parameterized:	Data width, address width, burst length


✅ Independent Dual Port Operation
Both ports operate fully independently, supporting concurrent reads/writes and burst mode separately.

4. Dual Port RAM - Read After Write Hazard

✅ Features:
- Synchronous Reset:	Clears all validity bits at reset.
- Valid Bit Array:	Remembers which memory addresses have been written.
- Read-after-Write (RAW):	If Port A writes to an address and Port B reads the same address in the same cycle, it forwards the data directly.
- Invalid Read Handling:	Returns 32'hFFFFFFFF if Port B tries to read an address that hasn’t been written yet.

5. Dual Port RAM - Write Conflict Resolution

✅ Problem:
If both clk_a and clk_b try to write to the same address in the same cycle, the behavior is unpredictable, especially on ASICs or FPGAs without true multi-port memory blocks.

✅ Solution Approach:
- Conflict detection (when we_a and we_b are both high and addresses match)
- A simple priority scheme (e.g., give Port A higher priority)
- Register updates only if no conflict OR controlled conflict resolution
