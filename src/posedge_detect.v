
// posedge_detect pos_fifo1 (.clk(clk),.rst_n(rst_n),.din(fifo1out_pulse),.dout(fifo1out_pulse_pos));

module posedge_detect(
    input clk, input rst_n
    ,input din, output dout
);

reg was; 
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) was <= 0;
    else was <= din;
end

assign dout = !was && din;

endmodule

