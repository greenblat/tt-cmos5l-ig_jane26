
`default_nettype wire
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


wire [63:0]  sign_version = 64'ha6488062a1021224 ;
endmodule
// FROMFILE a6488 062a1 021224 :: /Users/iliagreenblat/project2/fpga/fpga_rtl/synchronizer_rst_n.v


