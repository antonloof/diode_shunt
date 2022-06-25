module nr_div (
    input rstn,
    input clk,

    input [MANTISSA_W+EXP_W-1:0] d,
    input in_valid,
    output reg in_ready,

    output reg [MANTISSA_W+EXP_W-1:0] out,
    output reg out_valid,
    input out_ready
);
    localparam MANTISSA_W = 16;
    localparam EXP_W = 8;
    localparam ITERATION_COUNT = 4;
    localparam ITERATION_CNT_W = 2;
    localparam MANTISSA_W_CLOG2 = 4;


    localparam STATE_W = 2;
    localparam STATE_IDLE = 0;
    localparam STATE_APPROXIMATE = 1;
    localparam STATE_ITTERATING = 2;
    localparam STATE_DONE = 3;
    localparam FIX_POINT_LOCATION = 15;

    localparam CONST_48_OVER_17 = 32'd3031741621; // 2u30
    localparam CONST_32_OVER_17 = 16'd61681; // 1u15
    localparam CONST_2 = 32'h80000000; // 2u30
    


    reg [MANTISSA_W-1:0] d_man; // 1u15
    // sufficient for 16x16 multiplication
    reg [31:0] z; // 2u30
    reg [31:0] ztemp; // 2u30

    reg signed [EXP_W-1:0] d_exp; // 8s
    reg d_sign;

    reg [ITERATION_CNT_W-1:0] i;
    reg [STATE_W-1:0] state;
    

    always @(posedge clk) begin
        
        if (!rstn) begin
            i <= 0;
            state <= STATE_IDLE;
            in_ready <= 1;
            out_valid <= 0;

            
        end else begin
            if (state == STATE_IDLE) begin
                out_valid <= 0;

                if (in_ready && in_valid) begin
                    d_man <= ({(MANTISSA_W){d[MANTISSA_W+EXP_W-1]}} ^ d[MANTISSA_W+EXP_W-1:EXP_W]) + d[MANTISSA_W+EXP_W-1];
                    d_exp <= d[EXP_W-1:0];
                    d_sign <= d[MANTISSA_W+EXP_W-1];
                    state <= STATE_APPROXIMATE;
                    in_ready <= 0;
                end
           
            end else if (state == STATE_APPROXIMATE) begin
                z <= CONST_48_OVER_17 - (CONST_32_OVER_17 * d_man);
                state <= STATE_ITTERATING;

            end else if (state == STATE_ITTERATING) begin
                i <= i+1;
                if (i[0] == 1'b0) begin
                    ztemp <= CONST_2-(d_man * (z >> FIX_POINT_LOCATION));
                end else begin
                    z <= ((z >> FIX_POINT_LOCATION) * (ztemp >> FIX_POINT_LOCATION));
                end
                if (i == ITERATION_COUNT-1) begin
                    i <= 0;
                    state <= STATE_DONE;
                end
           
            end else if (state == STATE_DONE) begin
                out_valid <= 1;
                out[MANTISSA_W+EXP_W-1:EXP_W] <= ({MANTISSA_W{d_sign}} ^ (z[31:31-MANTISSA_W+1])) + d_sign;
                out[EXP_W-1:0] <= -d_exp + 1'b1;
                if (out_ready <= 1) begin
                    state <= STATE_IDLE;
                    in_ready <= 1;
                end
            end
        end
    end
    
// cocotb signal dump
`ifdef COCOTB_SIM
    initial begin
        $dumpfile ("nr_div.vcd");
        $dumpvars (0, nr_div);
        #1;
    end
`endif

endmodule