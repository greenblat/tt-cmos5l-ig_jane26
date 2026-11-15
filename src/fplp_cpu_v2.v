`default_nettype wire
`timescale 1ns / 1ps
// fplp_cpu - pipelined version
//
// Pipeline: overlapped FETCH / EXECUTE.
//   The program memory is synchronous: address presented in cycle N,
//   cpu_rdata valid in cycle N+1, one byte per cycle. Every cycle in which
//   an instruction executes, the core already presents the address of the
//   byte it will need next, so the byte stream never stops.
//
//   In S_EXEC:  popcoda = opcode at slot pc
//               cpu_rdata = byte at slot pc+1 (operand, or next opcode)
//
// Throughput (cycles per instruction):
//   1-byte ALU / stack / io / event ops ...... 1
//   2-byte ops (load/store/loadi8/events/..) . 2   (= one cycle per byte)
//   jump/call (2 bytes, taken or not) ........ 2
//   return, taken skip ....................... 2   (1 refetch bubble)
//   loadi16 (3 bytes) ........................ 3
//   apbrd .................................... 4 + pready wait states
//   sleep N .................................. N + 3 (same as before)
//
// Memory bandwidth is 1 byte/cycle, so a multi-byte instruction cannot take
// fewer cycles than its byte count; only control transfers lose a cycle.

module fplp_cpu (input clk, input rst_n
    ,input [9:0] global_time

    ,output reg  [15:0] paddr
    ,output reg  [15:0] pwdata
    ,output reg         psel
    ,output reg        penable
    ,output reg        pwrite
    ,output reg [3:0]  pstrb
    ,input         pready
//    ,input         pslverr
    ,input  [31:0] prdata

    ,output reg cmd_vld
    ,output reg [3:0] cmd_pin
    ,output reg [9:0] cmd_time
    ,output reg cmd_value
    ,output reg cmd_catch_change
    ,output reg cmd_catch_time
    ,output reg cmd_tri_now
    ,output reg cmd_tri_future
    ,output reg cmd_force_now
    ,output reg cmd_force_future


    ,output reg running
    ,input [9:0] thread_timing
    ,input [3:0]  active_thread
    ,input [11:0] thread_pc
    ,input  activate_cpu

    ,output     cpu_rd
    ,output     [15:0] cpu_addr
    ,input  [7:0] cpu_rdata

    ,output reg [3:0]   cpu_thread
    ,output reg [9:0]   cpu_event_timing
    ,output reg [11:0]  cpu_event_pc
    ,output reg [1:0]   cpu_event_mode
    ,output reg         cpu_event_vld

    ,output read_pins
    ,input [15:0] io_events

);

localparam S_IDLE   = 3'd0;   // not running
localparam S_FETCH0 = 3'd1;   // present address of pc
localparam S_FETCH1 = 3'd2;   // opcode of pc arrives -> popcoda, present pc+1
localparam S_EXEC   = 3'd3;   // execute popcoda (steady state)
localparam S_THIRD  = 3'd4;   // loadi16: high byte arrives
localparam S_APBRD  = 3'd5;   // waiting for APB read data

reg [2:0]  state;
reg [8:0]  pc;
reg [7:0]  popcoda;
reg [7:0]  popcodb;
reg [15:0] waiting;
reg [9:0]  timing;
reg [3:0]  thread_run;
reg [3:0]  apbst;

reg [3:0] [8:0]  pcstack;
wire [8:0] pcstack0 = pcstack[0];

wire [15:0] varrdata;
wire [15:0] opstack0,opstack1,opstack2;
wire [15:0] push_value;
wire push1_op, pop1_op, pop2_op, dual_op, replace_top_op;

// ---------------------------------------------------------------------------
// execute qualification
// ---------------------------------------------------------------------------
wire ex = running && (state==S_EXEC);

// an APB op must wait while a posted APB write is still in flight
wire apb_opcode = ((popcoda & 8'hfe)==8'h2e) || ((popcoda & 8'hfe)==8'h30);
wire apb_stall  = ex && apb_opcode && (apbst!=0);

wire go = ex && !apb_stall;          // instruction in popcoda executes now

// ---------------------------------------------------------------------------
// decoder (all *_code outputs are already qualified with 'go')
// ---------------------------------------------------------------------------
wire not_opcode;
wire nop_code, yield_code, load_code, store_code, stori_code, call_code;
wire return_code, loadi_code, loadi8_code, loadi16_code, addi_code;
wire add_code, sub_code, and_code, or_code, land_code, lor_code, select_code;
wire xor_code, neg_code, not_code, shiftl_code, mask_code;
wire global_time_code, thread_timing_code, exchange_code, sleep_code;
wire apbrd_code, apbwr_code, cpu_now_event_code, cpu_future_event_code;
wire io_set_pin_code, io_catch_change_code, io_catch_time_stack_code;
wire io_tri_now_code, io_force_now_code, io_force_future_stack_code;
wire io_tri_future_stack_code, io_tri_future_code, io_catch_time_code;
wire io_force_future_code;
wire jump_code, jumpzero_code, jumpnotzero_code, jumppos_code, jumpneg_code;
wire jumpgt_code, jumpeq_code;
wire skipzero_code, skipnotzero_code, skippos_code, skipneg_code;
wire skipgt_code, skipeq_code;
wire pop_code, dup_code, read_pins_code;
wire [2:0] imm_field;
wire addr_field;
wire [3:0] lit_field, indx_field, thread_field, pin_field;
wire val_field;
wire [1:0] skip_field;
wire second_flag, push1_flag, third_flag, dual_flag, triple_flag, single_flag;

fplpx_decoder fplpx_decoder (.valid(go),.opcode(popcoda)
   ,.not_opcode(not_opcode)
   ,.nop_code(nop_code)
   ,.nop_opcode()
   ,.yield_code(yield_code)
   ,.load_code(load_code)
   ,.store_code(store_code)
   ,.stori_code(stori_code)
   ,.call_code(call_code)
   ,.return_code(return_code)
   ,.loadi_code(loadi_code)
   ,.loadi8_code(loadi8_code)
   ,.loadi16_code(loadi16_code)
   ,.addi_code(addi_code)
   ,.add_code(add_code)
   ,.sub_code(sub_code)
   ,.and_code(and_code)
   ,.or_code(or_code)
   ,.land_code(land_code)
   ,.lor_code(lor_code)
   ,.select_code(select_code)
   ,.xor_code(xor_code)
   ,.neg_code(neg_code)
   ,.not_code(not_code)
   ,.shiftl_code(shiftl_code)
   ,.mask_code(mask_code)
   ,.global_time_code(global_time_code)
   ,.thread_timing_code(thread_timing_code)
   ,.exchange_code(exchange_code)
   ,.sleep_code(sleep_code)
   ,.apbrd_code(apbrd_code)
   ,.apbwr_code(apbwr_code)
   ,.cpu_now_event_code(cpu_now_event_code)
   ,.cpu_future_event_code(cpu_future_event_code)
   ,.io_set_pin_code(io_set_pin_code)
   ,.io_catch_time_code(io_catch_time_code)
   ,.io_catch_change_code(io_catch_change_code)
   ,.io_force_now_code(io_force_now_code)
   ,.io_force_future_code(io_force_future_code)
   ,.io_tri_now_code(io_tri_now_code)
   ,.io_tri_future_code(io_tri_future_code)
   ,.jump_code(jump_code)
   ,.jumpzero_code(jumpzero_code)
   ,.jumpnotzero_code(jumpnotzero_code)
   ,.jumppos_code(jumppos_code)
   ,.jumpneg_code(jumpneg_code)
   ,.jumpgt_code(jumpgt_code)
   ,.jumpeq_code(jumpeq_code)
   ,.skipzero_code(skipzero_code)
   ,.skipnotzero_code(skipnotzero_code)
   ,.skippos_code(skippos_code)
   ,.skipneg_code(skipneg_code)
   ,.skipgt_code(skipgt_code)
   ,.skipeq_code(skipeq_code)
   ,.pop_code(pop_code)
   ,.dup_code(dup_code)
   ,.imm_field(imm_field)
   ,.indx_field(indx_field)
   ,.addr_field(addr_field)
   ,.thread_field(thread_field)
   ,.pin_field(pin_field)
   ,.val_field(val_field)
   ,.skip_field(skip_field)
   ,.dual_flag(dual_flag)
   ,.triple_flag(triple_flag)
   ,.single_flag(single_flag)
   ,.second_flag(second_flag)
   ,.third_flag(third_flag)
   ,.push1_flag(push1_flag)
   ,.io_force_future_stack_code(io_force_future_stack_code)
   ,.io_tri_future_stack_code(io_tri_future_stack_code)
   ,.io_catch_time_stack_code(io_catch_time_stack_code)
   ,.lit_field(lit_field)
   ,.read_pins_code(read_pins_code)
);

// ---------------------------------------------------------------------------
// operand byte / variables
// ---------------------------------------------------------------------------
wire [9:0] cpu_rdata10 = {2'b0,cpu_rdata};
wire [8:0]  full_addr_field = {addr_field,cpu_rdata};
wire        varwrite = store_code || stori_code;
wire [15:0] wdata    = stori_code ? {12'd0,lit_field} : opstack0;

variables variables (.clk(clk),.rst_n(rst_n)
    ,.addr(full_addr_field),.mwrite(varwrite),.wdata(wdata)
    ,.rdata(varrdata)
);

// ---------------------------------------------------------------------------
// stack
// ---------------------------------------------------------------------------
wire third_push = running && (state==S_THIRD);
wire apb_rd_done = (apbst==4) && pready;
wire apb_push   = running && (state==S_APBRD) && apb_rd_done;

wire [15:0] next_opstack0 =
    third_push         ? {cpu_rdata,popcodb} :
    apb_push           ? prdata[15:0] :
    add_code           ? (opstack0 + opstack1) :
    sub_code           ? (opstack0 - opstack1) :
    and_code           ? (opstack0 & opstack1) :
    land_code          ? {15'd0,(opstack0 != 0) && (opstack1 != 0)} :
    or_code            ? (opstack0 | opstack1) :
    lor_code           ? {15'd0,(opstack0 != 0) || (opstack1 != 0)} :
    xor_code           ? (opstack0 ^ opstack1) :
    neg_code           ? -opstack0 :
    not_code           ? ~opstack0 :
    dup_code           ? opstack0 :
    global_time_code   ? {6'd0,global_time} :
    thread_timing_code ? {6'd0,timing} :
    addi_code          ? (opstack0 + {{12{indx_field[3]}},indx_field[3:0]}) :
    select_code        ? ((opstack0 != 0) ? opstack1 : opstack2) :
    loadi8_code        ? {8'd0,cpu_rdata} :
    loadi_code         ? {12'd0,indx_field[3:0]} :
    load_code          ? varrdata :
    shiftl_code        ? (opstack0 >> indx_field[3:0]) :
    mask_code          ? (opstack0 & ((16'd1<<indx_field[3:0])-16'd1)) :
    read_pins_code     ? io_events :
    16'd0;

assign push_value = next_opstack0;

assign push1_op = third_push || apb_push
    || load_code || loadi8_code || loadi_code || read_pins_code
    || dup_code || thread_timing_code || global_time_code;

assign pop1_op = pop_code || store_code || sleep_code
    || apbwr_code || apbrd_code
    || cpu_future_event_code
    || io_catch_time_code;

assign pop2_op = 1'b0;
assign dual_op = dual_flag;
assign replace_top_op = addi_code || shiftl_code || mask_code || neg_code || not_code;

fplp_stack fplp_stack(.clk(clk),.rst_n(rst_n)
    ,.opstack0(opstack0) ,.opstack1(opstack1),.opstack2(opstack2)
    ,.push_value(push_value)
    ,.push1_op(push1_op)
    ,.pop1_op(pop1_op)
    ,.pop2_op(pop2_op)
    ,.dual_op(dual_op)
    ,.replace_top_op(replace_top_op)
    ,.exchange_op(exchange_code)
    ,.exchange_dst(indx_field[2:0])
    ,.select_code(select_code)
);

// ---------------------------------------------------------------------------
// branch resolution (in S_EXEC, same cycle as the operand byte arrives)
// ---------------------------------------------------------------------------
wire c_zero = (opstack0 == 16'd0);
wire c_neg  = opstack0[15];
wire c_pos  = !opstack0[15] && !c_zero;          // signed > 0
wire c_gt   = (opstack0 > opstack1);              // unsigned, as before
wire c_eq   = (opstack0 == opstack1);

wire jump_taken = jump_code
    || (jumpzero_code    &&  c_zero)
    || (jumpnotzero_code && !c_zero)
    || (jumppos_code     &&  c_pos)
    || (jumpneg_code     &&  c_neg)
    || (jumpgt_code      &&  c_gt)
    || (jumpeq_code      &&  c_eq);

wire skip_cond =
       (skipzero_code    &&  c_zero)
    || (skipnotzero_code && !c_zero)
    || (skippos_code     &&  c_pos)
    || (skipneg_code     &&  c_neg)
    || (skipgt_code      &&  c_gt)
    || (skipeq_code      &&  c_eq);
wire skip_taken = skip_cond && (skip_field != 2'd0);

wire [8:0] pc_p1 = pc + 9'd1;
wire [8:0] pc_p2 = pc + 9'd2;
wire [8:0] pc_p3 = pc + 9'd3;
wire [8:0] skip_target = pc_p1 + {7'd0,skip_field};

// instructions that make the byte already in cpu_rdata useless as next opcode
wire redirect = call_code || jump_taken || return_code || skip_taken
    || (second_flag && !loadi16_code && !yield_code && !apbrd_code);

wire [8:0] redirect_pc =
    (call_code || jump_taken) ? full_addr_field :
    return_code               ? pcstack0 :
    skip_taken                ? skip_target :
                                pc_p2;            // end of 2-byte instruction

wire no_fetch = yield_code || sleep_code || apbrd_code;

// ---------------------------------------------------------------------------
// instruction fetch port
// ---------------------------------------------------------------------------
reg [8:0] fetch_slot;
always @(*) begin
    case (state)
        S_FETCH0: fetch_slot = pc;
        S_FETCH1: fetch_slot = pc_p1;
        S_EXEC:   fetch_slot = apb_stall    ? pc_p1 :   // re-read operand
                               loadi16_code ? pc_p2 :
                               redirect     ? redirect_pc :
                                              pc_p2;
        S_THIRD:  fetch_slot = pc_p3;
        S_APBRD:  fetch_slot = pc_p2;
        default:  fetch_slot = pc;
    endcase
end

assign cpu_addr = {6'd0,fetch_slot,1'b0};
assign cpu_rd = running && (waiting==0) && (
       (state==S_FETCH0)
    || (state==S_FETCH1)
    || ((state==S_EXEC) && !no_fetch)
    || (state==S_THIRD)
    || ((state==S_APBRD) && apb_rd_done)
    );

assign read_pins = read_pins_code;

// ---------------------------------------------------------------------------
// main sequencer
// ---------------------------------------------------------------------------
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= S_IDLE;
        running <= 0;
        pc <= 0;
        popcoda <= 0;
        popcodb <= 0;
        waiting <= 0;
        timing <= 0;
        thread_run <= 0;
        pcstack[0] <= 0;
        pcstack[1] <= 0;
        pcstack[2] <= 0;
        pcstack[3] <= 0;
        cpu_thread <= 0;
        cpu_event_vld <= 0;
        cpu_event_timing <= 0;
        cpu_event_pc <= 0;
        cpu_event_mode <= 0;
        cmd_vld <= 0;
        cmd_pin <= 0;
        cmd_time <= 0;
        cmd_value <= 0;
        cmd_catch_change <= 0;
        cmd_catch_time <= 0;
        cmd_tri_now <= 0;
        cmd_tri_future <= 0;
        cmd_force_now <= 0;
        cmd_force_future <= 0;
    end else begin
        // command / event strobes are single-cycle pulses
        cmd_vld <= 0;
        cmd_value <= 0;
        cmd_catch_change <= 0;
        cmd_catch_time <= 0;
        cmd_tri_now <= 0;
        cmd_tri_future <= 0;
        cmd_force_now <= 0;
        cmd_force_future <= 0;
        cpu_event_vld <= 0;
        cpu_event_timing <= 0;
        cpu_event_pc <= 0;
        cpu_event_mode <= 0;

        if (!running) begin
            if (activate_cpu) begin
                running <= 1;
                thread_run <= active_thread;
                timing <= thread_timing;
                pc <= thread_pc[8:0];
                state <= S_FETCH0;
            end
        end else if (waiting != 0) begin
            waiting <= waiting - 1;
        end else begin
            case (state)
            S_FETCH0: state <= S_FETCH1;

            S_FETCH1: begin
                popcoda <= cpu_rdata;
                state <= S_EXEC;
            end

            S_THIRD: begin
                pc <= pc_p3;
                state <= S_FETCH1;
            end

            S_APBRD: if (apb_rd_done) begin
                pc <= pc_p2;
                state <= S_FETCH1;
            end

            S_EXEC: if (go) begin
                // ---------------- side effects ----------------
                if (call_code) begin
                    pcstack[0] <= pc_p2;
                    pcstack[1] <= pcstack[0];
                    pcstack[2] <= pcstack[1];
                    pcstack[3] <= pcstack[2];
                end
                if (return_code) begin
                    pcstack[0] <= pcstack[1];
                    pcstack[1] <= pcstack[2];
                    pcstack[2] <= pcstack[3];
                    pcstack[3] <= 0;
                end
                if (io_set_pin_code) cmd_pin <= pin_field;
                if (io_catch_change_code) begin
                    cmd_vld <= 1; cmd_time <= 0; cmd_catch_change <= 1;
                end
                if (io_force_now_code) begin
                    cmd_vld <= 1; cmd_value <= val_field; cmd_force_now <= 1;
                end
                if (io_tri_now_code) begin
                    cmd_vld <= 1; cmd_tri_now <= 1;
                end
                if (io_catch_time_stack_code) begin
                    cmd_vld <= 1; cmd_time <= opstack0[9:0] + timing; cmd_catch_time <= 1;
                end
                if (io_force_future_stack_code) begin
                    cmd_vld <= 1; cmd_time <= opstack0[9:0] + timing;
                    cmd_force_future <= 1; cmd_value <= val_field;
                end
                if (io_tri_future_stack_code) begin
                    cmd_vld <= 1; cmd_time <= opstack0[9:0] + timing; cmd_tri_future <= 1;
                end
                if (io_catch_time_code) begin
                    cmd_vld <= 1; cmd_time <= cpu_rdata10 + timing; cmd_catch_time <= 1;
                end
                if (io_force_future_code) begin
                    cmd_vld <= 1; cmd_time <= cpu_rdata10 + timing;
                    cmd_value <= val_field; cmd_force_future <= 1;
                end
                if (io_tri_future_code) begin
                    cmd_vld <= 1; cmd_time <= cpu_rdata10 + timing; cmd_tri_future <= 1;
                end
                if (cpu_future_event_code) begin
                    cpu_event_vld <= 1;
                    cpu_event_timing <= timing + opstack0[8:0];
                    cpu_event_pc <= {4'b0,cpu_rdata[7:0]};
                    cpu_event_mode <= 2;
                    cpu_thread <= thread_field;
                end
                if (cpu_now_event_code) begin
                    cpu_event_vld <= 1;
                    cpu_event_pc <= {4'b0,cpu_rdata[7:0]};
                    cpu_event_mode <= 1;
                    cpu_thread <= thread_field;
                end

                // ---------------- sequencing ----------------
                if (yield_code) begin
                    running <= 0;
                    state <= S_IDLE;
                end else if (sleep_code) begin
                    waiting <= opstack0;
                    pc <= pc_p1;
                    state <= S_FETCH0;
                end else if (apbrd_code) begin
                    state <= S_APBRD;
                end else if (loadi16_code) begin
                    popcodb <= cpu_rdata;
                    state <= S_THIRD;
                end else if (redirect) begin
                    pc <= redirect_pc;
                    state <= S_FETCH1;
                end else begin
                    // 1-byte instruction: the next opcode is already here
                    popcoda <= cpu_rdata;
                    pc <= pc_p1;
`ifdef SIM
                    if (not_opcode)
                        $display("FAILED CPU pc=%h op=%h", pc, popcoda);
`endif
                end
            end

            default: state <= S_FETCH0;
            endcase
        end
    end
end

// ---------------------------------------------------------------------------
// APB master
// ---------------------------------------------------------------------------
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        apbst <= 0;
        psel <= 0;
        pwrite <= 0;
        penable <= 0;
        paddr <= 0;
        pwdata <= 0;
        pstrb <= 0;
    end else begin
        if (apbst==0) begin
            if (apbrd_code) begin
                paddr <= {7'b0,full_addr_field};
                pwrite <= 0;
                psel <= 1;
                pwdata <= 0;
                pstrb <= 0;
                apbst <= 3;
            end else if (apbwr_code) begin
                paddr <= {7'b0,full_addr_field};
                pwrite <= 1;
                psel <= 1;
                pwdata <= opstack0;
                pstrb <= 15;
                apbst <= 1;
            end
        end else if (apbst==1) begin
            penable <= 1;
            apbst <= 2;
        end else if (apbst==3) begin
            penable <= 1;
            apbst <= 4;
        end else if ((apbst==2)||(apbst==4)) begin
            if (pready) begin
                apbst <= 0;
                psel <= 0;
                pwrite <= 0;
                penable <= 0;
                paddr <= 0;
                pwdata <= 0;
                pstrb <= 0;
            end
        end
    end
end

wire [63:0]  sign_version = 64'he74ac371a8151126 ;
endmodule
// FROMFILE e74ac 371a8 :: /Users/iliagreenblat/projects/fplp/verila/src/fplp_cpu_v2.v

