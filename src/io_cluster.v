`default_nettype wire
module io_cluster (input clk, input rst_n
    ,output [11:0] pin_out
    ,output [11:0] tri_out
    ,input  [11:0] pin_in
    ,input [3:0] bunched_ios
    ,input cmd_vld
    ,input [3:0] cmd_pin
    ,input [9:0] cmd_time
    ,input cmd_value
    ,input cmd_catch_change
    ,input cmd_catch_time
    ,input cmd_tri_now
    ,input cmd_tri_future
    ,input cmd_force_now
    ,input cmd_force_future

    ,input [11:0] bus_value
    ,input [9:0] global_time
    ,input [11:0] enable_in_neg
    ,input [11:0] enable_in_pos
    ,input [11:0] enable_in_threads
    ,output [11:0] pin_sampled
    ,output [15:0] io_events
    ,output io_event_vld
    ,output [15:0] io_events_count
    ,input io_event_read
    ,output  [3:0] pin_event
    ,output  [9:0] pin_event_timing
    ,output   pin_event_vld
);
wire [11:0] event_vld;
wire [11:0] [11:0] event_data;
wire [11:0] clear_event;

wire [3:0] dbg_pin_dst = cmd_pin;
wire [12:0] command;

wire part_of_bus0 = (bunched_ios>0) && (bunched_ios<0);
wire cmd_vld0 =  cmd_vld && ( (cmd_pin == 0) || part_of_bus0);
wire modified_cmd_value0 = part_of_bus0 ? bus_value[0] : cmd_value;

iopin iopin0 (
     .clk(clk) ,.rst_n(rst_n)
    ,.cmd_vld(cmd_vld0)
    ,.cmd_time(cmd_time)
    ,.cmd_value(modified_cmd_value0)
    ,.cmd_catch_change(cmd_catch_change)
    ,.cmd_catch_time(cmd_catch_time)
    ,.cmd_tri_now(cmd_tri_now)
    ,.cmd_tri_future(cmd_tri_future)
    ,.cmd_force_now(cmd_force_now)
    ,.cmd_force_future(cmd_force_future)

    ,.global_time(global_time)
    ,.enable_in_neg(enable_in_neg[0])
    ,.enable_in_pos(enable_in_pos[0])
    ,.pin_in(pin_in[0])
    ,.pin_out(pin_out[0])
    ,.tri_out(tri_out[0])
    ,.pin_sampled(pin_sampled[0])
    ,.event_vld(event_vld[0])
    ,.event_data(event_data[0])
    ,.clear_event(clear_event[0])
);
wire part_of_bus1 = (bunched_ios>0) && (bunched_ios<1);
wire cmd_vld1 =  cmd_vld && ( (cmd_pin == 1) || part_of_bus1);
wire modified_cmd_value1 = part_of_bus1 ? bus_value[1] : cmd_value;

iopin iopin1 (
     .clk(clk) ,.rst_n(rst_n)
    ,.cmd_vld(cmd_vld1)
    ,.cmd_time(cmd_time)
    ,.cmd_value(modified_cmd_value1)
    ,.cmd_catch_change(cmd_catch_change)
    ,.cmd_catch_time(cmd_catch_time)
    ,.cmd_tri_now(cmd_tri_now)
    ,.cmd_tri_future(cmd_tri_future)
    ,.cmd_force_now(cmd_force_now)
    ,.cmd_force_future(cmd_force_future)

    ,.global_time(global_time)
    ,.enable_in_neg(enable_in_neg[1])
    ,.enable_in_pos(enable_in_pos[1])
    ,.pin_in(pin_in[1])
    ,.pin_out(pin_out[1])
    ,.tri_out(tri_out[1])
    ,.pin_sampled(pin_sampled[1])
    ,.event_vld(event_vld[1])
    ,.event_data(event_data[1])
    ,.clear_event(clear_event[1])
);
wire part_of_bus2 = (bunched_ios>0) && (bunched_ios<2);
wire cmd_vld2 =  cmd_vld && ( (cmd_pin == 2) || part_of_bus2);
wire modified_cmd_value2 = part_of_bus2 ? bus_value[2] : cmd_value;

iopin iopin2 (
     .clk(clk) ,.rst_n(rst_n)
    ,.cmd_vld(cmd_vld2)
    ,.cmd_time(cmd_time)
    ,.cmd_value(modified_cmd_value2)
    ,.cmd_catch_change(cmd_catch_change)
    ,.cmd_catch_time(cmd_catch_time)
    ,.cmd_tri_now(cmd_tri_now)
    ,.cmd_tri_future(cmd_tri_future)
    ,.cmd_force_now(cmd_force_now)
    ,.cmd_force_future(cmd_force_future)

    ,.global_time(global_time)
    ,.enable_in_neg(enable_in_neg[2])
    ,.enable_in_pos(enable_in_pos[2])
    ,.pin_in(pin_in[2])
    ,.pin_out(pin_out[2])
    ,.tri_out(tri_out[2])
    ,.pin_sampled(pin_sampled[2])
    ,.event_vld(event_vld[2])
    ,.event_data(event_data[2])
    ,.clear_event(clear_event[2])
);
wire part_of_bus3 = (bunched_ios>0) && (bunched_ios<3);
wire cmd_vld3 =  cmd_vld && ( (cmd_pin == 3) || part_of_bus3);
wire modified_cmd_value3 = part_of_bus3 ? bus_value[3] : cmd_value;

iopin iopin3 (
     .clk(clk) ,.rst_n(rst_n)
    ,.cmd_vld(cmd_vld3)
    ,.cmd_time(cmd_time)
    ,.cmd_value(modified_cmd_value3)
    ,.cmd_catch_change(cmd_catch_change)
    ,.cmd_catch_time(cmd_catch_time)
    ,.cmd_tri_now(cmd_tri_now)
    ,.cmd_tri_future(cmd_tri_future)
    ,.cmd_force_now(cmd_force_now)
    ,.cmd_force_future(cmd_force_future)

    ,.global_time(global_time)
    ,.enable_in_neg(enable_in_neg[3])
    ,.enable_in_pos(enable_in_pos[3])
    ,.pin_in(pin_in[3])
    ,.pin_out(pin_out[3])
    ,.tri_out(tri_out[3])
    ,.pin_sampled(pin_sampled[3])
    ,.event_vld(event_vld[3])
    ,.event_data(event_data[3])
    ,.clear_event(clear_event[3])
);
wire part_of_bus4 = (bunched_ios>0) && (bunched_ios<4);
wire cmd_vld4 =  cmd_vld && ( (cmd_pin == 4) || part_of_bus4);
wire modified_cmd_value4 = part_of_bus4 ? bus_value[4] : cmd_value;

iopin iopin4 (
     .clk(clk) ,.rst_n(rst_n)
    ,.cmd_vld(cmd_vld4)
    ,.cmd_time(cmd_time)
    ,.cmd_value(modified_cmd_value4)
    ,.cmd_catch_change(cmd_catch_change)
    ,.cmd_catch_time(cmd_catch_time)
    ,.cmd_tri_now(cmd_tri_now)
    ,.cmd_tri_future(cmd_tri_future)
    ,.cmd_force_now(cmd_force_now)
    ,.cmd_force_future(cmd_force_future)

    ,.global_time(global_time)
    ,.enable_in_neg(enable_in_neg[4])
    ,.enable_in_pos(enable_in_pos[4])
    ,.pin_in(pin_in[4])
    ,.pin_out(pin_out[4])
    ,.tri_out(tri_out[4])
    ,.pin_sampled(pin_sampled[4])
    ,.event_vld(event_vld[4])
    ,.event_data(event_data[4])
    ,.clear_event(clear_event[4])
);
wire part_of_bus5 = (bunched_ios>0) && (bunched_ios<5);
wire cmd_vld5 =  cmd_vld && ( (cmd_pin == 5) || part_of_bus5);
wire modified_cmd_value5 = part_of_bus5 ? bus_value[5] : cmd_value;

iopin iopin5 (
     .clk(clk) ,.rst_n(rst_n)
    ,.cmd_vld(cmd_vld5)
    ,.cmd_time(cmd_time)
    ,.cmd_value(modified_cmd_value5)
    ,.cmd_catch_change(cmd_catch_change)
    ,.cmd_catch_time(cmd_catch_time)
    ,.cmd_tri_now(cmd_tri_now)
    ,.cmd_tri_future(cmd_tri_future)
    ,.cmd_force_now(cmd_force_now)
    ,.cmd_force_future(cmd_force_future)

    ,.global_time(global_time)
    ,.enable_in_neg(enable_in_neg[5])
    ,.enable_in_pos(enable_in_pos[5])
    ,.pin_in(pin_in[5])
    ,.pin_out(pin_out[5])
    ,.tri_out(tri_out[5])
    ,.pin_sampled(pin_sampled[5])
    ,.event_vld(event_vld[5])
    ,.event_data(event_data[5])
    ,.clear_event(clear_event[5])
);
wire part_of_bus6 = (bunched_ios>0) && (bunched_ios<6);
wire cmd_vld6 =  cmd_vld && ( (cmd_pin == 6) || part_of_bus6);
wire modified_cmd_value6 = part_of_bus6 ? bus_value[6] : cmd_value;

iopin iopin6 (
     .clk(clk) ,.rst_n(rst_n)
    ,.cmd_vld(cmd_vld6)
    ,.cmd_time(cmd_time)
    ,.cmd_value(modified_cmd_value6)
    ,.cmd_catch_change(cmd_catch_change)
    ,.cmd_catch_time(cmd_catch_time)
    ,.cmd_tri_now(cmd_tri_now)
    ,.cmd_tri_future(cmd_tri_future)
    ,.cmd_force_now(cmd_force_now)
    ,.cmd_force_future(cmd_force_future)

    ,.global_time(global_time)
    ,.enable_in_neg(enable_in_neg[6])
    ,.enable_in_pos(enable_in_pos[6])
    ,.pin_in(pin_in[6])
    ,.pin_out(pin_out[6])
    ,.tri_out(tri_out[6])
    ,.pin_sampled(pin_sampled[6])
    ,.event_vld(event_vld[6])
    ,.event_data(event_data[6])
    ,.clear_event(clear_event[6])
);
wire part_of_bus7 = (bunched_ios>0) && (bunched_ios<7);
wire cmd_vld7 =  cmd_vld && ( (cmd_pin == 7) || part_of_bus7);
wire modified_cmd_value7 = part_of_bus7 ? bus_value[7] : cmd_value;

iopin iopin7 (
     .clk(clk) ,.rst_n(rst_n)
    ,.cmd_vld(cmd_vld7)
    ,.cmd_time(cmd_time)
    ,.cmd_value(modified_cmd_value7)
    ,.cmd_catch_change(cmd_catch_change)
    ,.cmd_catch_time(cmd_catch_time)
    ,.cmd_tri_now(cmd_tri_now)
    ,.cmd_tri_future(cmd_tri_future)
    ,.cmd_force_now(cmd_force_now)
    ,.cmd_force_future(cmd_force_future)

    ,.global_time(global_time)
    ,.enable_in_neg(enable_in_neg[7])
    ,.enable_in_pos(enable_in_pos[7])
    ,.pin_in(pin_in[7])
    ,.pin_out(pin_out[7])
    ,.tri_out(tri_out[7])
    ,.pin_sampled(pin_sampled[7])
    ,.event_vld(event_vld[7])
    ,.event_data(event_data[7])
    ,.clear_event(clear_event[7])
);
wire part_of_bus8 = (bunched_ios>0) && (bunched_ios<8);
wire cmd_vld8 =  cmd_vld && ( (cmd_pin == 8) || part_of_bus8);
wire modified_cmd_value8 = part_of_bus8 ? bus_value[8] : cmd_value;

iopin iopin8 (
     .clk(clk) ,.rst_n(rst_n)
    ,.cmd_vld(cmd_vld8)
    ,.cmd_time(cmd_time)
    ,.cmd_value(modified_cmd_value8)
    ,.cmd_catch_change(cmd_catch_change)
    ,.cmd_catch_time(cmd_catch_time)
    ,.cmd_tri_now(cmd_tri_now)
    ,.cmd_tri_future(cmd_tri_future)
    ,.cmd_force_now(cmd_force_now)
    ,.cmd_force_future(cmd_force_future)

    ,.global_time(global_time)
    ,.enable_in_neg(enable_in_neg[8])
    ,.enable_in_pos(enable_in_pos[8])
    ,.pin_in(pin_in[8])
    ,.pin_out(pin_out[8])
    ,.tri_out(tri_out[8])
    ,.pin_sampled(pin_sampled[8])
    ,.event_vld(event_vld[8])
    ,.event_data(event_data[8])
    ,.clear_event(clear_event[8])
);
wire part_of_bus9 = (bunched_ios>0) && (bunched_ios<9);
wire cmd_vld9 =  cmd_vld && ( (cmd_pin == 9) || part_of_bus9);
wire modified_cmd_value9 = part_of_bus9 ? bus_value[9] : cmd_value;

iopin iopin9 (
     .clk(clk) ,.rst_n(rst_n)
    ,.cmd_vld(cmd_vld9)
    ,.cmd_time(cmd_time)
    ,.cmd_value(modified_cmd_value9)
    ,.cmd_catch_change(cmd_catch_change)
    ,.cmd_catch_time(cmd_catch_time)
    ,.cmd_tri_now(cmd_tri_now)
    ,.cmd_tri_future(cmd_tri_future)
    ,.cmd_force_now(cmd_force_now)
    ,.cmd_force_future(cmd_force_future)

    ,.global_time(global_time)
    ,.enable_in_neg(enable_in_neg[9])
    ,.enable_in_pos(enable_in_pos[9])
    ,.pin_in(pin_in[9])
    ,.pin_out(pin_out[9])
    ,.tri_out(tri_out[9])
    ,.pin_sampled(pin_sampled[9])
    ,.event_vld(event_vld[9])
    ,.event_data(event_data[9])
    ,.clear_event(clear_event[9])
);
wire part_of_bus10 = (bunched_ios>0) && (bunched_ios<10);
wire cmd_vld10 =  cmd_vld && ( (cmd_pin == 10) || part_of_bus10);
wire modified_cmd_value10 = part_of_bus10 ? bus_value[10] : cmd_value;

iopin iopin10 (
     .clk(clk) ,.rst_n(rst_n)
    ,.cmd_vld(cmd_vld10)
    ,.cmd_time(cmd_time)
    ,.cmd_value(modified_cmd_value10)
    ,.cmd_catch_change(cmd_catch_change)
    ,.cmd_catch_time(cmd_catch_time)
    ,.cmd_tri_now(cmd_tri_now)
    ,.cmd_tri_future(cmd_tri_future)
    ,.cmd_force_now(cmd_force_now)
    ,.cmd_force_future(cmd_force_future)

    ,.global_time(global_time)
    ,.enable_in_neg(enable_in_neg[10])
    ,.enable_in_pos(enable_in_pos[10])
    ,.pin_in(pin_in[10])
    ,.pin_out(pin_out[10])
    ,.tri_out(tri_out[10])
    ,.pin_sampled(pin_sampled[10])
    ,.event_vld(event_vld[10])
    ,.event_data(event_data[10])
    ,.clear_event(clear_event[10])
);
wire part_of_bus11 = (bunched_ios>0) && (bunched_ios<11);
wire cmd_vld11 =  cmd_vld && ( (cmd_pin == 11) || part_of_bus11);
wire modified_cmd_value11 = part_of_bus11 ? bus_value[11] : cmd_value;

iopin iopin11 (
     .clk(clk) ,.rst_n(rst_n)
    ,.cmd_vld(cmd_vld11)
    ,.cmd_time(cmd_time)
    ,.cmd_value(modified_cmd_value11)
    ,.cmd_catch_change(cmd_catch_change)
    ,.cmd_catch_time(cmd_catch_time)
    ,.cmd_tri_now(cmd_tri_now)
    ,.cmd_tri_future(cmd_tri_future)
    ,.cmd_force_now(cmd_force_now)
    ,.cmd_force_future(cmd_force_future)

    ,.global_time(global_time)
    ,.enable_in_neg(enable_in_neg[11])
    ,.enable_in_pos(enable_in_pos[11])
    ,.pin_in(pin_in[11])
    ,.pin_out(pin_out[11])
    ,.tri_out(tri_out[11])
    ,.pin_sampled(pin_sampled[11])
    ,.event_vld(event_vld[11])
    ,.event_data(event_data[11])
    ,.clear_event(clear_event[11])
);

wire vldin = event_vld!=0;
wire [3:0] selected = 
    event_vld[0] ? 0 :
    event_vld[1] ? 1 :
    event_vld[2] ? 2 :
    event_vld[3] ? 3 :
    event_vld[4] ? 4 :
    event_vld[5] ? 5 :
    event_vld[6] ? 6 :
    event_vld[7] ? 7 :
    event_vld[8] ? 8 :
    event_vld[9] ? 9 :
    event_vld[10] ? 10 :
    event_vld[11] ? 11 :
    0;
wire [15:0]  new_data = {selected,event_data[selected]};
assign clear_event = vldin ? (1<<selected) : 0;
wire panic_fifo,fifo_empty,fifo_full;
syncfifo_v2 #(16,6) fifo (.clk(clk),.rst_n(rst_n),.vldin(vldin)
    ,.din(new_data)
    ,.empty(fifo_empty),.full(fifo_full)
    ,.readout(io_event_read)
    ,.dout(io_events)
    ,.count(io_events_count),.overflow(panic_fifo)
    ,.softreset(1'b0)
);
assign io_event_vld = !fifo_empty;
assign pin_event = selected;
wire [11:0] event_data_selected = event_data[selected];
assign pin_event_timing = event_data_selected[11:2];
assign pin_event_vld = vldin && enable_in_threads[selected];
endmodule


