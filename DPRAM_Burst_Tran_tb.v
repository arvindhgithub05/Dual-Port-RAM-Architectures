`timescale 1ns / 1ps

module DPRAM_Burst_Tran_tb;

    // ===============================
    // Parameters
    // ===============================
    parameter DATA_WIDTH = 8;
    parameter ADDR_WIDTH = 6;           // 64 memory locations
    parameter MAX_BURST_LEN = 4;

    // ===============================
    // Testbench signals
    // ===============================
    reg clk;

    reg                      we_a, we_b;
    reg                      burst_en_a, burst_en_b;
    reg  [$clog2(MAX_BURST_LEN)-1:0] burst_len_a, burst_len_b;
    reg  [ADDR_WIDTH-1:0]    base_addr_a, base_addr_b;
    reg  [DATA_WIDTH-1:0]    din_a, din_b;
    wire [DATA_WIDTH-1:0]    dout_a, dout_b;

    // ===============================
    // DUT instantiation
    // ===============================
    DPRAM_Burst_Tran #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .MAX_BURST_LEN(MAX_BURST_LEN)
    ) dut (
        .clk(clk),
        .we_a(we_a),
        .burst_en_a(burst_en_a),
        .burst_len_a(burst_len_a),
        .base_addr_a(base_addr_a),
        .din_a(din_a),
        .dout_a(dout_a),

        .we_b(we_b),
        .burst_en_b(burst_en_b),
        .burst_len_b(burst_len_b),
        .base_addr_b(base_addr_b),
        .din_b(din_b),
        .dout_b(dout_b)
    );

    // ===============================
    // Clock Generation
    // ===============================
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 10ns clock period
    end

    // ===============================
    // Test Sequence
    // ===============================
    initial begin
        $display("==== Dual Port RAM Burst Mode Testbench ====");
        $monitor("T=%0t | A: addr=%0d din=%0h dout=%0h | B: addr=%0d din=%0h dout=%0h",
                  $time, base_addr_a, din_a, dout_a, base_addr_b, din_b, dout_b);

        // === INIT ===
        we_a = 0; we_b = 0;
        burst_en_a = 0; burst_en_b = 0;
        burst_len_a = 0; burst_len_b = 0;
        base_addr_a = 0; base_addr_b = 0;
        din_a = 0; din_b = 0;

        #(2*10);

        // === TEST 1: Port A Burst Write to address 0 ===
        @(posedge clk);
        base_addr_a = 6'd0;
        burst_len_a = 2'd3;
        burst_en_a  = 1;
        we_a        = 1;

        repeat (4) begin
            @(posedge clk);
            din_a = din_a + 8'h11;  // Data: 11, 22, 33, 44
        end

        @(posedge clk);
        burst_en_a = 0;
        we_a = 0;

        // === TEST 2: Port B Burst Write to address 16 ===
        @(posedge clk);
        base_addr_b = 6'd16;
        burst_len_b = 2'd3;
        burst_en_b  = 1;
        we_b        = 1;
        din_b       = 8'hAA;

        repeat (4) begin
            @(posedge clk);
            din_b = din_b + 8'h11;  // Data: AA, BB, CC, DD
        end

        @(posedge clk);
        burst_en_b = 0;
        we_b = 0;

        // === TEST 3: Port A Burst Read from address 0 ===
        @(posedge clk);
        base_addr_a = 6'd0;
        burst_len_a = 2'd3;
        burst_en_a = 1;
        we_a = 0;

        repeat (4) @(posedge clk);
        burst_en_a = 0;

        // === TEST 4: Port B Burst Read from address 16 ===
        @(posedge clk);
        base_addr_b = 6'd16;
        burst_len_b = 2'd3;
        burst_en_b = 1;
        we_b = 0;

        repeat (4) @(posedge clk);
        burst_en_b = 0;

        // === TEST 5: Simultaneous Burst Write A and B to different areas ===
        @(posedge clk);
        base_addr_a = 6'd32;
        burst_len_a = 2'd2;
        burst_en_a  = 1;
        we_a        = 1;
        din_a       = 8'hE1;

        base_addr_b = 6'd48;
        burst_len_b = 2'd2;
        burst_en_b  = 1;
        we_b        = 1;
        din_b       = 8'hF1;

        repeat (3) begin
            @(posedge clk);
            din_a = din_a + 8'h01;
            din_b = din_b + 8'h01;
        end

        @(posedge clk);
        burst_en_a = 0; we_a = 0;
        burst_en_b = 0; we_b = 0;

        // === TEST 6: Read back Port A and B last writes ===
        @(posedge clk);
        base_addr_a = 6'd32;
        burst_len_a = 2'd2;
        burst_en_a  = 1;
        we_a = 0;

        base_addr_b = 6'd48;
        burst_len_b = 2'd2;
        burst_en_b  = 1;
        we_b = 0;

        repeat (3) @(posedge clk);

        burst_en_a = 0;
        burst_en_b = 0;

        #(20);
        $display("==== TEST COMPLETE ====");
        $finish;
    end

endmodule
