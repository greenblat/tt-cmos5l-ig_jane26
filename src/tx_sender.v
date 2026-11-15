`default_nettype wire
`timescale 1ns / 1ps


module tx_sender #(parameter WID = 32) ( input clk, input rst_n
    ,input [WID-1:0] din
    ,input vldin
    ,output done

    ,output [7:0] txdata
    ,output txvalid
    ,input txtaken
);

reg [7:0] pos;
wire [7:0] first = (WID>>2)+2;
always @(posedge clk) begin
    if (!rst_n) begin
        pos <= 0;
    end else if (vldin && (pos==0)) begin
        pos <= (WID>>2)+2;
    end else if (pos>0) begin
        if (txtaken) pos <= pos - 1 ;
    end
end

assign txvalid = (pos>0);
wire [31:0] tmpdin = din >> (4*(pos-2));
wire [7:0] txnibble = tmpdin[7:0];

wire [7:0] let_0 = 8'h30;
wire [7:0] let_9 = 8'h39;
wire [7:0] let_a = 8'h61;
wire [7:0] let_f = 8'h66;
wire [7:0] let_x = 8'h78;

assign txdata = (pos==first) ? let_x : (pos==1) ? 8'ha : ({4'b0,txnibble[3:0]} + ((txnibble[3:0]<10) ? let_0 : (let_a - 10))); 

assign done = txtaken && txvalid && (pos==1);
wire [63:0]  sign_version = 64'h4f6fe0f517151126 ;
endmodule
// FROMFILE 4f6fe 0f517 :: /Users/iliagreenblat/projects/fplp/verila/src/tx_sender.v


