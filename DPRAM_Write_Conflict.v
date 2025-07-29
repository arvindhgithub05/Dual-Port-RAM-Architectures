/*
- Problem: If both clk_a and clk_b try to write to the same address in the same cycle, the behavior is unpredictable, especially on ASICs or FPGAs without true multi-port memory blocks.

To resolve write-write conflicts to the same address in dual-port RAM with independent clocks, we'll need to add a conflict detection mechanism and a priority scheme.
- A simple priority scheme (e.g., give Port A higher priority)
- Register updates only if no conflict OR controlled conflict resolution

NOTE: We do not use any synchronizer or cross-domain FIFO, we assume that the frequency of these conflicts are rare — this is unsafe if strict async protection is needed.
*/

module DPRAM_Write_Conflict #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4
)(
    input  wire                     clk_a,
    input  wire                     we_a,
    input  wire [ADDR_WIDTH-1:0]    addr_a,
    input  wire [DATA_WIDTH-1:0]    din_a,
    output reg  [DATA_WIDTH-1:0]    dout_a,

    input  wire                     clk_b,
    input  wire                     we_b,
    input  wire [ADDR_WIDTH-1:0]    addr_b,
    input  wire [DATA_WIDTH-1:0]    din_b,
    output reg  [DATA_WIDTH-1:0]    dout_b
);

    localparam RAM_DEPTH = 1 << ADDR_WIDTH;
    reg [DATA_WIDTH-1:0] mem [0:RAM_DEPTH-1];

    // Conflict detection (clock-domain crossing unsafe if async!)
    wire conflict = we_a && we_b && (addr_a == addr_b);

    // Priority-based write arbitration logic
    // Port A has higher priority in case of simultaneous write to same address

    // Port A operation
    always @(posedge clk_a) begin
        if (we_a && !(conflict && clk_b != clk_a)) begin
            mem[addr_a] <= din_a;
        end
        dout_a <= mem[addr_a];
    end

    // Port B operation
    always @(posedge clk_b) begin
        if (we_b) begin
            // Only write if no conflict or not same address
            if (!(conflict && clk_b != clk_a)) begin
                if (!(we_a && (addr_a == addr_b))) begin
                    mem[addr_b] <= din_b;
                end
            end
        end
        dout_b <= mem[addr_b];
    end

endmodule
