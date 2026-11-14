
module ram_32bit_4096addr (
     input CK, input [31:0] D, output reg [31:0] Q, input [13:0] A
    ,input WEN, input CEN
    ,input [31:0] WMASK
);

reg [31:0] mem [0:3];


wire reading = !CEN && WEN ;


wire [31:0] dbgQ = mem[A];
wire [31:0] newD = (mem[A] & ~WMASK) | (WMASK & D);
always @(posedge CK) begin
    if (!CEN) begin
        if (!WEN) mem[A] <= newD;
        else Q <= mem[A];
    end
end
`ifdef SIM
always @(posedge CK) begin
    if (!CEN && !WEN) $display("___WRITE ad=%x data=%x", A,D);
end
always @(posedge CK) begin
    if (!CEN &&  WEN) $display("___READ  ad=%x data=%x", A,mem[A]);
end

integer II;
initial begin
    for (II=0;II<4096;II=II+1) begin
        mem[II] = 32'hffffffff;
    end
end
`endif

wire [63:0]  sign_version = 64'h0000a6bd20190723 ;
endmodule

