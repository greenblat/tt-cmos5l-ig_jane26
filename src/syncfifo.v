`default_nettype wire
`timescale 1ns / 1ps
module syncfifo #(parameter WID = 32, parameter DEPTH=8, parameter AWID = $clog2(DEPTH))(
     input clk,input rst_n,input softreset
    ,input vldin, input [WID-1:0] din, output full
    ,input readout, output [WID-1:0] dout, output empty
    ,output reg [15:0] count
    ,output overflow
);
localparam DEPTH1 = DEPTH-1;
localparam AWID1  = AWID-1;
reg [WID-1:0] fifos [0:DEPTH1];
reg [AWID1:0] wptr,rptr;
assign   empty = count == 0;
assign   full = count == DEPTH;
assign   dout = empty ? {WID{1'b0}} : fifos[rptr];
assign overflow = vldin && full;
always @(posedge clk) begin
    if (vldin && !full) begin
        fifos[wptr] <= din;
    end 
end

/* verilator lint_off WIDTHEXPAND */
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        wptr <= 0; rptr <= 0; count<=0;
    end else if(softreset) begin
        wptr <= 0; rptr <= 0; count<=0;
    end else begin
        if(vldin && !full) begin
            wptr <= (wptr==(DEPTH1)) ? 0 : (wptr + 1'b1);
        end 
        if(readout && !empty) begin
            rptr <= (rptr==(DEPTH1)) ? 0 : (rptr + 1'b1);
        end 
        count <= 
            ((vldin && !full)&&(readout && !empty))  ? count :
            (vldin && !full)  ? (count+1'b1) :
            (readout && !empty)  ? (count-1'b1) :
            count;
    end 
end
/* verilator lint_on WIDTHEXPAND */
wire [63:0]  sign_version = 64'h86ac2168cc151126 ;
endmodule
// FROMFILE 86ac2 168cc :: /Users/iliagreenblat/projects/fplp/verila/src/syncfifo.v




