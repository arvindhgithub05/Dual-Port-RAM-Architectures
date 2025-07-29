`timescale 1ns / 1ps

module DPRAM_Banked_Arch_tb;

    // Parameters
    parameter DATA_WIDTH = 8;
    parameter ADDR_WIDTH = 6;    // Total 64 addresses
    parameter NUM_BANKS  = 4;    // 4 banks => 2 bits for bank index

    // Derived parameter
    localparam BANK_ADDR_WIDTH = ADDR_WIDTH - $clog2(NUM_BANKS);
    localparam CLK_PERIOD = 10;

    // Testbench signals
    reg clk;

    reg                     we_a, we_b;
    reg  [ADDR_WIDTH-1:0]   addr_a, addr_b;
    reg  [DATA_WIDTH-1:0]   din_a, din_b;
    wire [DATA_WIDTH-1:0]   dout_a, dout_b;

    // DUT instantiation
    DPRAM_Banked_Arch #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .NUM_BANKS(NUM_BANKS)
    ) dut (
        .clk(clk),
        .we_a(we_a),
        .addr_a(addr_a),
        .din_a(din_a),
        .dout_a(dout_a),
        .we_b(we_b),
        .addr_b(addr_b),
        .din_b(din_b),
        .dout_b(dout_b)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // Test sequence
    initial begin
        $display("===== Starting Banked Dual-Port RAM Testbench =====");
        $monitor("T=%0t | A: we=%b addr=%0d din=%h dout=%h | B: we=%b addr=%0d din=%h dout=%h",
            $time, we_a, addr_a, din_a, dout_a, we_b, addr_b, din_b, dout_b);

        // Initialize
        we_a = 0; we_b = 0;
        addr_a = 0; addr_b = 0;
        din_a = 0; din_b = 0;

        // Wait a few cycles
        #(2 * CLK_PERIOD);

        // Test 1: Port A writes to Bank 0, Port B writes to Bank 1
        @(posedge clk);
        addr_a = 6'b000000;   // Bank 0
        din_a  = 8'hA1;
        we_a   = 1;

        addr_b = 6'b010000;   // Bank 1
        din_b  = 8'hB2;
        we_b   = 1;

        @(posedge clk);
        we_a = 0;
        we_b = 0;

        // Test 2: Readback both
        @(posedge clk);
        addr_a = 6'b000000;  // Should be A1
        addr_b = 6'b010000;  // Should be B2

        @(posedge clk);
        $display("Expect A=A1, B=B2");

        // Test 3: Conflict - Both write to Bank 2 at same time
        @(posedge clk);
        addr_a = 6'b100100; // Bank 2
        din_a  = 8'hCA;
        we_a   = 1;

        addr_b = 6'b100000; // Same Bank 2
        din_b  = 8'hCB;
        we_b   = 1;

        @(posedge clk);
        we_a = 0;
        we_b = 0;

        // Test 4: Read back both addresses in Bank 2
        @(posedge clk);
        addr_a = 6'b100100; // Expect CA
        addr_b = 6'b100000; // Expect 00 (CB write should have been ignored if A wrote same cycle)

        @(posedge clk);
        $display("Expect A=CA, B=00 or undefined depending on conflict resolution");

        // Test 5: Write B alone to Bank 3
        @(posedge clk);
        addr_b = 6'b110001; // Bank 3
        din_b  = 8'hD5;
        we_b   = 1;
        @(posedge clk);
        we_b = 0;

        // Read back from B
        @(posedge clk);
        addr_b = 6'b110001;
        @(posedge clk);

        #(2 * CLK_PERIOD);
        $display("===== End of Simulation =====");
        $finish;
    end

endmodule
