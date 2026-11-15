`default_nettype wire
`timescale 1ns / 1ps

module dbgparser #(parameter BAUDRATE=244,parameter DWID=32)(
    input clk, input rst_n
    ,input softreset
    ,input [7:0] rxdata, input rx_valid

    ,output reg [31:0] drct_addr
    ,output reg [DWID-1:0] drct_wdata
    ,output drct_wr
    ,output drct_rd

    ,output reg [15:0] uart_baudrate
    ,output wr_baud
    ,output reg echo_on

    ,input [31:0] status
);


reg [7:0] state;


wire [7:0] ST_IDLE = 0;
wire [7:0] ST_ADDR = 1;
wire [7:0] ST_LEN = 2;
wire [7:0] ST_WDATA = 3;
wire [7:0] ST_READ = 4;
wire [7:0] ST_WRITE = 5;
wire [7:0] ST_BAUDRATE = 6;
wire [7:0] ST_ECHO = 7;
wire [7:0] ST_INTERRUPT = 8;
wire [7:0] ST_GPIO = 9;
wire [7:0] ST_J0 = 10;

wire [7:0] let_A = 8'h41;
wire [7:0] let_B = 8'h42;
wire [7:0] let_L = 8'h4c;
wire [7:0] let_W = 8'h57;
wire [7:0] let_R = 8'h52;
wire [7:0] let_N = 8'h4e;
wire [7:0] let_I = 8'h49;
wire [7:0] let_G = 8'h47;
wire [7:0] let_w = 8'h77;
wire [7:0] let_J = 8'h4a;
wire [7:0] let_r = 8'h72;
wire [7:0] let_0 = 8'h30;
wire [7:0] let_9 = 8'h39;
wire [7:0] let_a = 8'h61;
wire [7:0] let_f = 8'h66;

wire hexvalid =    ((rxdata >= let_0) && (rxdata <= let_9)) 
                || ((rxdata >= let_a) && (rxdata <= let_f));
wire [7:0] tmpnibble0 = rxdata - let_0;
wire [7:0] tmpnibble1 = 10+rxdata-let_a;

wire [3:0] hexnibble = ((rxdata >= let_0) && (rxdata <= let_9)) ? tmpnibble0[3:0] : tmpnibble1[3:0];


// commands:  all commands can  be closed with "." - dot.
// B2a.    : change baudrate to 0x2a  .  baudrate is 16bit reg.
// waabbccdd.   : prepare  aabbccdd for writing.
// Waabbccdd. : actually write the data.
// W. : actually write previous wxxxx data.
// r. : read from the address.
// A1000. : set address.

reg [31:0] tmp;
reg incr_next_addr;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= ST_IDLE;
        drct_addr <= 0;
        drct_wdata <= 0;
        incr_next_addr <= 0;
        tmp <= 0;
    end else if (softreset) begin
        state <= ST_IDLE;
        drct_addr <= 0;
        drct_wdata <= 0;
        incr_next_addr <= 0;
        tmp <= 0;
    end else begin
        if (rx_valid) begin
            if (rxdata == let_A)  begin
                state <= ST_ADDR;
                drct_addr <= 0;
            end else if (rxdata == let_B)  begin
                state <= ST_BAUDRATE;
                tmp <= 0;
            end else if (rxdata == let_N)  begin
                state <= ST_ECHO;
                tmp <= 0;
            end else if (rxdata == let_I)  begin
                state <= ST_INTERRUPT;
                tmp <= 0;
            end else if (rxdata == let_G)  begin
                state <= ST_GPIO;
                tmp <= 0;
            end else if (rxdata == let_L) begin
                state <= ST_LEN;
            end else if (rxdata == let_J) begin
                state <= ST_J0;
                tmp <= 0;
            end else if (state == ST_J0) begin
                if (hexvalid) begin
                    tmp <= {tmp[27:0],hexnibble};
                end else
                    state <= ST_IDLE;
            end else if (rxdata == let_W) begin
                if (incr_next_addr) drct_addr <= drct_addr + 4;
                state <= ST_WDATA;
                incr_next_addr <= 0;
                drct_wdata <= 0;
            end else if (rxdata == let_R) begin
                incr_next_addr <= 0;
                state <= ST_READ;
            end else if (rxdata == let_r) begin
                if (incr_next_addr) drct_addr <= drct_addr + 4;
                incr_next_addr <= 0;
                state <= ST_READ;
            end else if (rxdata == let_w) begin
                if (incr_next_addr) drct_addr <= drct_addr + 4;
                state <= ST_WRITE;
                incr_next_addr <= 0;
                drct_wdata <= 0;
            end else if (state==ST_ADDR) begin
                incr_next_addr <= 0;
                if (hexvalid) begin
                    drct_addr <= {drct_addr[27:0],hexnibble};
                end else
                    state <= ST_IDLE;
            end else if (state==ST_BAUDRATE) begin
                if (hexvalid) begin
                    tmp <= {tmp[27:0],hexnibble};
                end else
                    state <= ST_IDLE;
            end else if (state==ST_ECHO) begin
                if (hexvalid) begin
                    tmp <= {tmp[27:0],hexnibble};
                end else
                    state <= ST_IDLE;
            end else if (state==ST_INTERRUPT) begin
                if (hexvalid) begin
                    tmp <= {tmp[27:0],hexnibble};
                end else
                    state <= ST_IDLE;
            end else if (state==ST_GPIO) begin
                if (hexvalid) begin
                    tmp <= {tmp[27:0],hexnibble};
                end else
                    state <= ST_IDLE;

            end else if (state==ST_WDATA) begin
                incr_next_addr <= 0;
                if (hexvalid) begin
                    drct_wdata <= {drct_wdata[DWID-5:0],hexnibble};
                end else
                    state <= ST_IDLE;
            end else if (state==ST_READ) begin
                state <= ST_IDLE;
                incr_next_addr <= 1;
            end else if (state==ST_WRITE) begin
                if (hexvalid) begin
                    drct_wdata <= {drct_wdata[DWID-5:0],hexnibble};
                end else begin
                    state <= ST_IDLE;
                    incr_next_addr <= 1;
                end
            end
        end
    end
end
reg [7:0] was_state;
always @(posedge clk) was_state <= state;
        
assign drct_rd  = (was_state == ST_READ) && (state != ST_READ);
assign drct_wr  = ((was_state == ST_WRITE) && (state != ST_WRITE)) || ((was_state == ST_WDATA) && (state != ST_WDATA));
assign wr_baud  = (was_state == ST_BAUDRATE) && (state != ST_BAUDRATE);
wire wr_echo = (was_state == ST_ECHO) && (state != ST_ECHO);
wire use_j   = (was_state == ST_J0) && (state != ST_J0);

// for simulation markings. add to rgf?
reg [15:0] jjvalue;
reg [15:0] jjseq;
always @(posedge clk) begin
    if (!rst_n)  begin
        uart_baudrate <= BAUDRATE;
        echo_on <= 1;
        jjvalue <= 0;
        jjseq <= 0;
    end else if (softreset) begin
        uart_baudrate <= BAUDRATE;
        echo_on <= 1;
        jjvalue <= 0;
        jjseq <= 0;
    end else begin
        if (wr_baud) uart_baudrate <= tmp[15:0];
        if (wr_echo) echo_on <= tmp[0];
        if  (use_j) begin
            jjseq <= jjseq + 1;
            jjvalue <= tmp[15:0];
        end
    end
end







wire [63:0]  sign_version = 64'h4b0955ae63151126 ;
endmodule
// FROMFILE 4b095 5ae63 :: /Users/iliagreenblat/projects/fplp/verila/src/dbgparser.v







