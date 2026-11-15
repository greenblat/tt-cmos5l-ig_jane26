`default_nettype wire
`timescale 1ns / 1ps

module cpu_cluster (input clk, input rst_n
    ,input softreset

    ,output  [15:0] paddr
    ,output  [15:0] pwdata
    ,output         psel
    ,output        penable
    ,output        pwrite
    ,output [3:0]  pstrb
    ,input         pready
    ,input         pslverr
    ,input  [31:0] prdata

    ,output cmd_vld
    ,output [3:0] cmd_pin
    ,output [9:0] cmd_time
    ,output cmd_value
    ,output cmd_catch_change
    ,output cmd_catch_time
    ,output cmd_tri_now
    ,output cmd_tri_future
    ,output cmd_force_now
    ,output cmd_force_future

    ,input [9:0] global_time
    ,input io_event_vld


    ,output cpu_rd
    ,output [15:0] cpu_addr
    ,input  [31:0] cpu_rdata

    ,input  prog_vld
    ,input [3:0] prog_thread
    ,input [11:0] prog_pc

    ,input  [3:0] pin_event
    ,input  [9:0] pin_event_timing
    ,input   pin_event_vld

    ,input [3:0] ext_event
    ,input ext_event_vld

    ,output read_pins
    ,input [15:0] io_events
);


wire [3:0] cpu_thread;
wire [1:0] cpu_event_mode;
wire [11:0] cpu_event_pc;
wire [9:0] cpu_event_timing;
wire  cpu_event_vld;



reg  next_taken;
wire [11:0] next_pc;
wire  next_ready;
wire [3:0] next_thread;
wire [9:0] next_timing;

doorbells doorbells (
     .clk(clk) ,.rst_n(rst_n) ,.softreset(softreset) ,.global_time(global_time)
    ,.prog_pc(prog_pc)
    ,.prog_thread(prog_thread)
    ,.prog_vld(prog_vld)

    ,.cpu_event(cpu_thread)
    ,.cpu_event_mode(cpu_event_mode)
    ,.cpu_event_pc(cpu_event_pc)
    ,.cpu_event_timing(cpu_event_timing)
    ,.cpu_event_vld(cpu_event_vld)

    ,.pin_event(pin_event)
    ,.pin_event_timing(pin_event_timing)
    ,.pin_event_vld(pin_event_vld)

    ,.ext_event(ext_event)
    ,.ext_event_vld(ext_event_vld)

    ,.next_ready(next_ready)
    ,.next_taken(next_taken)
    ,.next_pc(next_pc)
    ,.next_thread(next_thread)
    ,.next_timing(next_timing)
);


reg [9:0] thread_timing;
reg [3:0]  active_thread;
reg [11:0] thread_pc;
wire running;
reg activate_cpu;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        thread_timing <= 0;
        active_thread <= 0;
        thread_pc <= 0; 
        activate_cpu <= 0;
        next_taken <= 0;
    end else begin
        if (!running) begin
            if (next_ready) begin
                thread_timing <= next_timing;
                active_thread <= next_thread;
                thread_pc <= next_pc;
                activate_cpu <= 1;
                next_taken <= 1;
            end
        end else begin
            activate_cpu <= 0;
            next_taken <= 0;
        end
    end
end

wire [15:0] cpu_addr_a;
assign cpu_addr = cpu_addr_a>>3;
reg [1:0] was_cpu_addr; always @(posedge clk) was_cpu_addr <= cpu_addr_a[2:1];
wire [7:0] cpu_rdata8 = 
    (was_cpu_addr == 0) ? cpu_rdata[7:0] :
    (was_cpu_addr == 1) ? cpu_rdata[15:8] :
    (was_cpu_addr == 2) ? cpu_rdata[23:16] :
    (was_cpu_addr == 3) ? cpu_rdata[31:24] :
    8'hx;

fplp_cpu  cpu_top (
     .clk(clk) ,.rst_n(rst_n)
    ,.running(running)
    ,.global_time(global_time)
    ,.thread_timing(thread_timing)
    ,.active_thread(active_thread)
    ,.thread_pc(thread_pc)
    ,.activate_cpu(activate_cpu)


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

    ,.cpu_addr(cpu_addr_a)
    ,.cpu_rd(cpu_rd)
    ,.cpu_rdata(cpu_rdata8)

    ,.paddr(paddr)
    ,.penable(penable)
    ,.psel(psel)
    ,.pstrb(pstrb)
    ,.pwdata(pwdata)
    ,.pwrite(pwrite)
    ,.prdata(prdata)
    ,.pready(pready)
//    ,.pslverr(pslverr)

    ,.cpu_thread(cpu_thread)
    ,.cpu_event_mode(cpu_event_mode)
    ,.cpu_event_pc(cpu_event_pc)
    ,.cpu_event_timing(cpu_event_timing)
    ,.cpu_event_vld(cpu_event_vld)

    ,.read_pins(read_pins)
    ,.io_events(io_events)

);



wire [63:0]  sign_version = 64'hc82df480bc151126 ;
endmodule
// FROMFILE c82df 480bc :: /Users/iliagreenblat/projects/fplp/verila/src/cpu_cluster.v


