module DPRAM_Banked_Arch #(
    parameter DATA_WIDTH = 8,          // Width of each data word
    parameter ADDR_WIDTH = 6,          // Address width (total memory = 2^ADDR_WIDTH)
    parameter NUM_BANKS  = 4           // Number of banks (must be power of 2)
)(
    input  wire                     clk,
    
    // Port A Interface
    input  wire                     we_a,
    input  wire [ADDR_WIDTH-1:0]    addr_a,
    input  wire [DATA_WIDTH-1:0]    din_a,
    output reg  [DATA_WIDTH-1:0]    dout_a,

    // Port B Interface
    input  wire                     we_b,
    input  wire [ADDR_WIDTH-1:0]    addr_b,
    input  wire [DATA_WIDTH-1:0]    din_b,
    output reg  [DATA_WIDTH-1:0]    dout_b
);

    // === Derived Parameters ===
    localparam BANK_ADDR_WIDTH = ADDR_WIDTH - $clog2(NUM_BANKS);  // Address bits per bank
    localparam BANK_DEPTH      = 1 << BANK_ADDR_WIDTH;

    // === Memory Declaration: NUM_BANKS arrays ===
    reg [DATA_WIDTH-1:0] banks[NUM_BANKS-1:0][0:BANK_DEPTH-1];

    // === Extract bank index and bank-local address ===
    // $clog2(4), which evaluates to 2 as 2^(2) = 4
    // 
    wire [$clog2(NUM_BANKS)-1:0] bank_sel_a = addr_a[ADDR_WIDTH-1:ADDR_WIDTH-$clog2(NUM_BANKS)];
    wire [$clog2(NUM_BANKS)-1:0] bank_sel_b = addr_b[ADDR_WIDTH-1:ADDR_WIDTH-$clog2(NUM_BANKS)];

    wire [BANK_ADDR_WIDTH-1:0]   bank_addr_a = addr_a[BANK_ADDR_WIDTH-1:0];
    wire [BANK_ADDR_WIDTH-1:0]   bank_addr_b = addr_b[BANK_ADDR_WIDTH-1:0];

    integer i;

    // === Arbitration: Port A has higher priority ===
    always @(posedge clk) begin
        for (i = 0; i < NUM_BANKS; i = i + 1) begin
            // Port A access
            if (bank_sel_a == i) begin
                if (we_a)
                    banks[i][bank_addr_a] <= din_a;
                dout_a <= banks[i][bank_addr_a];
            end

            // Port B access
            if (bank_sel_b == i) begin
                if (bank_sel_b != bank_sel_a || !we_a) begin
                    // No conflict with Port A, or Port A isn't writing
                    if (we_b)
                        banks[i][bank_addr_b] <= din_b;
                end
                dout_b <= banks[i][bank_addr_b];
            end
        end
    end

endmodule
