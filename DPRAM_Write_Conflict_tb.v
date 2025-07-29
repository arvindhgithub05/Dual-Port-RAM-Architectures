`timescale 1ns / 1ps

module DPRAM_Write_Conflict_tb;

    parameter DATA_WIDTH = 8;
    parameter ADDR_WIDTH = 4;

    // Testbench signals
    reg                     clk_a, clk_b;
    reg                     we_a, we_b;
    reg  [ADDR_WIDTH-1:0]   addr_a, addr_b;
    reg  [DATA_WIDTH-1:0]   din_a, din_b;
    wire [DATA_WIDTH-1:0]   dout_a, dout_b;

    // DUT instantiation
    DPRAM_Write_Conflict #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) dut (
        .clk_a(clk_a),
        .we_a(we_a),
        .addr_a(addr_a),
        .din_a(din_a),
        .dout_a(dout_a),
        .clk_b(clk_b),
        .we_b(we_b),
        .addr_b(addr_b),
        .din_b(din_b),
        .dout_b(dout_b)
    );

    // Clock generation
    initial begin
        clk_a = 0;
        clk_b = 0;
        forever #5 clk_a = ~clk_a; // 10ns period
    end

    initial begin
        forever #7 clk_b = ~clk_b; // 14ns period (asynchronous)
    end

    // Test sequence
    initial begin
        $display("Starting Dual-Port RAM Conflict Safe Testbench");
        $monitor("T=%0t | A: we=%b addr=%0d din=%0h dout=%0h | B: we=%b addr=%0d din=%0h dout=%0h",
            $time, we_a, addr_a, din_a, dout_a, we_b, addr_b, din_b, dout_b);

        // Initialize
        we_a = 0; we_b = 0;
        addr_a = 0; addr_b = 0;
        din_a = 0; din_b = 0;

        // Wait few cycles
        #20;

        // Write from Port A to address 3
        @(posedge clk_a);
        we_a = 1; addr_a = 4'h3; din_a = 8'hA5;
        @(posedge clk_a);
        we_a = 0;

        // Write from Port B to address 7
        @(posedge clk_b);
        we_b = 1; addr_b = 4'h7; din_b = 8'h5A;
        @(posedge clk_b);
        we_b = 0;

        // Read back from A
        @(posedge clk_a);
        addr_a = 4'h3;
        @(posedge clk_a);

        // Read back from B
        @(posedge clk_b);
        addr_b = 4'h7;
        @(posedge clk_b);

        // Conflict test: Both write to address 5 at the same time
        @(posedge clk_a);
        addr_a = 4'h5; din_a = 8'hF0; we_a = 1;
        addr_b = 4'h5; din_b = 8'h0F; we_b = 1;
        @(posedge clk_b);
        we_a = 0; we_b = 0;

        // Read from both ports to address 5 to check conflict resolution
        @(posedge clk_a);
        addr_a = 4'h5;
        @(posedge clk_b);
        addr_b = 4'h5;

        #40;

        $display("End of simulation.");
        $finish;
    end

endmodule
