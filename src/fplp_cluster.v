`default_nettype wire
`timescale 1ns / 1ps
module fplp_cluster  #(parameter BAUDRATE=416) (input clk, input rst_n
    ,output [11:0] pin_out
    ,output [11:0] tri_out
    ,input  [11:0] pin_in

    ,output [31:0] leds

    ,input rxd_i, output txd_o
);


wire [3:0] cmd_pin ;
wire [9:0] cmd_time ;
wire cmd_catch_change ;
wire cmd_catch_time ;
wire cmd_tri_now ;
wire cmd_tri_future ;
wire cmd_force_now ;
wire cmd_force_future ;
wire cmd_value;

wire [31:0] s_paddr;
wire        s_penable;
wire [31:0] s_prdata;
wire        s_pready;
wire        s_psel;
wire        s_pslverr = 0;
wire [3:0]  s_pstrb;
wire [31:0] s_pwdata;
wire        s_pwrite;


wire read_pins;

wire uart2extram;
wire [31:0] drct_addr;
wire  drct_rd;
wire [31:0] drct_wdata;
wire  drct_wr;
wire   [31:0] drct_rdata;



ig_debuguart #(.BAUDRATE(BAUDRATE)) ig_debuguart (.clk(clk) ,.reset_n(rst_n)
    ,.rxd   (rxd_i  )
    ,.txd   (txd_o  )

    ,.interrupt (1'b0)

    
    ,.s_paddr   (s_paddr[31:0]  )
    ,.s_penable (s_penable      )
    ,.s_prdata  (s_prdata[31:0] )
    ,.s_pready  (s_pready       )
    ,.s_psel    (s_psel         )
    ,.s_pslverr (s_pslverr      )
    ,.s_pstrb   (s_pstrb[3:0]   )
    ,.s_pwdata  (s_pwdata[31:0] )
    ,.s_pwrite  (s_pwrite       )

    ,.uart2extram(uart2extram)
    ,.drct_addr(drct_addr)
    ,.drct_rd(drct_rd)
    ,.drct_wdata(drct_wdata)
    ,.drct_wr(drct_wr)
    ,.drct_rdata(drct_rdata)

);

wire [15:0] version = 'h2409;
wire ctrl_enable,ctrl_softreset,ctrl_event_to_rgf;
wire [7:0] status = 0;

wire [16:0] uart_command;
wire uart_command_pulse;

wire [11:0] pin_sampled;
wire [15:0] io_events;
wire io_events_pulse;

wire [16:0] command;
wire [11:0] enable_in_neg;
wire [11:0] enable_in_pos;
wire [11:0] enable_in_threads;
wire io_event_vld;
wire [11:0] bus_value;
wire [3:0] bunched_ios;

reg [9:0] global_time;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        global_time <= 0;
    end else if (!ctrl_enable) begin
        global_time <= 0;
    end else begin
        global_time <= global_time+1;
    end
end

wire [31:0] prdata;
assign s_prdata = prdata;

wire [15:0] fplp_paddr  ;
wire        fplp_penable;
wire        fplp_psel   ;
wire [3:0]  fplp_pstrb  ;
wire [31:0] fplp_pwdata ;
assign fplp_pwdata[31:16] = 0;
wire        fplp_pwrite ;
wire [31:0] fplp_prdata = prdata ;
wire xsel = fplp_psel && !fplp_paddr[15];

wire        psel    = xsel || s_psel;
wire [31:0] paddr   = xsel ? {16'b0,fplp_paddr}   : s_paddr;
wire        penable = xsel ? fplp_penable : s_penable;
wire [3:0]  pstrb   = xsel ? fplp_pstrb   : s_pstrb;
wire [31:0] pwdata  = xsel ? fplp_pwdata  : s_pwdata;
wire        pwrite  = xsel ? fplp_pwrite  : s_pwrite;

assign s_pready =  !fplp_psel;

wire [15:0] io_events_count;
wire [3:0] prog_thread;
wire [11:0] prog_pc;

wire [7:0] fifo0;
wire fifo0_pulse;
wire [15:0] fifo0count;
wire [7:0] fifo0out;
wire fifo0out_pulse;

wire [7:0] fifo1;
wire fifo1_pulse;
wire [15:0] fifo1count;
wire [7:0] fifo1out;
wire fifo1out_pulse;



wire fifo0_empty,fifo1_empty;
wire fifo1out_pulse_pos;
posedge_detect pos_fifo1 (.clk(clk),.rst_n(rst_n),.din(fifo1out_pulse),.dout(fifo1out_pulse_pos));

syncfifo #(.WID(8),.DEPTH(4)) fifo0fifo (.clk(clk),.rst_n(rst_n)
    ,.din(fifo0),.vldin(fifo0_pulse),.dout(fifo0out),.readout(fifo0out_pulse)
    ,.count(fifo0count),.empty(fifo0_empty),.full(),.overflow()
    ,.softreset(ctrl_softreset)
);
syncfifo #(.WID(8),.DEPTH(4)) fifo1fifo (.clk(clk),.rst_n(rst_n)
    ,.din(fifo1),.vldin(fifo1_pulse),.dout(fifo1out),.readout(fifo1out_pulse_pos)
    ,.count(fifo1count),.empty(fifo1_empty),.full(),.overflow()
    ,.softreset(ctrl_softreset)
);
wire [3:0] ext_event;
wire ext_event_vld;
reg was_psel;
always @(posedge clk) was_psel <= psel;
wire psel_pulse = !was_psel && psel;
wire psel_final = pwrite ? psel_pulse : psel;
wire prog_vld;
fplp_rgf fplp_rgf (.pclk(clk),.presetn(rst_n)
    ,.pwrite(pwrite),.paddr(paddr[7:0]),.psel(psel_final),.penable(penable)
    ,.prdata(prdata),.prdata_wire(),.pwdata(pwdata),.pstrb(pstrb)
    ,.pready(),.pslverr()
    ,.softreset(1'b0)

    ,.version(version)
    ,.ctrl_operate(ctrl_enable)
    ,.ctrl_softreset(ctrl_softreset)
    ,.ctrl_event_to_rgf(ctrl_event_to_rgf)
    ,.status(status)
    ,.global_time(global_time)
    ,.bunched_ios(bunched_ios)
    ,.enable_in_neg(enable_in_neg)
    ,.enable_in_pos(enable_in_pos)
    ,.enable_in_threads(enable_in_threads)
    ,.uart_command(uart_command)
    ,.uart_command_pulse(uart_command_pulse)
    ,.pin_sampled(pin_sampled)
    ,.io_events_count(io_events_count[3:0])
    ,.io_events(io_events)
    ,.io_events_pulse(io_events_pulse)
    ,.bus_value(bus_value)
    ,.leds(leds)
    ,.prog_data_pulse(prog_vld)
    ,.prog_data({prog_thread,prog_pc})
    ,.fifo0(fifo0)
    ,.fifo0_pulse(fifo0_pulse)
    ,.fifo0count(fifo0count[7:0])
    ,.fifo0out(fifo0out)
    ,.fifo0out_pulse(fifo0out_pulse)

    ,.fifo1(fifo1)
    ,.fifo1_pulse(fifo1_pulse)
    ,.fifo1count(fifo1count[7:0])
    ,.fifo1out(fifo1out)
    ,.fifo1out_pulse(fifo1out_pulse)

    ,.ext_event(ext_event)
    ,.ext_event_pulse(ext_event_vld)

    ,.scratchpad()
    ,.param0()
    ,.param1()
    ,.param2()
    ,.param3()
);

wire [31:0] qq;
wire [15:0] cpu_addr;
wire cpu_rd;

wire  [3:0] pin_event;
wire  [9:0] pin_event_timing;
wire  pin_event_vld;


wire cmd_vld;
cpu_cluster cpu_cluster (
     .clk(clk) ,.rst_n(rst_n)
    ,.softreset(ctrl_softreset)
    ,.pwrite(fplp_pwrite),.paddr(fplp_paddr[15:0]),.psel(fplp_psel),.penable(fplp_penable)
    ,.prdata(fplp_prdata),.pwdata(fplp_pwdata[15:0]),.pstrb(fplp_pstrb)
    ,.pready(1'b1),.pslverr(1'b0)

    ,.cmd_vld(cmd_vld)
    ,.cmd_value(cmd_value)
    ,.cmd_pin(cmd_pin)
    ,.cmd_time(cmd_time)
    ,.cmd_catch_change(cmd_catch_change)
    ,.cmd_catch_time(cmd_catch_time)
    ,.cmd_tri_now(cmd_tri_now)
    ,.cmd_tri_future(cmd_tri_future)
    ,.cmd_force_now(cmd_force_now)
    ,.cmd_force_future(cmd_force_future)


    ,.global_time(global_time[9:0])
    ,.io_event_vld(io_event_vld)

    ,.cpu_rd(cpu_rd)
    ,.cpu_addr(cpu_addr)
    ,.cpu_rdata(qq)

    ,.prog_vld(prog_vld)
    ,.prog_thread(prog_thread)
    ,.prog_pc(prog_pc)

    ,.pin_event(pin_event)
    ,.pin_event_timing(pin_event_timing)
    ,.pin_event_vld(pin_event_vld)

    ,.ext_event(ext_event)
    ,.ext_event_vld(ext_event_vld)

    ,.read_pins(read_pins)
    ,.io_events(io_events)
);

wire drct_access = uart2extram && (drct_wr || drct_rd);
wire wen = ~(drct_wr && uart2extram);
wire cen = ~(cpu_rd || drct_access);

// wire [31:0] wmask = drct_access ? 32'hffffffff : cpu_wmask ;
wire [31:0] wmask = 32'hffffffff ;
wire [13:0] aa = drct_access ? drct_addr[13:0] : cpu_addr[13:0] ;
wire [31:0] dd = drct_wdata;

assign drct_rdata = qq;

ram_32bit_4096addr ram (
     .CK(clk)
    ,.D(dd[31:0])
    ,.Q(qq[31:0])
    ,.A(aa[13:0])
    ,.WEN(wen)
    ,.CEN(cen)
    ,.WMASK(wmask)
);


io_cluster io_cluster (
     .clk(clk) ,.rst_n(rst_n)

    ,.cmd_vld(cmd_vld)
    ,.cmd_pin(cmd_pin)
    ,.cmd_value(cmd_value)
    ,.cmd_time(cmd_time)
    ,.cmd_catch_change(cmd_catch_change)
    ,.cmd_catch_time(cmd_catch_time)
    ,.cmd_tri_now(cmd_tri_now)
    ,.cmd_tri_future(cmd_tri_future)
    ,.cmd_force_now(cmd_force_now)
    ,.cmd_force_future(cmd_force_future)

    ,.enable_in_neg(enable_in_neg)
    ,.enable_in_pos(enable_in_pos)
    ,.enable_in_threads(enable_in_threads)
    ,.global_time(global_time[9:0])
    ,.io_event_vld(io_event_vld)
    ,.io_events(io_events[15:0])
    ,.io_event_read(io_events_pulse || ctrl_event_to_rgf || read_pins)
    ,.io_events_count(io_events_count)
    ,.pin_in(pin_in[11:0])
    ,.pin_out(pin_out[11:0])
    ,.pin_sampled(pin_sampled)
    ,.tri_out(tri_out)
    ,.bunched_ios(bunched_ios)
    ,.bus_value(bus_value)

    ,.pin_event(pin_event)
    ,.pin_event_timing(pin_event_timing)
    ,.pin_event_vld(pin_event_vld)
);


wire [63:0]  sign_version = 64'hb4d4c94ade151126 ;
endmodule
// FROMFILE b4d4c 94ade :: /Users/iliagreenblat/projects/fplp/verila/src/fplp_cluster.v


