module hyperbolic_exp_cordic (
    input rstn,
    input clk,

    input signed [NUM_W - 1:0] z0,
    input in_valid,
    output reg in_ready,
    
    output reg signed [NUM_W - 1:0] w,
    output reg out_valid,
    input out_ready
);
    localparam NUM_W = 16;
    // should be +2 however those iterations make no difference at 15 significant digits
    localparam ITERATION_COUNT = NUM_W;
    // numbers are twos complement fixed point 2.14 two bits before decimal 14 after, we have sign
    localparam NUM_W_BITS = $clog2(ITERATION_COUNT+1);
    
    localparam state_idle = 0;
    localparam state_iterating = 1;
    localparam state_done = 2;
    localparam signed CORDIC_FACTOR = 19784;
    
    reg [NUM_W_BITS-1:0] iteration_no;
    reg [1:0] state;
    reg signed [NUM_W-1:0] z;

    reg [NUM_W - 1:0] STATE_INDEXES [ITERATION_COUNT - 1: 0];
    reg signed [NUM_W:1] ATANH_2_TO_THE_MINUS_I [ITERATION_COUNT - 1: 0];
    reg signed [15:0] t;
    initial begin
        // wow.... such constants
        STATE_INDEXES[0] <= 1;
        STATE_INDEXES[1] <= 2;
        STATE_INDEXES[2] <= 3;
        STATE_INDEXES[3] <= 4;
        STATE_INDEXES[4] <= 4;
        STATE_INDEXES[5] <= 5;
        STATE_INDEXES[6] <= 6;
        STATE_INDEXES[7] <= 7;
        STATE_INDEXES[8] <= 8;
        STATE_INDEXES[9] <= 9;
        STATE_INDEXES[10] <= 10;
        STATE_INDEXES[11] <= 11;
        STATE_INDEXES[12] <= 12;
        STATE_INDEXES[13] <= 13;
        STATE_INDEXES[14] <= 13;
        STATE_INDEXES[15] <= 14;
        ATANH_2_TO_THE_MINUS_I[1] <= 9000;
        ATANH_2_TO_THE_MINUS_I[2] <= 4185;
        ATANH_2_TO_THE_MINUS_I[3] <= 2059;
        ATANH_2_TO_THE_MINUS_I[4] <= 1025;
        ATANH_2_TO_THE_MINUS_I[5] <= 512;
        ATANH_2_TO_THE_MINUS_I[6] <= 256;
        ATANH_2_TO_THE_MINUS_I[7] <= 128;
        ATANH_2_TO_THE_MINUS_I[8] <= 64;
        ATANH_2_TO_THE_MINUS_I[9] <= 32;
        ATANH_2_TO_THE_MINUS_I[10] <= 16;
        ATANH_2_TO_THE_MINUS_I[11] <= 8;
        ATANH_2_TO_THE_MINUS_I[12] <= 4;
        ATANH_2_TO_THE_MINUS_I[13] <= 2;
        ATANH_2_TO_THE_MINUS_I[14] <= 1;
    end
    
    always @(posedge clk) begin
        if (!rstn) begin
            in_ready <= 1;
            out_valid <= 0;
            iteration_no <= 0;
            state <= state_idle;
            z <= 0;
            w <= 0;
        end else begin 
            if (state == state_idle) begin
                if (in_ready && in_valid) begin
                    z <= z0;
                    w <= CORDIC_FACTOR;
                    state <= state_iterating;
                    iteration_no <= 0;
                end
            end else if (state == state_iterating) begin
                iteration_no <= iteration_no + 1;
                t <= ATANH_2_TO_THE_MINUS_I[STATE_INDEXES[iteration_no]];
                z <= z - (({NUM_W{z[NUM_W-1]}} ^ ATANH_2_TO_THE_MINUS_I[STATE_INDEXES[iteration_no]]) + z[NUM_W-1]);
                w <= w + ({NUM_W{z[NUM_W-1]}} ^ (w >> STATE_INDEXES[iteration_no])) + z[NUM_W-1];
                if (iteration_no == ITERATION_COUNT - 1) begin
                    state <= state_done;
                    out_valid <= 1;
                end
            end else if (state == state_done) begin
                if (out_ready && out_valid) begin
                    state <= state_idle;
                end
            end
        end
    end
    
// cocotb signal dump
`ifdef COCOTB_SIM
    initial begin
        $dumpfile ("hyperbolic_exp_cordic.vcd");
        $dumpvars (0, hyperbolic_exp_cordic);
        #1;
    end
`endif

endmodule