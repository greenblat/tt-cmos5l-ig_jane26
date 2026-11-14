module fplpx_decoder(input [7:0] opcode,input valid,output not_opcode
,output nop_code
,output [7:0] nop_opcode
,output yield_code
,output load_code
,output store_code
,output stori_code
,output call_code
,output return_code
,output loadi8_code
,output loadi16_code
,output loadi_code
,output addi_code
,output add_code
,output sub_code
,output and_code
,output or_code
,output land_code
,output lor_code
,output select_code
,output xor_code
,output neg_code
,output not_code
,output shiftl_code
,output mask_code
,output global_time_code
,output thread_timing_code
,output exchange_code
,output sleep_code
,output apbrd_code
,output apbwr_code
,output cpu_now_event_code
,output cpu_future_event_code
,output io_set_pin_code
,output io_catch_change_code
,output io_catch_time_stack_code
,output io_tri_now_code
,output io_force_now_code
,output io_force_future_stack_code
,output io_tri_future_stack_code
,output io_tri_future_code
,output io_catch_time_code
,output io_force_future_code
,output jump_code
,output jumpzero_code
,output jumpnotzero_code
,output jumppos_code
,output jumpneg_code
,output jumpgt_code
,output jumpeq_code
,output skipzero_code
,output skipnotzero_code
,output skippos_code
,output skipneg_code
,output skipgt_code
,output skipeq_code
,output pop_code
,output dup_code
,output read_pins_code
,output [2:0] imm_field
,output addr_field
,output [3:0] lit_field
,output [3:0] indx_field
,output [3:0] thread_field
,output [3:0] pin_field
,output val_field
,output [1:0] skip_field
,output second_flag
,output push1_flag
,output third_flag
,output dual_flag
,output triple_flag
,output single_flag
);
assign nop_code = valid && ((opcode & 8'hf8)==8'h68) ;
assign nop_opcode = 8'h68;
assign yield_code = valid && ((opcode & 8'hff)==8'h19) ;
assign load_code = valid && ((opcode & 8'hfe)==8'h36) ;
assign store_code = valid && ((opcode & 8'hfe)==8'h34) ;
assign stori_code = valid && ((opcode & 8'he0)==8'he0) ;
assign call_code = valid && ((opcode & 8'hfe)==8'h32) ;
assign return_code = valid && ((opcode & 8'hff)==8'h18) ;
assign loadi8_code = valid && ((opcode & 8'hff)==8'h17) ;
assign loadi16_code = valid && ((opcode & 8'hff)==8'h16) ;
assign loadi_code = valid && ((opcode & 8'hf0)==8'hd0) ;
assign addi_code = valid && ((opcode & 8'hf0)==8'hc0) ;
assign add_code = valid && ((opcode & 8'hff)==8'h15) ;
assign sub_code = valid && ((opcode & 8'hff)==8'h14) ;
assign and_code = valid && ((opcode & 8'hff)==8'h13) ;
assign or_code = valid && ((opcode & 8'hff)==8'h12) ;
assign land_code = valid && ((opcode & 8'hff)==8'h11) ;
assign lor_code = valid && ((opcode & 8'hff)==8'h10) ;
assign select_code = valid && ((opcode & 8'hff)==8'h0f) ;
assign xor_code = valid && ((opcode & 8'hff)==8'h0e) ;
assign neg_code = valid && ((opcode & 8'hff)==8'h0d) ;
assign not_code = valid && ((opcode & 8'hff)==8'h0c) ;
assign shiftl_code = valid && ((opcode & 8'hf0)==8'hb0) ;
assign mask_code = valid && ((opcode & 8'hf0)==8'ha0) ;
assign global_time_code = valid && ((opcode & 8'hff)==8'h0b) ;
assign thread_timing_code = valid && ((opcode & 8'hff)==8'h0a) ;
assign exchange_code = valid && ((opcode & 8'hf8)==8'h60) ;
assign sleep_code = valid && ((opcode & 8'hff)==8'h09) ;
assign apbrd_code = valid && ((opcode & 8'hfe)==8'h30) ;
assign apbwr_code = valid && ((opcode & 8'hfe)==8'h2e) ;
assign cpu_now_event_code = valid && ((opcode & 8'hf0)==8'h90) ;
assign cpu_future_event_code = valid && ((opcode & 8'hf0)==8'h80) ;
assign io_set_pin_code = valid && ((opcode & 8'hf0)==8'h70) ;
assign io_catch_change_code = valid && ((opcode & 8'hff)==8'h08) ;
assign io_catch_time_stack_code = valid && ((opcode & 8'hff)==8'h07) ;
assign io_tri_now_code = valid && ((opcode & 8'hff)==8'h06) ;
assign io_force_now_code = valid && ((opcode & 8'hfe)==8'h2c) ;
assign io_force_future_stack_code = valid && ((opcode & 8'hfe)==8'h2a) ;
assign io_tri_future_stack_code = valid && ((opcode & 8'hff)==8'h05) ;
assign io_tri_future_code = valid && ((opcode & 8'hff)==8'h04) ;
assign io_catch_time_code = valid && ((opcode & 8'hff)==8'h03) ;
assign io_force_future_code = valid && ((opcode & 8'hfe)==8'h28) ;
assign jump_code = valid && ((opcode & 8'hfe)==8'h26) ;
assign jumpzero_code = valid && ((opcode & 8'hfe)==8'h24) ;
assign jumpnotzero_code = valid && ((opcode & 8'hfe)==8'h22) ;
assign jumppos_code = valid && ((opcode & 8'hfe)==8'h20) ;
assign jumpneg_code = valid && ((opcode & 8'hfe)==8'h1e) ;
assign jumpgt_code = valid && ((opcode & 8'hfe)==8'h1c) ;
assign jumpeq_code = valid && ((opcode & 8'hfe)==8'h1a) ;
assign skipzero_code = valid && ((opcode & 8'hfc)==8'h4c) ;
assign skipnotzero_code = valid && ((opcode & 8'hfc)==8'h48) ;
assign skippos_code = valid && ((opcode & 8'hfc)==8'h44) ;
assign skipneg_code = valid && ((opcode & 8'hfc)==8'h40) ;
assign skipgt_code = valid && ((opcode & 8'hfc)==8'h3c) ;
assign skipeq_code = valid && ((opcode & 8'hfc)==8'h38) ;
assign pop_code = valid && ((opcode & 8'hf8)==8'h58) ;
assign dup_code = valid && ((opcode & 8'hf8)==8'h50) ;
assign read_pins_code = valid && ((opcode & 8'hff)==8'h02) ;
assign not_opcode = !(
    nop_code ||yield_code ||load_code ||store_code ||stori_code ||call_code
     ||return_code ||loadi8_code ||loadi16_code ||loadi_code ||addi_code
     ||add_code ||sub_code ||and_code ||or_code ||land_code ||lor_code
     ||select_code ||xor_code ||neg_code ||not_code ||shiftl_code
     ||mask_code ||global_time_code ||thread_timing_code ||exchange_code
     ||sleep_code ||apbrd_code ||apbwr_code ||cpu_now_event_code
     ||cpu_future_event_code ||io_set_pin_code ||io_catch_change_code
     ||io_catch_time_stack_code ||io_tri_now_code ||io_force_now_code
     ||io_force_future_stack_code ||io_tri_future_stack_code ||io_tri_future_code
     ||io_catch_time_code ||io_force_future_code ||jump_code ||jumpzero_code
     ||jumpnotzero_code ||jumppos_code ||jumpneg_code ||jumpgt_code
     ||jumpeq_code ||skipzero_code ||skipnotzero_code ||skippos_code
     ||skipneg_code ||skipgt_code ||skipeq_code ||pop_code ||dup_code
     ||read_pins_code);
assign imm_field[0] = opcode[0];
assign imm_field[1] = opcode[1];
assign imm_field[2] = opcode[2];
assign addr_field = opcode[0];
assign lit_field[0] = opcode[1];
assign lit_field[1] = opcode[2];
assign lit_field[2] = opcode[3];
assign lit_field[3] = opcode[4];
assign indx_field[0] = opcode[0];
assign indx_field[1] = opcode[1];
assign indx_field[2] = opcode[2];
assign indx_field[3] = opcode[3];
assign thread_field[0] = opcode[0];
assign thread_field[1] = opcode[1];
assign thread_field[2] = opcode[2];
assign thread_field[3] = opcode[3];
assign pin_field[0] = opcode[0];
assign pin_field[1] = opcode[1];
assign pin_field[2] = opcode[2];
assign pin_field[3] = opcode[3];
assign val_field = opcode[0];
assign skip_field[0] = opcode[0];
assign skip_field[1] = opcode[1];
assign second_flag = valid && (yield_code ||load_code ||store_code ||stori_code ||call_code ||loadi8_code ||loadi16_code ||apbrd_code ||apbwr_code ||cpu_now_event_code ||cpu_future_event_code ||io_tri_future_code ||io_catch_time_code ||io_force_future_code ||jump_code ||jumpzero_code ||jumpnotzero_code ||jumppos_code ||jumpneg_code ||jumpgt_code ||jumpeq_code);
assign push1_flag = valid && (load_code ||loadi8_code ||loadi_code ||read_pins_code);
assign third_flag = valid && (loadi16_code);
assign dual_flag = valid && (add_code ||sub_code ||and_code ||or_code ||land_code ||lor_code ||xor_code);
assign triple_flag = valid && (select_code);
assign single_flag = valid && (neg_code ||not_code ||shiftl_code ||mask_code ||pop_code);
endmodule

