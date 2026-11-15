`default_nettype wire
`timescale 1ns / 1ps
module fplp_stack ( input clk, input rst_n
    ,output [15:0] opstack0
    ,output [15:0] opstack1
    ,output [15:0] opstack2
    ,input [15:0]  push_value
    ,input push1_op
    ,input pop1_op
    ,input pop2_op
    ,input dual_op
    ,input replace_top_op
    ,input exchange_op
    ,input [2:0] exchange_dst
    ,input select_code

);

// not driving out, synthesis should remove it
reg [3:0] depth_used;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        depth_used <= 0;
    end else  if (push1_op) begin
        depth_used <= depth_used + 1;
    end else  if (pop1_op) begin
        depth_used <= depth_used - 1;
    end else  if (pop2_op) begin
        depth_used <= depth_used - 2;
    end else  if (dual_op) begin
        depth_used <= depth_used - 1;
    end 
end

reg [15:0] opstack [0:7];

assign opstack0 = opstack[0];
assign opstack1 = opstack[1];
assign opstack2 = opstack[2];
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        opstack[0] <= 16'h3333;
        opstack[1] <= 16'h3333;
        opstack[2] <= 16'h3333;
        opstack[3] <= 16'h3333;
        opstack[4] <= 16'h3333;
        opstack[5] <= 16'h3333;
        opstack[6] <= 16'h3333;
        opstack[7] <= 16'h3333;
    end else if (select_code) begin
        opstack[0] <= push_value;
        opstack[1] <= opstack[3];
        opstack[2] <= opstack[4];
        opstack[3] <= opstack[5];
        opstack[4] <= opstack[6];
        opstack[5] <= opstack[7];
        opstack[6] <= 0;
        opstack[7] <= 0;
    end else if (push1_op) begin
        opstack[0] <= push_value;
        opstack[1] <= opstack[0];
        opstack[2] <= opstack[1];
        opstack[3] <= opstack[2];
        opstack[4] <= opstack[3];
        opstack[5] <= opstack[4];
        opstack[6] <= opstack[5];
        opstack[7] <= opstack[6];
    end else if (pop1_op) begin
        opstack[0] <= opstack[1];
        opstack[1] <= opstack[2];
        opstack[2] <= opstack[3];
        opstack[3] <= opstack[4];
        opstack[4] <= opstack[5];
        opstack[5] <= opstack[6];
        opstack[6] <= opstack[7];
        opstack[7] <= 0;
    end else if (pop2_op) begin
        opstack[0] <= opstack[2];
        opstack[1] <= opstack[3];
        opstack[2] <= opstack[4];
        opstack[3] <= opstack[5];
        opstack[4] <= opstack[6];
        opstack[5] <= opstack[7];
        opstack[6] <= 0;
        opstack[7] <= 0;
    end else if (pop1_op) begin
        opstack[0] <= opstack[1];
        opstack[1] <= opstack[2];
        opstack[2] <= opstack[3];
        opstack[3] <= opstack[4];
        opstack[4] <= opstack[5];
        opstack[5] <= opstack[6];
        opstack[6] <= opstack[7];
        opstack[7] <= 0;
    end else if (dual_op) begin
        opstack[0] <= push_value;
        opstack[1] <= opstack[2];
        opstack[2] <= opstack[3];
        opstack[3] <= opstack[4];
        opstack[4] <= opstack[5];
        opstack[5] <= opstack[6];
        opstack[6] <= opstack[7];
        opstack[7] <= 0;
    end else if (replace_top_op) begin
        opstack[0] <= push_value;
    end else if (exchange_op) begin
        opstack[0] <= opstack[exchange_dst];
        opstack[exchange_dst] <= opstack[0];
    end 
end
wire [15:0] dbg0 = opstack[0];
wire [15:0] dbg1 = opstack[1];
wire [15:0] dbg2 = opstack[2];
wire [15:0] dbg3 = opstack[3];

wire [63:0]  sign_version = 64'h0728437070151126 ;
endmodule
// FROMFILE 07284 37070 :: /Users/iliagreenblat/projects/fplp/verila/src/fplp_stack.v



