`default_nettype wire
`timescale 1ns / 1ps

module ram_32bit_4096addr (
     input CK, input [31:0] D, output [31:0] Q, input [13:0] A
    ,input WEN, input CEN
    ,input [31:0] WMASK
);

reg [31:0] mem0 [0:31];
reg [31:0] mem1 [0:31];
reg [31:0] mem2 [0:31];
reg [31:0] mem3 [0:31];

wire [6:0] AA = A[6:0];
wire [4:0] AAA = AA[4:0];



wire [31:0] new0D = (mem0[AAA] & ~WMASK) | (WMASK & D);
wire [31:0] new1D = (mem1[AAA] & ~WMASK) | (WMASK & D);
wire [31:0] new2D = (mem2[AAA] & ~WMASK) | (WMASK & D);
wire [31:0] new3D = (mem3[AAA] & ~WMASK) | (WMASK & D);

wire WEN0 = WEN || (AA[6:5] != 0);
wire WEN1 = WEN || (AA[6:5] != 1);
wire WEN2 = WEN || (AA[6:5] != 2);
wire WEN3 = WEN || (AA[6:5] != 3);

reg [31:0] Q0,Q1,Q2,Q3;
reg sel0,sel1,sel2,sel3;

always @(posedge CK) begin
    if (!CEN) begin
        if (!WEN0) mem0[AAA] <= new0D;
        if (!WEN1) mem1[AAA] <= new1D;
        if (!WEN2) mem2[AAA] <= new2D;
        if (!WEN3) mem3[AAA] <= new3D;
        Q0 <= mem0[AAA];
        Q1 <= mem1[AAA];
        Q2 <= mem2[AAA];
        Q3 <= mem3[AAA];
        sel0 <= AA[6:5] == 0;
        sel1 <= AA[6:5] == 1;
        sel2 <= AA[6:5] == 2;
        sel3 <= AA[6:5] == 3;
    end
end

assign Q = sel0 ? Q0 : sel1 ? Q1 : sel2 ? Q2 : Q3; 
    

endmodule


