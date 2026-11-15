
`default_nettype wire
`timescale 1ns / 1ps

module synchronizer_rst_n (
    input clk, input rst_n,output rst_n_synced
);

reg SYNCFLOP0,SYNCFLOP1;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        SYNCFLOP0 <= 0;
        SYNCFLOP1 <= 0;
    end else begin
        SYNCFLOP0 <= 1;
        SYNCFLOP1 <= SYNCFLOP0;
    end
end
assign rst_n_synced = SYNCFLOP1;


wire [63:0]  sign_version = 64'h36cec06b05151126 ;
endmodule
// FROMFILE 36cec 06b05 :: /Users/iliagreenblat/projects/fplp/verila/src/synchronizer_rst_n.v



