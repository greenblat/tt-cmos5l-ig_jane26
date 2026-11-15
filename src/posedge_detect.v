`default_nettype wire
`timescale 1ns / 1ps

module posedge_detect(
    input clk, input rst_n
    ,input din, output dout
);

reg was; 
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) was <= 0;
    else was <= din;
end

assign dout = !was && din;

wire [63:0]  sign_version = 64'h8529f050b8151126 ;
endmodule
// FROMFILE 8529f 050b8 :: /Users/iliagreenblat/projects/fplp/verila/src/posedge_detect.v


