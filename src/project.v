/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_greenblat_protocoler (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

wire [31:0] leds;
wire [11:0] pin_in;
wire [11:0] pin_out;
wire [11:0] tri_out;

wire rxd_i = ui_in[0];
wire txd_o;
assign uo_out[0] = txd_o;
assign uo_out[4:1] = leds[3:0];
assign uo_out[7:5] = pin_out[11:9];
assign pin_in[11:8] = ui_in[7:4];

assign uio_out = pin_out[7:0];
assign pin_in[7:0] = uio_in[7:0];
assign uio_oe =  tri_out;

fplp_cluster #(.BAUDRATE(50)) fplp_cluster (
     .clk(clk)
    ,.leds(leds[31:0])
    ,.pin_in(pin_in[11:0])
    ,.pin_out(pin_out[11:0])
    ,.tri_out(tri_out[11:0])
    ,.rst_n(rst_n)
    ,.rxd_i(rxd_i)
    ,.txd_o(txd_o)
);








endmodule
