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
  wire       clk100m_ext;
  wire       dir;               // 1: encode / 0: decode
  wire       halt;
  wire       bist;
  wire       pll_en;
  wire [1:0] dbg_sel;
  wire       mcht_rxd;

  assign {mcht_rxd, dbg_sel, pll_en, bist, halt, dir, clk100m_ext} = ui_in;


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

  logic       tx_vld;
  logic [7:0] tx_msg;
  wire        tx_dne;

  wire        rx_vld;

  wire        pll_clko;
  PLL4X       pll4x_0 ( .CLK25I ( clk ),       // I
                        .CLK4XO ( pll_clko ),  // O
                        .RST_N  ( rst_n )
                      );

  wire        clk100m;
  assign      clk100m = pll_en? pll_clko :  clk100m_ext; 



  defparam u_mcht_trx_0.pTX_MSG_LEN = 8;
  defparam u_mcht_trx_0.pRX_MSG_LEN = 8;
  MCHT_TRX u_mcht_trx_0 (
                           .TXD        ( mcht_txd  ),  // O
                           .RXD        ( mcht_rxdi ),  // I

                           .TX_VLD     ( tx_vld ),     // I
                           .TX_MSG     ( tx_msg ),    // I pMSG_LEN
                           .TX_DNE     ( tx_dne ),     // O

                           .RX_MSG     ( dec_rxd ),    // O pMSG_LEN
                           .RX_VLD     ( rx_vld ),     // O

                           .CLK_25M    ( clk ),        // I
                           .CLK100M    ( clk100m ),    // I
                           .RST_N      ( rst_n )  // I
                        );


  logic tx_drv;
  always_ff @(posedge clk or negedge rst_n)
    if( !rst_n )
      tx_vld <= 1'b0;
    else
      tx_vld <= tx_drv;
  
  always_ff @(posedge clk or negedge rst_n)
    if( !rst_n )
      tx_msg <= 8'h00;
    else
      if( tx_drv )
        tx_msg <= enc_txd;


  // FSM
  logic [2:0] tx_sm;
   
  always_ff @(posedge clk or negedge rst_n)
    if( !rst_n ) begin
      tx_sm  <= 3'd0;
      tx_drv <= 1'b0;
      end
    else
      case( tx_sm )
        3'd0:    begin tx_sm <= 3'd1; tx_drv <= 1'b0; end
        3'd1:    begin tx_sm <= 3'd2; tx_drv <= 1'b0; end
        3'd2:    begin tx_sm <= 3'd3; tx_drv <= 1'b1; end
        3'd3:    begin tx_sm <= 3'd4; tx_drv <= 1'b0; end
        3'd4:    begin tx_sm <= 3'd5; tx_drv <= 1'b0; end
        3'd5:    if( tx_dne )
                 begin tx_sm <= 3'd6; tx_drv <= 1'b0; end
                 else
                 begin tx_sm <= 3'd5; tx_drv <= 1'b0; end

        3'd6:    begin tx_sm <= 3'd7; tx_drv <= 1'b0; end 
        3'd7:    begin tx_sm <= 3'd0; tx_drv <= 1'b0; end 
        default: begin tx_sm <= 3'd0; tx_drv <= 1'b0; end
      endcase
  
  
  logic [7:0] tx_msg_bak;
  always_ff @(posedge clk or negedge rst_n)
    if( !rst_n )
      tx_msg_bak <= 8'h00;
    else
      if( tx_dne & bist )
        tx_msg_bak <= tx_msg;
  
  // ----------------------------------------------------------------------------
  // ----------------------------------------------------------------------------
  // DBG_OUT
  logic bist_er;
  always_comb
    if( bist )
      dbg_out = {6'b000_000, bist_er};
    else
      case( dbg_sel )
        2'd0: dbg_out = {ena, clk, rst_n, bist, clk100m, dir, halt};
        2'd1: dbg_out = {4'b0000, mcht_txd, mcht_rxdi, mcht_rxd};
        2'd2: dbg_out = 7'b000_0000;
        2'd3: dbg_out = 7'b000_0000;
      endcase

   //   3'd4: dbg_out = 7'b000_0000;
   //   3'd5: dbg_out = 7'b000_0000;
   //   3'd6: dbg_out = 7'b000_0000;
   //   3'd7: dbg_out = 7'b000_0000;
   // endcase



  // ----------------------------------------------------------------------------
  // ----------------------------------------------------------------------------
  // BIST Logic
  // Internal loopback, Tx compare with Rx
  logic cmp_err;
  always_ff @(posedge clk or negedge rst_n)
    if( !rst_n )
      cmp_err <= 1'b0;
    else
      cmp_err <= cmp_err | (rx_vld? (|(tx_msg_bak ^ dec_rxd)) : 1'b0);
      
  assign bist_er = bist & cmp_err;



endmodule // tt_um_patrick_lin_git_mcht_trx
