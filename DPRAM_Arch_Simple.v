module DPRAM_Arch_Simple #(
    parameter DATA_WIDTH = 8,         // Width of data word
    parameter ADDR_WIDTH = 4          // Width of address bus (for 2^ADDR_WIDTH memory locations)
)(
    input  wire                     clk_a,      // Clock for Port A
    input  wire                     we_a,       // Write enable for Port A
    input  wire [ADDR_WIDTH-1:0]    addr_a,     // Address for Port A
    input  wire [DATA_WIDTH-1:0]    din_a,      // Data input for Port A
    output reg  [DATA_WIDTH-1:0]    dout_a,     // Data output for Port A

    input  wire                     clk_b,      // Clock for Port B
    input  wire                     we_b,       // Write enable for Port B
    input  wire [ADDR_WIDTH-1:0]    addr_b,     // Address for Port B
    input  wire [DATA_WIDTH-1:0]    din_b,      // Data input for Port B
    output reg  [DATA_WIDTH-1:0]    dout_b      // Data output for Port B
);

    // Memory Declaration
    localparam RAM_DEPTH = 1 << ADDR_WIDTH;
    reg [DATA_WIDTH-1:0] mem [0:RAM_DEPTH-1];

    // Port A Operation
    always @(posedge clk_a) begin
        if (we_a)
            mem[addr_a] <= din_a;
        dout_a <= mem[addr_a];   // Synchronous Read
    end

    // Port B Operation
    always @(posedge clk_b) begin
        if (we_b)
            mem[addr_b] <= din_b;
        dout_b <= mem[addr_b];  // Synchronous Read
    end

endmodule
