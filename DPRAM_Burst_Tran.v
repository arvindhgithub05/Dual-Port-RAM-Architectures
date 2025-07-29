module DPRAM_Burst_Tran #(
    parameter DATA_WIDTH = 8,         // Width of each memory word
    parameter ADDR_WIDTH = 6,         // Total memory = 2^ADDR_WIDTH
    parameter MAX_BURST_LEN = 4       // Maximum burst length supported
)(
    input  wire                     clk,

    // ===========================
    // Port A Interface
    // ===========================
    input  wire                     we_a,         // Write enable
    input  wire                     burst_en_a,   // Enable burst mode
    input  wire [$clog2(MAX_BURST_LEN)-1:0] burst_len_a, // Number of words in burst
    input  wire [ADDR_WIDTH-1:0]    base_addr_a,  // Base address of burst
    input  wire [DATA_WIDTH-1:0]    din_a,        // Data input
    output reg  [DATA_WIDTH-1:0]    dout_a,       // Data output

    // ===========================
    // Port B Interface
    // ===========================
    input  wire                     we_b,
    input  wire                     burst_en_b,
    input  wire [$clog2(MAX_BURST_LEN)-1:0] burst_len_b,
    input  wire [ADDR_WIDTH-1:0]    base_addr_b,
    input  wire [DATA_WIDTH-1:0]    din_b,
    output reg  [DATA_WIDTH-1:0]    dout_b
);

    // ===========================
    // Internal Memory Declaration
    // ===========================
    localparam MEM_DEPTH = 1 << ADDR_WIDTH;
    reg [DATA_WIDTH-1:0] mem [0:MEM_DEPTH-1];

    // ===========================
    // Burst Address Counters
    // ===========================
    reg [$clog2(MAX_BURST_LEN)-1:0] burst_count_a = 0;
    reg [ADDR_WIDTH-1:0] addr_a;

    reg [$clog2(MAX_BURST_LEN)-1:0] burst_count_b = 0;
    reg [ADDR_WIDTH-1:0] addr_b;

    // ===========================
    // Address Generation Logic
    // ===========================
    always @(posedge clk) begin
        if (burst_en_a) begin
            if (burst_count_a < burst_len_a)
                burst_count_a <= burst_count_a + 1;
            addr_a <= base_addr_a + burst_count_a;
        end else begin
            burst_count_a <= 0;
            addr_a <= base_addr_a;
        end
    end

    always @(posedge clk) begin
        if (burst_en_b) begin
            if (burst_count_b < burst_len_b)
                burst_count_b <= burst_count_b + 1;
            addr_b <= base_addr_b + burst_count_b;
        end else begin
            burst_count_b <= 0;
            addr_b <= base_addr_b;
        end
    end

    // ===========================
    // Memory Access: Port A
    // ===========================
    always @(posedge clk) begin
        if (we_a)
            mem[addr_a] <= din_a;
        dout_a <= mem[addr_a];
    end

    // ===========================
    // Memory Access: Port B
    // ===========================
    always @(posedge clk) begin
        if (we_b)
            mem[addr_b] <= din_b;
        dout_b <= mem[addr_b];
    end

endmodule
