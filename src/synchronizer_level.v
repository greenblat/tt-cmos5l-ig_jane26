
`default_nettype wire
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


wire [63:0]  sign_version = 64'h05da405bbd250226 ;
endmodule
// FROMFILE 05da4 05bbd :: /Users/iliagreenblat/project4/rtl/p4_synchronizer_level.v



