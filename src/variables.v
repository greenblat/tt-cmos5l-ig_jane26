`default_nettype wire
`timescale 1ns / 1ps
module variables (input clk, input rst_n
    ,input [8:0] addr
    ,input [15:0] wdata
    ,input mwrite

    ,output [15:0] rdata
);

localparam WIDE = 128;
reg [WIDE-1:0] mem;

wire [5:0] wrdpart = addr[8:3];
wire [2:0] widpart = addr[2:0];
wire [4:0] varwid = 
    (widpart==0) ? 1 :
    (widpart==1) ? 2 :
    (widpart==2) ? 4 :
    (widpart==3) ? 8 :
    16;
wire [16:0] wmask =  (1<<varwid) - 1;

wire [WIDE-1:0] shiftedx = 
    (wrdpart==0) ? mem :
    (wrdpart==1) ? (mem >> (wrdpart*2)) :
    (wrdpart==2) ? (mem >> (wrdpart*2)) :
    (wrdpart==3) ? (mem >> (wrdpart*2)) :
    128'hx;

wire [WIDE-1:0] shiftedx2 =  mem >> (wrdpart*2);
wire [WIDE-1:0] shiftedx4 =  mem >> (wrdpart*4);
wire [WIDE-1:0] shiftedx8 =  mem >> (wrdpart*8);
wire [WIDE-1:0] shiftedx16 =  mem >> (wrdpart*16);

wire [15:0] shifted2  =  shiftedx2[15:0] & 16'h3;
wire [15:0] shifted4  =  shiftedx4[15:0] & 16'hf;
wire [15:0] shifted8  =  shiftedx8[15:0] & 16'hff;
wire [15:0] shifted16 =  shiftedx16[15:0] & 16'hffff;
    
wire [63:0] shifted0 = mem[63:0];

assign rdata = (widpart==0) ? {15'b0,shifted0[wrdpart]} : 
               (widpart==1) ? shifted2 : 
               (widpart==2) ? shifted4 : 
               (widpart==3) ? shifted8 : 
               shifted16;




// wire panic0 = (widpart==0) && (wrdpart>=WIDE);
wire panic1 = (widpart==1) && ((1+2*wrdpart)>=WIDE);
wire panic2 = (widpart==2) && ((3+4*wrdpart)>=WIDE);
wire panic3 = (widpart==3) && ((7+8*wrdpart)>=WIDE);
wire panic4 = (widpart>3)  && ((15+16*wrdpart)>=WIDE);

always @(posedge clk) begin
    if (mwrite) begin
        if (widpart == 0) begin
            mem[{1'b0,wrdpart}] <= wdata[0];
        end else if (widpart==1) begin
            mem[wrdpart*2] <= wdata[0];
            mem[wrdpart*2+1] <= wdata[1];
        end else if (widpart==2) begin
            mem[wrdpart*4] <= wdata[0];
            mem[wrdpart*4+1] <= wdata[1];
            mem[wrdpart*4+2] <= wdata[2];
            mem[wrdpart*4+3] <= wdata[3];
        end else if (widpart==3) begin
            mem[wrdpart*8] <= wdata[0];
            mem[wrdpart*8+1] <= wdata[1];
            mem[wrdpart*8+2] <= wdata[2];
            mem[wrdpart*8+3] <= wdata[3];
            mem[wrdpart*8+4] <= wdata[4];
            mem[wrdpart*8+5] <= wdata[5];
            mem[wrdpart*8+6] <= wdata[6];
            mem[wrdpart*8+7] <= wdata[7];
        end else begin
            mem[wrdpart*16+0] <= wdata[0];
            mem[wrdpart*16+1] <= wdata[1];
            mem[wrdpart*16+2] <= wdata[2];
            mem[wrdpart*16+3] <= wdata[3];
            mem[wrdpart*16+4] <= wdata[4];
            mem[wrdpart*16+5] <= wdata[5];
            mem[wrdpart*16+6] <= wdata[6];
            mem[wrdpart*16+7] <= wdata[7];
            mem[wrdpart*16+8] <= wdata[8];
            mem[wrdpart*16+9] <= wdata[9];
            mem[wrdpart*16+10] <= wdata[10];
            mem[wrdpart*16+11] <= wdata[11];
            mem[wrdpart*16+12] <= wdata[12];
            mem[wrdpart*16+13] <= wdata[13];
            mem[wrdpart*16+14] <= wdata[14];
            mem[wrdpart*16+15] <= wdata[15];
        end
    end
end

wire [63:0]  sign_version = 64'h8fcd32face151126 ;
endmodule
// FROMFILE 8fcd3 2face :: /Users/iliagreenblat/projects/fplp/verila/src/variables.v





