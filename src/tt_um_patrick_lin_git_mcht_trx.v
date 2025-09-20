/*
 * Copyright (c) 2024 Patrick Lin
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_patrick_lin_git_mcht_trx
(
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)

    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  /*
  // All output pins must be assigned. If not used, assign to 0.
  assign uo_out  = ui_in + uio_in;  // Example: ou_out is the sum of ui_in and uio_in
  assign uio_out = 0;
  assign uio_oe  = 0;

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, clk, rst_n, 1'b0};
  */

  // ----------------------------------------------------------------------------
  // ----------------------------------------------------------------------------
  // OUT
  wire        mcht_txd;
  logic [6:0] dbg_out;

  assign uo_out = {mcht_txd, dbg_out};


  // ----------------------------------------------------------------------------
  // ----------------------------------------------------------------------------
  // IN
  wire       clk100m;
  wire       dir;               // 1: encode / 0: decode
  wire       halt;
  wire       bist;
  wire [2:0] dbg_sel;
  wire       mcht_rxd;

  assign {mcht_rxd, dbg_sel, bist, halt, dir, clk100m} = ui_in;


  // ----------------------------------------------------------------------------
  // ----------------------------------------------------------------------------
  // BIDIR
  assign uio_oe  = {8{bist? 1'b0 : ~dir}};

  wire [7:0] dec_rxd;
  assign uio_out = dec_rxd;

  wire [7:0] enc_txd;
  assign enc_txd = uio_in;



  // ----------------------------------------------------------------------------
  // ----------------------------------------------------------------------------
  // core logic
  wire mcht_rxdi = bist? mcht_txd : (dir? 1'b1 : mcht_rxd);

  defparam u_mcht_trx_0.pTX_MSG_LEN = 8;
  defparam u_mcht_trx_0.pRX_MSG_LEN = 8;
  MCHT_TRX u_mcht_trx_0 (
                           .TXD        ( mcht_txd  ),  // O
                           .RXD        ( mcht_rxdi ),  // I

                           .TX_VLD     ( tx_vld ),     // I
                           .TX_MSG     ( tx_msg ),     // I pMSG_LEN
                           .TX_DNE     ( tx_dne ),     // O

                           .RX_MSG     ( rx_msg ),     // O pMSG_LEN
                           .RX_VLD     ( rx_vld ),     // O

                           .CLK_25M    ( core_clk ),   // I
                           .CLK100M    ( mcht_clk ),   // I
                           .RST_N      ( pwon_rst_n )  // I
                        );


  
  
  // ----------------------------------------------------------------------------
  // ----------------------------------------------------------------------------
  // DBG_OUT
  logic dbg_out;
  always_comb
    if( bist )
      dbg_out = 7'b000_0000;
    else
      case( dbg_sel )
        3'd0: dbg_out = {ena, clk, rst_n, bist, clk100m, dir, halt};
        3'd1: dbg_out = {4'b0000, mcht_txd, mcht_rxdi, mcht_rxd};
        3'd2: dbg_out = 7'b000_0000;
        3'd3: dbg_out = 7'b000_0000;
        3'd4: dbg_out = 7'b000_0000;
        3'd5: dbg_out = 7'b000_0000;
        3'd6: dbg_out = 7'b000_0000;
        3'd7: dbg_out = 7'b000_0000;
      endcase



  // ----------------------------------------------------------------------------
  // ----------------------------------------------------------------------------
  // BIST Logic
  // Internal loopback, Tx compare with Rx

endmodule
