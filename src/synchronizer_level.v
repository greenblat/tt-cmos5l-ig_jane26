
`default_nettype wire
`timescale 1ns / 1ps

module synchronizer_level (
    input clk, input din, input rst_n,output dout
);


reg SFLOP0,SFLOP1;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        SFLOP0 <= 1'b0;
        SFLOP1 <= 1'b0;
    end else begin
        SFLOP0 <= din;
        SFLOP1 <= SFLOP0;
    end
end
assign dout = SFLOP1;


wire [63:0]  sign_version = 64'h265050631e151126 ;
endmodule
// FROMFILE 26505 0631e :: /Users/iliagreenblat/projects/fplp/verila/src/synchronizer_level.v




