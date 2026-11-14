`default_nettype wire
module syncfifo_v2 #(parameter WID = 32, parameter DEPTH=8, parameter AWID = $clog2(DEPTH))(
     input clk,input rst_n,input softreset
    ,input vldin, input [WID-1:0] din, output full
    ,input readout, output reg [WID-1:0] dout, output empty
    ,output [15:0] count
    ,output overflow
);

// localparam AWID = $clog2(DEPTH);

wire [15:0] int_count;
wire [WID-1:0] int_dout;

wire int_vldin,int_full,int_empty,panic0,int_readout;
syncfifo #(.WID(WID),.DEPTH(DEPTH)) infifo (.clk(clk),.rst_n(rst_n),.softreset(softreset)
    ,.vldin(int_vldin),.din(din)
    ,.full(int_full),.empty(int_empty),.overflow(panic0),.count(int_count)
    ,.readout(int_readout),.dout(int_dout)
);
reg vldout;
// vldin vldout int_empty readout : state changing
always @(posedge  clk or negedge rst_n) begin
    if (!rst_n) begin
        vldout <= 0;
    end else if (vldin && vldout && readout && int_empty) begin
        vldout <= 1;
    end else if (!vldout || readout) begin
        if (vldin && int_empty) begin
            vldout <= 1;
        end if (readout && int_empty && vldout) begin
            vldout <= 0;
        end if (!int_empty && !vldout) begin
            vldout <= 1;
        end
    end
end
always @(posedge  clk) begin
    if (!vldout || readout) begin
        if (vldin && int_empty) begin
            dout <= din;
        end else if (!int_empty && (!vldout || readout)) begin
            dout <= int_dout;
        end else if (int_empty && !vldin && readout) begin
            dout <= 0;
        end
    end
end

assign int_readout = !int_empty && (!vldout || readout);
assign int_vldin = vldin && ( !int_empty || (vldout && !readout));
assign count = 0 + int_count + vldout;
assign empty = int_empty && !vldout;
assign full = int_full;
assign overflow = (vldin && full) || panic0;

wire [63:0]  sign_version = 64'h6ec421ea4c250226 ;
endmodule






