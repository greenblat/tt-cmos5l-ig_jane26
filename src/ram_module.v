`default_nettype wire
`timescale 1ns / 1ps

module ram_module (
     input CLK, input [31:0] D, output reg [31:0] QQ, input [15:0] A
    ,input WEN, input CEN
    ,output reg VLD
    ,output [127:0] WIDEQ
);

reg [31:0] DP;
reg [6:0]  AP;
reg WENP;
reg CENP;

always @(posedge CLK) begin
    if (!CEN) begin
        DP <= D;
        AP <= A[8:2];
        WENP <= WEN;
        CENP <= 0;
    end else begin
        DP <= 0;
        AP <= 0;
        WENP <= 1;
        CENP <= 1;
    end
end



reg [31:0] mem0 [0:31];
reg [31:0] mem1 [0:31];
reg [31:0] mem2 [0:31];
reg [31:0] mem3 [0:31];

wire [6:0] AA = AP[6:0];
wire [4:0] AAA = AA[6:2];




wire WEN0 = WENP || (AA[1:0] != 0);
wire WEN1 = WENP || (AA[1:0] != 1);
wire WEN2 = WENP || (AA[1:0] != 2);
wire WEN3 = WENP || (AA[1:0] != 3);

reg [31:0] Q0,Q1,Q2,Q3;
reg sel0,sel1,sel2,sel3;

always @(posedge CLK) begin
    if (!WEN0) mem0[AAA] <= DP;
    if (!WEN1) mem1[AAA] <= DP;
    if (!WEN2) mem2[AAA] <= DP;
    if (!WEN3) mem3[AAA] <= DP;
end

always @(posedge CLK) begin
    VLD <= !CENP;
    if (!CENP) begin
        Q0 <= mem0[AAA];
        Q1 <= mem1[AAA];
        Q2 <= mem2[AAA];
        Q3 <= mem3[AAA];
        sel0 <= AA[1:0] == 0;
        sel1 <= AA[1:0] == 1;
        sel2 <= AA[1:0] == 2;
        sel3 <= AA[1:0] == 3;
    end
end

always @(posedge CLK)  QQ <= sel0 ? Q0 : sel1 ? Q1 : sel2 ? Q2 : Q3; 
assign WIDEQ = {Q3,Q2,Q1,Q0};    

endmodule


