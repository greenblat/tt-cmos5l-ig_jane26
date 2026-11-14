`default_nettype wire
module fplp_rgf (input pclk, input presetn, input softreset
    ,input psel, input penable, input pwrite, input [4-1:0] pstrb, input [8-1:0] paddr, input [32-1:0] pwdata, output [32-1:0] prdata,output [32-1:0] prdata_wire
    ,output pready, output pslverr
    ,input [15:0] version
    ,input [7:0] status
    ,input [9:0] global_time
    ,output [3:0] bunched_ios
    ,output [11:0] enable_in_neg
    ,output [11:0] enable_in_pos
    ,output [11:0] enable_in_threads
    ,output [16:0] uart_command
    ,output uart_command_pulse
    ,input [11:0] pin_sampled
    ,input [15:0] io_events
    ,output io_events_pulse
    ,input [3:0] io_events_count
    ,output [11:0] bus_value
    ,output [31:0] leds
    ,output [31:0] scratchpad
    ,output [15:0] prog_data
    ,output prog_data_pulse
    ,output [15:0] param0
    ,output [15:0] param1
    ,output [15:0] param2
    ,output [15:0] param3
    ,output [7:0] fifo0
    ,output fifo0_pulse
    ,input [7:0] fifo0count
    ,input [7:0] fifo0out
    ,output fifo0out_pulse
    ,output [7:0] fifo1
    ,output fifo1_pulse
    ,input [7:0] fifo1count
    ,input [7:0] fifo1out
    ,output fifo1out_pulse
    ,output [3:0] ext_event
    ,output ext_event_pulse
    ,output  ctrl_operate
    ,output  ctrl_softreset
    ,output  ctrl_event_to_rgf
);
    wire [2:0] control; // hhh

wire i_pread = psel && !pwrite;
wire i_pwrite = psel && pwrite && penable;
assign pslverr = 0;
assign pready = 1;
wire [31:0] last_wdata;

wire [1023:0] ZEROES = 1024'b0;
fplp_rgf_ram rgf (.pclk(pclk),.presetn(presetn),.softreset(softreset),.pwrite(i_pwrite),.pread(i_pread),.paddr(paddr)
    ,.pwdata(pwdata),.prdata(prdata),.prdata_wire(prdata_wire)
    ,.pstrb(pstrb),.last_wdata(last_wdata)
    ,.penable(penable),.pready()
    ,.version(version)
    ,.control(control)
    ,.status(status)
    ,.global_time(global_time)
    ,.bunched_ios(bunched_ios)
    ,.enable_in_neg(enable_in_neg)
    ,.enable_in_pos(enable_in_pos)
    ,.enable_in_threads(enable_in_threads)
    ,.uart_command(uart_command)
    ,.uart_command_pulse(uart_command_pulse)
    ,.pin_sampled(pin_sampled)
    ,.io_events(io_events)
    ,.io_events_pulse(io_events_pulse)
    ,.io_events_count(io_events_count)
    ,.bus_value(bus_value)
    ,.leds(leds)
    ,.scratchpad(scratchpad)
    ,.prog_data(prog_data)
    ,.prog_data_pulse(prog_data_pulse)
    ,.param0(param0)
    ,.param1(param1)
    ,.param2(param2)
    ,.param3(param3)
    ,.fifo0(fifo0)
    ,.fifo0_pulse(fifo0_pulse)
    ,.fifo0count(fifo0count)
    ,.fifo0out(fifo0out)
    ,.fifo0out_pulse(fifo0out_pulse)
    ,.fifo1(fifo1)
    ,.fifo1_pulse(fifo1_pulse)
    ,.fifo1count(fifo1count)
    ,.fifo1out(fifo1out)
    ,.fifo1out_pulse(fifo1out_pulse)
    ,.ext_event(ext_event)
    ,.ext_event_pulse(ext_event_pulse)
);
assign ctrl_operate = control[0];
assign ctrl_softreset = control[1];
assign ctrl_event_to_rgf = control[2];
endmodule
`timescale 1ns / 1ps
module fplp_rgf_ram (
    input pclk,input presetn, input softreset, input pwrite, input pread, input penable
    ,input [32-1:0] pwdata, output [32-1:0] prdata, output [32-1:0] prdata_wire
    ,input [4-1:0] pstrb
    ,input [8-1:0] paddr ,output reg [32-1:0] last_wdata
    ,output pready
    ,input [15:0] version
    ,output reg [2:0] control
    ,input [7:0] status
    ,input [9:0] global_time
    ,output reg [3:0] bunched_ios
    ,output reg [11:0] enable_in_neg
    ,output reg [11:0] enable_in_pos
    ,output reg [11:0] enable_in_threads
    ,output reg [16:0] uart_command
    ,output uart_command_pulse
    ,input [11:0] pin_sampled
    ,input [15:0] io_events
    ,output io_events_pulse
    ,input [3:0] io_events_count
    ,output reg [11:0] bus_value
    ,output reg [31:0] leds
    ,output reg [31:0] scratchpad
    ,output reg [15:0] prog_data
    ,output prog_data_pulse
    ,output reg [15:0] param0
    ,output reg [15:0] param1
    ,output reg [15:0] param2
    ,output reg [15:0] param3
    ,output reg [7:0] fifo0
    ,output fifo0_pulse
    ,input [7:0] fifo0count
    ,input [7:0] fifo0out
    ,output fifo0out_pulse
    ,output reg [7:0] fifo1
    ,output fifo1_pulse
    ,input [7:0] fifo1count
    ,input [7:0] fifo1out
    ,output fifo1out_pulse
    ,output reg [3:0] ext_event
    ,output ext_event_pulse
);
wire [32-1:0] wdata = pwdata;

wire [8-1:0] mpaddr0 =  8'hfc & (paddr - 'h0);
wire [8-1:0] mpaddr = (pread||pwrite) ? mpaddr0  : 0;
assign prdata_wire =

    (mpaddr == 'h0) ? {16'b0,version} :
    (mpaddr == 'h4) ? {29'b0,control} :
    (mpaddr == 'h8) ? {24'b0,status} :
    (mpaddr == 'hc) ? {22'b0,global_time} :
    (mpaddr == 'h10) ? {28'b0,bunched_ios} :
    (mpaddr == 'h14) ? {20'b0,enable_in_neg} :
    (mpaddr == 'h18) ? {20'b0,enable_in_pos} :
    (mpaddr == 'h1c) ? {20'b0,enable_in_threads} :
    (mpaddr == 'h20) ? {15'b0,uart_command} :
    (mpaddr == 'h24) ? {20'b0,pin_sampled} :
    (mpaddr == 'h28) ? {16'b0,io_events} :
    (mpaddr == 'h2c) ? {28'b0,io_events_count} :
    (mpaddr == 'h30) ? {20'b0,bus_value} :
    (mpaddr == 'h34) ? leds[31:0] :
    (mpaddr == 'h38) ? scratchpad[31:0] :
    (mpaddr == 'h3c) ? {16'b0,prog_data} :
    (mpaddr == 'h40) ? {16'b0,param0} :
    (mpaddr == 'h44) ? {16'b0,param1} :
    (mpaddr == 'h48) ? {16'b0,param2} :
    (mpaddr == 'h4c) ? {16'b0,param3} :
    (mpaddr == 'h50) ? {24'b0,fifo0} :
    (mpaddr == 'h54) ? {24'b0,fifo0count} :
    (mpaddr == 'h58) ? {24'b0,fifo0out} :
    (mpaddr == 'h5c) ? {24'b0,fifo1} :
    (mpaddr == 'h60) ? {24'b0,fifo1count} :
    (mpaddr == 'h64) ? {24'b0,fifo1out} :
    (mpaddr == 'h68) ? {28'b0,ext_event} :
    32'hdeadbeef;



reg [32-1:0] prdata_reg;
always @(posedge pclk) prdata_reg <=  prdata_wire;
assign pready = 1;

assign prdata =   
    prdata_reg;

wire [32-1:0] mask = { {{8{pstrb[3]}},{8{pstrb[2]}},{8{pstrb[1]}},{8{pstrb[0]}}} };
always @(posedge pclk) if (pwrite) last_wdata <= wdata & mask;
always @(posedge pclk or negedge presetn) begin
    if (!presetn) begin 
        control <= 3'h0;
        bunched_ios <= 4'h0;
        enable_in_neg <= 12'h0;
        enable_in_pos <= 12'h0;
        enable_in_threads <= 12'h0;
        uart_command <= 17'h0;
        bus_value <= 12'h0;
        leds <= 32'h0;
        scratchpad <= 32'h0;
        prog_data <= 16'h0;
        param0 <= 16'h0;
        param1 <= 16'h0;
        param2 <= 16'h0;
        param3 <= 16'h0;
        fifo0 <= 8'h0;
        fifo1 <= 8'h0;
        ext_event <= 4'h0;
    end else if (softreset)  begin
        control <= 3'h0;
        bunched_ios <= 4'h0;
        enable_in_neg <= 12'h0;
        enable_in_pos <= 12'h0;
        enable_in_threads <= 12'h0;
        uart_command <= 17'h0;
        bus_value <= 12'h0;
        leds <= 32'h0;
        scratchpad <= 32'h0;
        prog_data <= 16'h0;
        param0 <= 16'h0;
        param1 <= 16'h0;
        param2 <= 16'h0;
        param3 <= 16'h0;
        fifo0 <= 8'h0;
        fifo1 <= 8'h0;
        ext_event <= 4'h0;
    end else if (pwrite)  begin
        if (mpaddr == 'h4) control <= (control & ~mask[2:0]) | (wdata[2:0] & mask[2:0]);
        if (mpaddr == 'h10) bunched_ios <= (bunched_ios & ~mask[3:0]) | (wdata[3:0] & mask[3:0]);
        if (mpaddr == 'h14) enable_in_neg <= (enable_in_neg & ~mask[11:0]) | (wdata[11:0] & mask[11:0]);
        if (mpaddr == 'h18) enable_in_pos <= (enable_in_pos & ~mask[11:0]) | (wdata[11:0] & mask[11:0]);
        if (mpaddr == 'h1c) enable_in_threads <= (enable_in_threads & ~mask[11:0]) | (wdata[11:0] & mask[11:0]);
        if (mpaddr == 'h20) uart_command <= (uart_command & ~mask[16:0]) | (wdata[16:0] & mask[16:0]);
        if (mpaddr == 'h30) bus_value <= (bus_value & ~mask[11:0]) | (wdata[11:0] & mask[11:0]);
        if (mpaddr == 'h34) leds <= (leds & ~mask) | (wdata & mask);
        if (mpaddr == 'h38) scratchpad <= (scratchpad & ~mask) | (wdata & mask);
        if (mpaddr == 'h3c) prog_data <= (prog_data & ~mask[15:0]) | (wdata[15:0] & mask[15:0]);
        if (mpaddr == 'h40) param0 <= (param0 & ~mask[15:0]) | (wdata[15:0] & mask[15:0]);
        if (mpaddr == 'h44) param1 <= (param1 & ~mask[15:0]) | (wdata[15:0] & mask[15:0]);
        if (mpaddr == 'h48) param2 <= (param2 & ~mask[15:0]) | (wdata[15:0] & mask[15:0]);
        if (mpaddr == 'h4c) param3 <= (param3 & ~mask[15:0]) | (wdata[15:0] & mask[15:0]);
        if (mpaddr == 'h50) fifo0 <= (fifo0 & ~mask[7:0]) | (wdata[7:0] & mask[7:0]);
        if (mpaddr == 'h5c) fifo1 <= (fifo1 & ~mask[7:0]) | (wdata[7:0] & mask[7:0]);
        if (mpaddr == 'h68) ext_event <= (ext_event & ~mask[3:0]) | (wdata[3:0] & mask[3:0]);
    end
end

wire uart_command_wr_sel = pwrite && (mpaddr=='h20);
reg uart_command_wr_pulse_reg; always @(posedge pclk or negedge presetn)  if (!presetn) uart_command_wr_pulse_reg<=0; else uart_command_wr_pulse_reg <= uart_command_wr_sel;
assign uart_command_pulse = uart_command_wr_pulse_reg;


wire io_events_rd_sel = pread && (mpaddr=='h28);
reg io_events_rd_pulse_reg; always @(posedge pclk or negedge presetn)  if (!presetn) io_events_rd_pulse_reg<=0; else io_events_rd_pulse_reg <= io_events_rd_sel;
assign io_events_pulse = io_events_rd_pulse_reg && penable;


wire prog_data_wr_sel = pwrite && (mpaddr=='h3c);
reg prog_data_wr_pulse_reg; always @(posedge pclk or negedge presetn)  if (!presetn) prog_data_wr_pulse_reg<=0; else prog_data_wr_pulse_reg <= prog_data_wr_sel;
assign prog_data_pulse = prog_data_wr_pulse_reg;


wire fifo0_wr_sel = pwrite && (mpaddr=='h50);
reg fifo0_wr_pulse_reg; always @(posedge pclk or negedge presetn)  if (!presetn) fifo0_wr_pulse_reg<=0; else fifo0_wr_pulse_reg <= fifo0_wr_sel;
assign fifo0_pulse = fifo0_wr_pulse_reg;


wire fifo0out_rd_sel = pread && (mpaddr=='h58);
reg fifo0out_rd_pulse_reg; always @(posedge pclk or negedge presetn)  if (!presetn) fifo0out_rd_pulse_reg<=0; else fifo0out_rd_pulse_reg <= fifo0out_rd_sel;
assign fifo0out_pulse = fifo0out_rd_pulse_reg && penable;


wire fifo1_wr_sel = pwrite && (mpaddr=='h5c);
reg fifo1_wr_pulse_reg; always @(posedge pclk or negedge presetn)  if (!presetn) fifo1_wr_pulse_reg<=0; else fifo1_wr_pulse_reg <= fifo1_wr_sel;
assign fifo1_pulse = fifo1_wr_pulse_reg;


wire fifo1out_rd_sel = pread && (mpaddr=='h64);
reg fifo1out_rd_pulse_reg; always @(posedge pclk or negedge presetn)  if (!presetn) fifo1out_rd_pulse_reg<=0; else fifo1out_rd_pulse_reg <= fifo1out_rd_sel;
assign fifo1out_pulse = fifo1out_rd_pulse_reg && penable;


wire ext_event_wr_sel = pwrite && (mpaddr=='h68);
reg ext_event_wr_pulse_reg; always @(posedge pclk or negedge presetn)  if (!presetn) ext_event_wr_pulse_reg<=0; else ext_event_wr_pulse_reg <= ext_event_wr_sel;
assign ext_event_pulse = ext_event_wr_pulse_reg;

endmodule
