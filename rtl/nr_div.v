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
    localparam MANTISSA_W = 15;
    localparam EXP_W = 8;
    localparam ITERATION_COUNT = 4;
    localparam ITERATION_CNT_W = 3;
    localparam MANTISSA_W_CLOG2 = 4;


    localparam STATE_W = 2;
    localparam STATE_IDLE = 0;
    localparam STATE_APPROXIMATE = 1;
    localparam STATE_ITTERATING = 2;
    localparam STATE_DONE = 3;
    localparam FIX_POINT_LOCATION = 14;
    // fixed point with 2.14 unsigned numbers
    localparam CONST_48_OVER_17 = 46261;
    localparam CONST_32_OVER_17 = 30840;
    localparam CONST_2 = 32768;
    


    reg [MANTISSA_W:0] d_man;
    // sufficient for 16x16 multiplication
    reg [31:0] z;
    reg [31:0] ztemp;

    reg signed [EXP_W-1:0] d_exp;
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
                if (in_ready && in_valid) begin
                    d_man <= {2'b0, ({(MANTISSA_W-1){d[MANTISSA_W+EXP_W-1]}} ^ d[MANTISSA_W-2+EXP_W:EXP_W]) + d[MANTISSA_W+EXP_W-1]};
                    d_exp <= d[EXP_W-1:0];
                    d_sign <= d[MANTISSA_W+EXP_W-1];
                    state <= STATE_APPROXIMATE;
                end
           
            end else if (state == STATE_APPROXIMATE) begin
                z <= ((CONST_48_OVER_17 << FIX_POINT_LOCATION) - ((CONST_32_OVER_17 * d_man)));
                state <= STATE_ITTERATING;

            end else if (state == STATE_ITTERATING) begin
                i <= i+1;
                if (i[0] == 1'b0) begin
                    ztemp <= (CONST_2 << FIX_POINT_LOCATION) - (d_man * (z >> FIX_POINT_LOCATION));
                end else begin
                    z <= ((z >> FIX_POINT_LOCATION) * (ztemp >> FIX_POINT_LOCATION));
                end
                if (i == ITERATION_COUNT-1) begin
                    i <= 0;
                    state <= STATE_DONE;
                end
           
            end else if (state == STATE_DONE) begin
                out_valid <= 1;
                out[MANTISSA_W+EXP_W-1:EXP_W] <= ({MANTISSA_W{d_sign}} ^ (z[29:29-MANTISSA_W+1])) + d_sign;
                out[EXP_W-1:0] <= -d_exp + 1'b1;
                if (out_ready <= 1) begin
                    state <= STATE_IDLE;
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