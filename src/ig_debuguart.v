`default_nettype wire
`timescale 1ns / 1ps


module ig_debuguart #(parameter BAUDRATE=244) (
     input clk ,input reset_n
    ,input rxd, output txd


    ,output reg [31:0] s_paddr
    ,output reg [31:0] s_pwdata
    ,output reg    s_psel
    ,output        s_penable
    ,output reg        s_pwrite
    ,output [3:0]  s_pstrb
    ,input         s_pready
    ,input         s_pslverr
    ,input  [31:0] s_prdata

    ,output uart2extram
    ,output [31:0] drct_addr
    ,output  drct_rd
    ,output [31:0] drct_wdata
    ,output  drct_wr
    ,input   [31:0] drct_rdata
    ,input drct_ready

    ,input interrupt

);

reg [15:0] max_rx_sync;
reg [15:0] max_tx_sync;
reg [15:0] max_echo;
reg [15:0] max_prdata;

wire rst_n0;
wire uart_rst_n;
wire echo_on;
synchronizer_level sync0 (.clk(clk),.rst_n(reset_n),.din(1'b1),.dout(rst_n0));
reg [3:0] rstcnt;
always @(posedge clk or negedge rst_n0) begin
    if (!rst_n0) begin
        rstcnt <= 0;
    end else begin
        rstcnt <= rstcnt+(rstcnt!=15);
    end
end
wire rst_n = rstcnt==15;
        



wire softreset = 0;
assign s_pstrb  = 4'hf;

wire swiss_read = drct_rd && (drct_addr[31:28] == 0);
wire read_fifo;
wire panic_read_fifo;
wire read_fifo_empty,read_fifo_full;
wire [15:0] read_fifo_count;
wire [7:0] read_fifo_out;
wire read_fifo_readout;
syncfifo #(.WID(8),.DEPTH(4)) read_wide_fifo (
    .clk(clk),.rst_n(rst_n)
   ,.vldin(swiss_read),.din(drct_addr[7:0])
   ,.readout(read_fifo_readout),.dout(read_fifo_out)
   ,.empty(read_fifo_empty),.full(read_fifo_full)
   ,.count(read_fifo_count)
   ,.softreset(softreset)
   ,.overflow(panic_read_fifo)
);

wire panic_tx_fifo;
wire [15:0] prdata_fifo_count;
wire [15:0] tx_sync_fifo_count;
wire ok_to_drct_rd = !read_fifo_empty &&  (prdata_fifo_count < 4) && (tx_sync_fifo_count<=6);
reg [1:0] waitState;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        waitState <= 0;
    end else begin
        if (waitState==0) begin
            if (ok_to_drct_rd)  begin
                waitState <= 1;
            end
        end else if (waitState == 1) begin
            if (!ok_to_drct_rd) begin
                waitState <= 2;
            end
        end else if (waitState == 2) begin
            if (ok_to_drct_rd) begin
                waitState <= 0;
            end
        end
    end
end
assign read_fifo_readout = ok_to_drct_rd && (waitState == 0);


wire uart2swiss = read_fifo_readout || (drct_wr && (drct_addr[31:28] == 0));

assign uart2extram = (drct_wr || drct_rd) && (drct_addr[31:28] == 5);

wire uart2interrupt = (drct_wr || drct_rd) && (drct_addr[31:28] == 6);







reg [31:0] qqdata;




reg sticky_interrupt;
reg uart2extram_d1;
reg uart2extram_d2;
reg uart2extram_d3;
reg uart2extram_d4;
always @(posedge clk) begin
    if (!rst_n) begin
        sticky_interrupt <= 0;
        qqdata <= 0;
        uart2extram_d1 <= 0;
        uart2extram_d2 <= 0;
        uart2extram_d3 <= 0;
        uart2extram_d4 <= 0;
    end else begin
        uart2extram_d1 <= uart2extram && drct_rd;
        uart2extram_d2 <= uart2extram_d1;
        uart2extram_d3 <= uart2extram_d2;
        uart2extram_d4 <= uart2extram_d3;
        if (uart2extram_d3) qqdata <= drct_rdata;
        if (interrupt) 
            sticky_interrupt <= 1;
        else if (uart2interrupt)
            sticky_interrupt <= 0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        s_paddr <= 0;
        s_pwdata <= 0;
        s_pwrite <= 0;
        s_psel <= 0;
    end else begin
        if (uart2swiss) begin
            s_paddr <= drct_addr;
            s_pwdata <= drct_wdata;
            s_pwrite <= drct_wr;
            s_psel <= 1;
        end else begin
            s_paddr <= 0;
            s_pwdata <= 0;
            s_pwrite <= 0;
            s_psel <= 0;
        end
    end
end
wire s_pready_int = !uart2swiss;
assign s_penable = s_psel;

    



wire [31:0] rdata;
wire  readout_rdata;
wire rdata_fifo_empty;





wire [7:0] uart_status;
wire [7:0] rxdata,txdata;
wire write_tx,tx_empty,rx_valid,read_rx;
wire write_tx_sys;
wire [7:0] uart_control = 8'h50;
wire [15:0] uart_baudrate;


synchronizer_rst_n sync_rst_uart (.clk(clk),.rst_n(rst_n),.rst_n_synced(uart_rst_n));
wire [7:0] rxdata_sys,txdata_sys;


wire [15:0] rx_sync_fifo_count;
wire [15:0] echo_fifo_count;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        max_rx_sync <= 0;
        max_tx_sync <= 0;
        max_echo <= 0;
        max_prdata <= 0;
    end else begin
        if (rx_sync_fifo_count> max_rx_sync) max_rx_sync <= rx_sync_fifo_count;
        if (tx_sync_fifo_count>max_tx_sync) max_tx_sync <= tx_sync_fifo_count;
        if (echo_fifo_count>max_echo) max_echo <= echo_fifo_count;
        if (prdata_fifo_count>max_prdata) max_prdata <= prdata_fifo_count;
    end
end

wire rx_sync_full;
wire panic_rx_fifo;
wire rx_sync_empty;
syncfifo #(.WID(8),.DEPTH(4)) rx_sync_fifo (
    .clk(clk),.rst_n(rst_n)
   ,.vldin(rx_valid),.din(rxdata)
   ,.readout(!rx_sync_empty),.dout(rxdata_sys)
   ,.empty(rx_sync_empty),.full(rx_sync_full)
   ,.count(rx_sync_fifo_count)
   ,.softreset(softreset)
   ,.overflow(panic_rx_fifo)
);

wire tx_sync_empty,tx_sync_full;
assign write_tx = tx_empty && !tx_sync_empty;
syncfifo_v2 #(.WID(8),.DEPTH(16)) tx_sync_fifo (
    .clk(clk),.rst_n(rst_n)
   ,.vldin(write_tx_sys),.din(txdata_sys)
   ,.readout(write_tx),.dout(txdata)
   ,.empty(tx_sync_empty),.full(tx_sync_full)
   ,.count(tx_sync_fifo_count)
   ,.softreset(softreset)
   ,.overflow(panic_tx_fifo)
);

ig_uart ig_uart (
   .clk(clk)
  ,.rst_n(uart_rst_n)

  ,.txd(txd) ,.rxd(rxd)

  ,.control(uart_control[7:0])
  ,.status(uart_status[7:0])
  ,.baudrate(uart_baudrate[15:0])
  ,.read_rx(rx_valid)

  ,.write_tx(write_tx)
  ,.txdata(txdata[7:0])
  ,.tx_empty(tx_empty)

  ,.rxdata(rxdata)
  ,.rx_valid(rx_valid)

    ,.txbitstart(),.tx_active(),.tx_shift()
);

wire wr_baud;
reg announce = 1;
reg [3:0] evenann;
reg [15:0] between;
reg [23:0] more_between;
wire echo_fifo_empty,echo_fifo_full,readout_echo;
wire send_announce = echo_fifo_empty && announce && (between == 0) && (more_between==0);
always @(posedge clk) begin
    if (!rst_n) begin
        announce <= 1;
        evenann <= 0;
        between <= 0;
        more_between <= 0 ;
    end else begin
        if (!rx_sync_empty) begin
            announce <= 0;
            more_between <= 0;
            between <= 0;
        end else if (wr_baud)  begin 
            announce <= 1;
            more_between <= 0;
            between <= 0;
        end else if (send_announce) begin
            evenann <= (evenann == 8) ? 0 : (evenann+1);
            between <=  uart_baudrate * 256;
            if (evenann == 8) more_between <= uart_baudrate * 8196;
        end else begin
            if (announce && (between>0)) between <= between - 1 ;
            if (more_between>0) more_between <= more_between-1;
        end
    end
end

wire [8:0] [7:0]  RTU26 = " 62UTR**\n";

wire [7:0] echobyte;
wire [7:0] charA = RTU26[evenann];

wire rx_valid_ann = echo_on && ((!rx_sync_empty) || send_announce);
wire [7:0] rxdata_ann = (!rx_sync_empty) ? rxdata_sys : charA;

syncfifo_v2 #(.WID(8),.DEPTH(8)) echo_fifo (
    .clk(clk),.rst_n(rst_n)
   ,.vldin(rx_valid_ann),.din(rxdata_ann)
   ,.readout(readout_echo),.dout(echobyte)
   ,.empty(echo_fifo_empty),.full(echo_fifo_full)
   ,.count(echo_fifo_count)
   ,.softreset(softreset)
   ,.overflow()
);

wire panic1 = echo_fifo_full && rx_valid_ann;

wire prdata_fifo_write = s_pready_int && s_penable && !s_pwrite;
wire [31:0] rpacket;

wire [31:0] prdata_fifo_din = 
    uart2extram_d4 ? qqdata : 
    s_prdata;

wire prdata_fifo_vldin  = prdata_fifo_write || uart2extram_d4; 

wire rdata_fifo_full;
syncfifo_v2 #(.WID(32),.DEPTH(4)) prdata_fifo (
    .clk(clk),.rst_n(rst_n)
   ,.vldin(prdata_fifo_vldin),.din(prdata_fifo_din)
   ,.readout(readout_rdata),.dout(rpacket)
   ,.empty(rdata_fifo_empty),.full(rdata_fifo_full)
   ,.count(prdata_fifo_count)
   ,.softreset(softreset)
   ,.overflow()
);
wire panic0 = rdata_fifo_full && prdata_fifo_write;

wire [7:0] tx_rdata;
wire rdata_txvalid,rdata_txtaken;
tx_sender #(.WID(32)) tx_sender (
    .clk(clk),.rst_n(rst_n)
    ,.vldin(!rdata_fifo_empty)
    ,.din(rpacket)
    ,.done(readout_rdata)
    ,.txdata(tx_rdata)
    ,.txvalid(rdata_txvalid)
    ,.txtaken(rdata_txtaken)
);


assign rdata_txtaken = !rx_sync_full && (tx_sync_fifo_count < 2040);
assign write_tx_sys = (rdata_txvalid && rdata_txtaken) || (rdata_txtaken && !echo_fifo_empty);
assign txdata_sys = rdata_txvalid ? tx_rdata : echobyte ;
assign readout_echo = !rx_sync_full && !rdata_txvalid  && !echo_fifo_empty;



wire [31:0] status = 0; // ILIA TBD

dbgparser #(.BAUDRATE(BAUDRATE),.DWID(32)) dbgparser (
     .clk(clk)
    ,.drct_addr(drct_addr[31:0])
    ,.drct_rd(drct_rd)
    ,.drct_wdata(drct_wdata)
    ,.drct_wr(drct_wr)
    ,.rst_n(rst_n)
    ,.rx_valid(!rx_sync_empty)
    ,.rxdata(rxdata_sys[7:0])
    ,.uart_baudrate(uart_baudrate)
    ,.wr_baud(wr_baud)
    ,.echo_on(echo_on)
    ,.softreset(softreset)
    ,.status(status)
);

wire [63:0]  sign_version = 64'h5f8bc9f64e151126 ;
endmodule
// FROMFILE 5f8bc 9f64e :: /Users/iliagreenblat/projects/fplp/verila/src/ig_debuguart.v


