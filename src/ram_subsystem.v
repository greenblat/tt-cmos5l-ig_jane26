
module ram_subsystem ( input clk, input rst_n
    ,input drct_access
    ,input drct_wr
    ,input [15:0] drct_addr
    ,input [31:0] drct_wdata
    ,output [31:0] drct_rdata
    ,output drct_ready

    ,input cpu_rd
    ,input [15:0] cpu_addr
    ,output [7:0] cpu_rdata
    ,output reg cpu_ready

);

wire wen = ~(drct_wr && drct_access);
wire cen = ~(cpu_rd || drct_access);
wire [15:0] aa = drct_access ? drct_addr[15:0] : cpu_addr[15:0] ;

wire vld;
wire [15:0] [7:0] wideq;
ram_module ramx (
     .CLK(clk)
    ,.D(drct_wdata)
    ,.QQ(drct_rdata)
    ,.A(aa)
    ,.WEN(wen)
    ,.CEN(cen)
    ,.VLD(vld)
    ,.WIDEQ(wideq)
);

reg [3:0] page0,page1;
reg [3:0] inpage0,inpage1;
reg vld0,vld1;
reg drct_ready0,drct_ready1;
reg [3:0] was_addr;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        page0 <= 0;
        inpage0 <= 0;
        page1 <= 0;
        inpage1 <= 0;
        vld0 <= 0;
        vld1 <= 1;
        drct_ready0 <= 0;
        drct_ready1 <= 0;
        cpu_ready <= 0;
        was_addr <= 0;
    end else begin
        drct_ready0 <= drct_access && !drct_wr;
        drct_ready1 <= drct_ready0;
        vld0 <= !drct_access & cpu_rd;        
        vld1 <= vld0;        
        inpage0 <= cpu_addr[3:0];
        page0 <= cpu_addr[7:4];
        inpage1 <= inpage0;
        page1 <= page0;
        cpu_ready <= (page0 == cpu_addr[7:4]) && vld0;
        was_addr <= cpu_addr[3:0];
    end
end
assign cpu_rdata = wideq[was_addr[3:0]];
// assign cpu_ready = vld1 && (cpu_addr[7:4] == page1);

assign drct_ready = drct_ready1;


endmodule

