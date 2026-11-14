`default_nettype wire
module doorbells #(parameter THREADS=16) ( input clk, input rst_n
    ,input softreset
    ,input [9:0] global_time

    ,input [3:0]   pin_event
    ,input [9:0]   pin_event_timing
    ,input         pin_event_vld

    ,input [3:0]   cpu_event
    ,input [9:0]   cpu_event_timing
    ,input [11:0]   cpu_event_pc
    ,input [1:0]   cpu_event_mode
    ,input         cpu_event_vld

    ,output        next_ready
    ,output [9:0]  next_timing
    ,output [11:0] next_pc
    ,output [3:0]  next_thread
    ,input         next_taken

    ,input        prog_vld
    ,input [3:0]  prog_thread
    ,input [11:0] prog_pc

    ,input [3:0] ext_event
    ,input ext_event_vld
);


reg [THREADS-1:0] [9:0] timings;
reg [THREADS-1:0] [11:0] pcs;
reg [THREADS-1:0]  futures; // waiting for future time or next run time
reg [THREADS-1:0]  readies; // waiting for future time or next run time


wire [11:0] dbg0 = pcs[0];
wire [11:0] dbg1 = pcs[1];
wire [11:0] dbg2 = pcs[2];
wire [11:0] dbg3 = pcs[3];
wire [11:0] dbg4 = pcs[4];
wire [11:0] dbg5 = pcs[5];
wire [9:0]  tdbg3 = timings[3];

assign next_ready = readies!=0;
assign next_thread = 
    readies[0] ? 0 :
    readies[1] ? 1 :
    readies[2] ? 2 :
    readies[3] ? 3 :
    readies[4] ? 4 :
    readies[5] ? 5 :
    readies[6] ? 6 :
    readies[7] ? 7 :
    readies[8] ? 8 :
    readies[9] ? 9 :
    readies[10] ? 10 :
    readies[11] ? 11 :
    readies[12] ? 12 :
    readies[13] ? 13 :
    readies[14] ? 14 :
    readies[15] ? 15 :
    0;

assign next_pc = pcs[next_thread];
assign next_timing = timings[next_thread];


integer ii;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        timings <= 0;
        pcs     <= 0;
        readies   <= 0;
        futures   <= 0;
    end else begin
        if (prog_vld) begin
            pcs[prog_thread] <= prog_pc;
        end 
        if (pin_event_vld) begin
            timings[pin_event] <= pin_event_timing;
            readies[pin_event]   <= 1;
        end
        if (cpu_event_vld) begin
            timings[cpu_event] <= cpu_event_timing;
            if (cpu_event_pc!=0) pcs[cpu_event] <= cpu_event_pc; 
            readies[cpu_event]   <= cpu_event_mode[0];
            futures[cpu_event]   <= cpu_event_mode[1];
        end
        if (ext_event_vld) begin
            timings[ext_event] <= global_time;
//            pcs[ext_event] <= 0; 
            readies[ext_event]   <= 1;
        end

        for (ii=0;ii<THREADS;ii=ii+1) begin
            if ((futures[ii] == 1) && (timings[ii] == global_time)) begin
                futures[ii] <= 0;
                readies[ii] <= 1;
            end
        end

        if (next_taken && next_ready) begin
            readies[next_thread] <= 0;
        end
    end
end


endmodule

