
`ifndef VERILATOR_LINT_CHK
`endif // VERILATOR_LINT_CHK




module ADPLL_5X #(parameter pFRQCY_DIVIDER = 3'd5)
(
  input  wire       REF_CLKI,                  //  25M, 40ns
  output wire       GEN_CLKO,                  // 125M,  8ns
  output logic      LOCK,

  input  wire       LOAD_BASE,
  input  wire [7:0] BASE_DLYS,

  input  wire       RST_N 
);


  wire clk_fdbk;

  wire [4:0] up_adj;
  wire [4:0] dn_adj;
  wire       ring_osco;
  wire       f1st_sync;
  wire       too_fast;
  wire       too_slow;

  wire [4:0] up_lth;
  wire [4:0] dn_lth;

  PFD u_pfd_0 (
               .CLKI_REF   ( REF_CLKI ),   // I
               .CLKI_FBK   ( clk_fdbk ),   // I
               .CLKI_OSC   ( ring_osco ),  // I

               .UP         ( up_adj ),     // O 5
               .DN         ( dn_adj ),     // O 5
               .F1ST_SYNC  ( f1st_sync ),  // O

               .TOO_FAST   ( too_fast ),   // O
               .TOO_SLOW   ( too_slow ),   // O
               .UP_LATCH   ( up_lth ),     // I 5
               .DN_LATCH   ( dn_lth ),     // I 5
               .RST_N      ( RST_N )       // I
              );


  wire [7:0] cur_delay;
  UP_DN_CTRL u_up_dn_ctrl_0 (
                             .UP         ( up_adj ),     // I 5
                             .DN         ( dn_adj ),     // I 5
                             .F1ST_SYNC  ( f1st_sync ),  // I

                             .TOO_FAST   ( too_fast ),   // I
                             .TOO_SLOW   ( too_slow ),   // I
                             .LOAD_BASE  ( LOAD_BASE ),  // I
                             .BASE_DLYS  ( BASE_DLYS ),  // I 8
                             .CUR_DELAY  ( cur_delay ),  // O 8

                             .UP_LATCH   ( up_lth ),     // O 5
                             .DN_LATCH   ( dn_lth ),     // O 5

                             .REF_CLK    ( REF_CLKI ),   // I
                             .RST_N      ( RST_N )       // I
                            );


  wire  [64:0] dly_conn;
  logic [63:0] dly_bpss;

//wire  [32:0] dly_conn;
//logic [31:0] dly_bpss;

`ifdef dOLD_STYLE

  always_comb
    case( cur_delay[7:2] )

      6'd0:  dly_bpss = 64'b11111111_11111111_11111111_11111111_11111111_11111111_11111111_11111111;   // - 0
      6'd1:  dly_bpss = 64'b11111111_11111111_11111111_11111111_11111111_11111111_11111111_11111110;   // - 1, 2^1-1
      6'd2:  dly_bpss = 64'b11111111_11111111_11111111_11111111_11111111_11111111_11111111_11111100;   // - 3, 2^2-1
      6'd3:  dly_bpss = 64'b11111111_11111111_11111111_11111111_11111111_11111111_11111111_11111000;   // - 7, 2^3-1
      6'd4:  dly_bpss = 64'b11111111_11111111_11111111_11111111_11111111_11111111_11111111_11110000;   // -15, 2^4-1
      6'd5:  dly_bpss = 64'b11111111_11111111_11111111_11111111_11111111_11111111_11111111_11100000;
      6'd6:  dly_bpss = 64'b11111111_11111111_11111111_11111111_11111111_11111111_11111111_11000000;
      6'd7:  dly_bpss = 64'b11111111_11111111_11111111_11111111_11111111_11111111_11111111_10000000;

      6'd8:  dly_bpss = 64'b11111111_11111111_11111111_11111111_11111111_11111111_11111111_00000000;
      6'd9:  dly_bpss = 64'b11111111_11111111_11111111_11111111_11111111_11111111_11111110_00000000;
      6'd10: dly_bpss = 64'b11111111_11111111_11111111_11111111_11111111_11111111_11111100_00000000;
      6'd11: dly_bpss = 64'b11111111_11111111_11111111_11111111_11111111_11111111_11111000_00000000;
      6'd12: dly_bpss = 64'b11111111_11111111_11111111_11111111_11111111_11111111_11110000_00000000;
      6'd13: dly_bpss = 64'b11111111_11111111_11111111_11111111_11111111_11111111_11100000_00000000;
      6'd14: dly_bpss = 64'b11111111_11111111_11111111_11111111_11111111_11111111_11000000_00000000;
      6'd15: dly_bpss = 64'b11111111_11111111_11111111_11111111_11111111_11111111_10000000_00000000;

      6'd16: dly_bpss = 64'b11111111_11111111_11111111_11111111_11111111_11111111_00000000_00000000;
      6'd17: dly_bpss = 64'b11111111_11111111_11111111_11111111_11111111_11111110_00000000_00000000;
      6'd18: dly_bpss = 64'b11111111_11111111_11111111_11111111_11111111_11111100_00000000_00000000;
      6'd19: dly_bpss = 64'b11111111_11111111_11111111_11111111_11111111_11111000_00000000_00000000;
      6'd20: dly_bpss = 64'b11111111_11111111_11111111_11111111_11111111_11110000_00000000_00000000;
      6'd21: dly_bpss = 64'b11111111_11111111_11111111_11111111_11111111_11100000_00000000_00000000;
      6'd22: dly_bpss = 64'b11111111_11111111_11111111_11111111_11111111_11000000_00000000_00000000;
      6'd23: dly_bpss = 64'b11111111_11111111_11111111_11111111_11111111_10000000_00000000_00000000;

      6'd24: dly_bpss = 64'b11111111_11111111_11111111_11111111_11111111_00000000_00000000_00000000;
      6'd25: dly_bpss = 64'b11111111_11111111_11111111_11111111_11111110_00000000_00000000_00000000;
      6'd26: dly_bpss = 64'b11111111_11111111_11111111_11111111_11111100_00000000_00000000_00000000;
      6'd27: dly_bpss = 64'b11111111_11111111_11111111_11111111_11111000_00000000_00000000_00000000;
      6'd28: dly_bpss = 64'b11111111_11111111_11111111_11111111_11110000_00000000_00000000_00000000;
      6'd29: dly_bpss = 64'b11111111_11111111_11111111_11111111_11100000_00000000_00000000_00000000;
      6'd30: dly_bpss = 64'b11111111_11111111_11111111_11111111_11000000_00000000_00000000_00000000;
      6'd31: dly_bpss = 64'b11111111_11111111_11111111_11111111_10000000_00000000_00000000_00000000;

      /*
      5'd0:  dly_bpss = 32'b11111111_11111111_11111111_11111111;   // - 0
      5'd1:  dly_bpss = 32'b11111111_11111111_11111111_11111110;   // - 1, 2^1-1
      5'd2:  dly_bpss = 32'b11111111_11111111_11111111_11111100;   // - 3, 2^2-1
      5'd3:  dly_bpss = 32'b11111111_11111111_11111111_11111000;   // - 7, 2^3-1
      5'd4:  dly_bpss = 32'b11111111_11111111_11111111_11110000;   // -15, 2^4-1
      5'd5:  dly_bpss = 32'b11111111_11111111_11111111_11100000;
      5'd6:  dly_bpss = 32'b11111111_11111111_11111111_11000000;
      5'd7:  dly_bpss = 32'b11111111_11111111_11111111_10000000;

      5'd8:  dly_bpss = 32'b11111111_11111111_11111111_00000000;
      5'd9:  dly_bpss = 32'b11111111_11111111_11111110_00000000;
      5'd10: dly_bpss = 32'b11111111_11111111_11111100_00000000;
      5'd11: dly_bpss = 32'b11111111_11111111_11111000_00000000;
      5'd12: dly_bpss = 32'b11111111_11111111_11110000_00000000;
      5'd13: dly_bpss = 32'b11111111_11111111_11100000_00000000;
      5'd14: dly_bpss = 32'b11111111_11111111_11000000_00000000;
      5'd15: dly_bpss = 32'b11111111_11111111_10000000_00000000;

      5'd16: dly_bpss = 32'b11111111_11111111_00000000_00000000;
      5'd17: dly_bpss = 32'b11111111_11111110_00000000_00000000;
      5'd18: dly_bpss = 32'b11111111_11111100_00000000_00000000;
      5'd19: dly_bpss = 32'b11111111_11111000_00000000_00000000;
      5'd20: dly_bpss = 32'b11111111_11110000_00000000_00000000;
      5'd21: dly_bpss = 32'b11111111_11100000_00000000_00000000;
      5'd22: dly_bpss = 32'b11111111_11000000_00000000_00000000;
      5'd23: dly_bpss = 32'b11111111_10000000_00000000_00000000;

      5'd24: dly_bpss = 32'b11111111_00000000_00000000_00000000;
      5'd25: dly_bpss = 32'b11111110_00000000_00000000_00000000;
      5'd26: dly_bpss = 32'b11111100_00000000_00000000_00000000;
      5'd27: dly_bpss = 32'b11111000_00000000_00000000_00000000;
      5'd28: dly_bpss = 32'b11110000_00000000_00000000_00000000;
      5'd29: dly_bpss = 32'b11100000_00000000_00000000_00000000;
      5'd30: dly_bpss = 32'b11000000_00000000_00000000_00000000;
      5'd31: dly_bpss = 32'b10000000_00000000_00000000_00000000;
      */

      6'd32: dly_bpss = 64'b11111111_11111111_11111111_11111111_00000000_00000000_00000000_00000000;
      6'd33: dly_bpss = 64'b11111111_11111111_11111111_11111110_00000000_00000000_00000000_00000000;
      6'd34: dly_bpss = 64'b11111111_11111111_11111111_11111100_00000000_00000000_00000000_00000000;
      6'd35: dly_bpss = 64'b11111111_11111111_11111111_11111000_00000000_00000000_00000000_00000000;
      6'd36: dly_bpss = 64'b11111111_11111111_11111111_11110000_00000000_00000000_00000000_00000000;
      6'd37: dly_bpss = 64'b11111111_11111111_11111111_11100000_00000000_00000000_00000000_00000000;
      6'd38: dly_bpss = 64'b11111111_11111111_11111111_11000000_00000000_00000000_00000000_00000000;
      6'd39: dly_bpss = 64'b11111111_11111111_11111111_10000000_00000000_00000000_00000000_00000000;

      6'd40: dly_bpss = 64'b11111111_11111111_11111111_00000000_00000000_00000000_00000000_00000000;
      6'd41: dly_bpss = 64'b11111111_11111111_11111110_00000000_00000000_00000000_00000000_00000000;
      6'd42: dly_bpss = 64'b11111111_11111111_11111100_00000000_00000000_00000000_00000000_00000000;
      6'd43: dly_bpss = 64'b11111111_11111111_11111000_00000000_00000000_00000000_00000000_00000000;
      6'd44: dly_bpss = 64'b11111111_11111111_11110000_00000000_00000000_00000000_00000000_00000000;
      6'd45: dly_bpss = 64'b11111111_11111111_11100000_00000000_00000000_00000000_00000000_00000000;
      6'd46: dly_bpss = 64'b11111111_11111111_11000000_00000000_00000000_00000000_00000000_00000000;
      6'd47: dly_bpss = 64'b11111111_11111111_10000000_00000000_00000000_00000000_00000000_00000000;

      6'd48: dly_bpss = 64'b11111111_11111111_00000000_00000000_00000000_00000000_00000000_00000000;
      6'd49: dly_bpss = 64'b11111111_11111110_00000000_00000000_00000000_00000000_00000000_00000000;
      6'd50: dly_bpss = 64'b11111111_11111100_00000000_00000000_00000000_00000000_00000000_00000000;
      6'd51: dly_bpss = 64'b11111111_11111000_00000000_00000000_00000000_00000000_00000000_00000000;
      6'd52: dly_bpss = 64'b11111111_11110000_00000000_00000000_00000000_00000000_00000000_00000000;
      6'd53: dly_bpss = 64'b11111111_11100000_00000000_00000000_00000000_00000000_00000000_00000000;
      6'd54: dly_bpss = 64'b11111111_11000000_00000000_00000000_00000000_00000000_00000000_00000000;
      6'd55: dly_bpss = 64'b11111111_10000000_00000000_00000000_00000000_00000000_00000000_00000000;

      6'd56: dly_bpss = 64'b11111111_00000000_00000000_00000000_00000000_00000000_00000000_00000000;
      6'd57: dly_bpss = 64'b11111110_00000000_00000000_00000000_00000000_00000000_00000000_00000000;
      6'd58: dly_bpss = 64'b11111100_00000000_00000000_00000000_00000000_00000000_00000000_00000000;
      6'd59: dly_bpss = 64'b11111000_00000000_00000000_00000000_00000000_00000000_00000000_00000000;
      6'd60: dly_bpss = 64'b11110000_00000000_00000000_00000000_00000000_00000000_00000000_00000000;
      6'd61: dly_bpss = 64'b11100000_00000000_00000000_00000000_00000000_00000000_00000000_00000000;
      6'd62: dly_bpss = 64'b11000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000;
      6'd63: dly_bpss = 64'b10000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000;

      default:  dly_bpss = 64'b11111111_11111111_11111111_11111111_11111111_11111111_11111111_11111111;   // - 0

    endcase

`else

  assign dly_bpss = 64'hFFFF_FFFF_FFFF_FFFF  - (|cur_delay[7:2]? ((2 ^ cur_delay[7:2])-64'd1) : 64'd0);
//assign dly_bpss = 32'hFFFF_FFFF            - (|cur_delay[6:2]? ((2 ^ cur_delay[6:2])-32'd1) : 32'd0);

`endif // OLD_STYLE



  // ------------------------------------------------------------------------------
  // Ring Osciallator Source
  assign  dly_conn[0] = RST_N? ~ring_osco : 1'b0;
  
genvar idx;
generate
for(idx = 0 ; idx < 64 ; idx++ ) begin  // total 63 instance

  DLY_CELL u_dly_cell_inst (
                            .SIG_I      ( dly_conn[idx] ),     // I
                            .BYPASS     ( dly_bpss[idx] ),     // I
                            .SIG_O      ( dly_conn[idx+1] )    // O
                           );

end
endgenerate

  // last stage
  FINE_TUNE u_fine_tune_0 (
                         //.SIG_I      ( dly_conn[63] ),      // I
                           .SIG_I      ( dly_conn[64] ),      // I
                           .SIG_O      ( ring_osco ),         // O
                           .DLY_SEL    ( cur_delay[1:0] )     // I 2
                          );



  // -------------------------------------------------------
  // 5x CLK   _/`\_/`\_/`\_/`\_/`\_/`\_/`\_/`\_/`\_/`\_/`\_/`\_/`\
  //           |   |   |   |   |   |   |   |   |   |   |   |
  //             0   1   2   3   4   0   1   2   3   4   0   1
  //          _/```````\___________/```````\___________/```````\__
  //          _______/```\_______________/```\_______________/```\
  //          _/`````````\_________/`````````\_________/`````````\

  logic [2:0] div_cnt;
  logic       div_clk;

  always @(posedge ring_osco or negedge RST_N)
    if( !RST_N ) begin
      div_cnt <=  3'd0;
      div_clk <=  1'b0;
      end
    else begin
      if( div_cnt == (pFRQCY_DIVIDER - 3'd1) ) begin
        div_cnt <=  3'd0;
        div_clk <=  1'b1;
        end
      else
        div_cnt <=  div_cnt + 3'd1;

      if( div_cnt == 3'd1 )
        div_clk <=  1'b0;
    end


  // negative edge
  logic div_clkn;
  always @(negedge ring_osco or negedge RST_N)
    if( !RST_N )
      div_clkn <=  1'b0;
    else
      div_clkn <=  (div_cnt == 3'd1)? 1'b1 : 1'b0;



//assign clk_fdbk = div_clk;


  assign clk_fdbk = div_clk | div_clkn;

  assign GEN_CLKO = ring_osco;


  // -------------------------------------------------------
  wire ref_clki = ~REF_CLKI;

  wire clkxor = ref_clki ^ clk_fdbk;

  logic [2:0] xor_cnt;
  always @(negedge ring_osco or negedge RST_N)
    if( !RST_N ) begin
      xor_cnt <=  3'd0;
      LOCK    <=  1'b0;
      end
    else begin
      if( clkxor | div_clkn )                                        // ignore the cross point
        xor_cnt <=  (&xor_cnt)? 3'd7: xor_cnt + 3'd1;
      else
        xor_cnt <=  3'd0;

      LOCK <= &xor_cnt;
    end


endmodule // ADPLL_5X

//
// Typical Delay should be around 0.14 ns
//
module DLY_CELL
(
  input wire  SIG_I,
  
  input wire  BYPASS,

  output wire SIG_O
);

  wire sig_1;
  INV    dnt_inv1 (.A(SIG_I), .Y(sig_1));

  wire sig_2;
  INV    dnt_inv2 (.A(sig_1), .Y(sig_2));

//assign SIG_O = BYPASS? SIG_I : sig_2;
  MUX2_1 dnt_mux2_1_0 ( .A( sig_2 ),
                        .B( SIG_I ),
                        .S( BYPASS ),
                        .Y( SIG_O)
                      );


endmodule // DLY_CELL

module FINE_TUNE
(
  input  wire        SIG_I,
  output logic       SIG_O,
  input  wire  [1:0] DLY_SEL
);
 
  wire dly1_o;
  DLY1 u_dly1_0 (.A( SIG_I ), .Y( dly1_o ));

  wire dly3_o;
  DLY3 u_dly3_0 (.A( SIG_I ), .Y( dly3_o ));

  wire dly5_o;
  DLY5 u_dly5_0 (.A( SIG_I ), .Y( dly5_o ));

  wire dly7_o;
  DLY7 u_dly7_0 (.A( SIG_I ), .Y( dly7_o ));

  always_comb
    case( DLY_SEL )
      2'd0:    SIG_O = dly1_o;
      2'd1:    SIG_O = dly3_o;
      2'd2:    SIG_O = dly5_o;
      2'd3:    SIG_O = dly7_o;
      default: SIG_O = dly1_o;
    endcase

endmodule // FINE_TUNE

module LATCH_1T
(
  input   wire SIG_I,
  output  wire SIG_O,

  input   wire CLK,
  input   wire RST_N
);


  // ---------------------------------------------------
  // Latch Up & Down
  logic clr_lth;
  logic clr_lthd;
  logic set_lth;
  wire  clr_set = clr_lthd | ~RST_N;
  always @(posedge SIG_I or posedge clr_set)
    if( clr_set )
      set_lth <=  1'b0;
    else
      set_lth <=  1'b1;


  // ---------------------------------------------------
  // sync.
  // generate 1T pulse
  always @(negedge CLK or negedge RST_N)
    if( !RST_N )
      clr_lth <=  1'b0;
    else
      clr_lth <=  clr_lth? 1'b0 : set_lth;


  assign SIG_O = clr_lth;

  // fix hold time
  wire dly7_o;
  DLY7 u_dly7_0 (.A( clr_lth ), .Y( clr_lthd ));


endmodule // LATCH_1T
`ifndef VERILATOR_LINT_CHK
`endif // LINT_CHK


/* verilator lint_off TIMESCALEMOD */

// Phase and Frequency Detectoor
module PFD
(
  input  wire        CLKI_REF,
  input  wire        CLKI_FBK,

  input  wire        CLKI_OSC,   // 5x Frequency

  output logic [4:0] UP,         // REF is leading, too slow
  output logic [4:0] DN,         // FBK is leading, too fast
  output logic       F1ST_SYNC,

  output logic       TOO_FAST,  
  output logic       TOO_SLOW,  

  input  wire  [4:0] UP_LATCH,   // REF is leading, too slow
  input  wire  [4:0] DN_LATCH,   // FBK is leading, too fast


  input  wire        RST_N
);

  wire ref_clk_d0;
  DLY9 dly_up0 (.A( CLKI_REF   ), .Y( ref_clk_d0 ));
  wire ref_clk_d1;
  DLY9 dly_up1 (.A( ref_clk_d0 ), .Y( ref_clk_d1 ));
  wire ref_clk_d2;
  DLY9 dly_up2 (.A( ref_clk_d1 ), .Y( ref_clk_d2 ));
  wire ref_clk_d3;
  DLY9 dly_up3 (.A( ref_clk_d2 ), .Y( ref_clk_d3 ));
  wire ref_clk_d4;
  DLY9 dly_up4 (.A( ref_clk_d3 ), .Y( ref_clk_d4 ));
  wire ref_clk_d5;
  DLY9 dly_up5 (.A( ref_clk_d4 ), .Y( ref_clk_d5 ));
  wire ref_clk_d6;
  DLY9 dly_up6 (.A( ref_clk_d5 ), .Y( ref_clk_d6 ));
  wire ref_clk_d7;
  DLY9 dly_up7 (.A( ref_clk_d6 ), .Y( ref_clk_d7 ));

//wire clk_ref_f;
  wire clk_ref_f_rst;
//assign  clk_ref_f     = ref_clk_d4 & ~ref_clk_d0;
  assign  clk_ref_f_rst = ref_clk_d7 & ~ref_clk_d3;


  wire fbk_clk_d0;
  DLY9 dly_dn0 (.A( CLKI_FBK   ), .Y( fbk_clk_d0 ));
  wire fbk_clk_d1;
  DLY9 dly_dn1 (.A( fbk_clk_d0 ), .Y( fbk_clk_d1 ));
  wire fbk_clk_d2;
  DLY9 dly_dn2 (.A( fbk_clk_d1 ), .Y( fbk_clk_d2 ));
  wire fbk_clk_d3;
  DLY9 dly_dn3 (.A( fbk_clk_d2 ), .Y( fbk_clk_d3 ));
  wire fbk_clk_d4;
  DLY9 dly_dn4 (.A( fbk_clk_d3 ), .Y( fbk_clk_d4 ));
  wire fbk_clk_d5;
  DLY9 dly_dn5 (.A( fbk_clk_d4 ), .Y( fbk_clk_d5 ));
  wire fbk_clk_d6;
  DLY9 dly_dn6 (.A( fbk_clk_d5 ), .Y( fbk_clk_d6 ));
  wire fbk_clk_d7;
  DLY9 dly_dn7 (.A( fbk_clk_d6 ), .Y( fbk_clk_d7 ));

//wire clk_fbk_f;
  wire clk_fbk_f_rst;
//assign  clk_fbk_f     = fbk_clk_d4 & ~fbk_clk_d0;                //  ____________/``\_______
  assign  clk_fbk_f_rst = fbk_clk_d7 & ~fbk_clk_d3;                //  _____________/``\______

//wire clk_two_f;
//assign  clk_two_f = clk_ref_f | clk_fbk_f;

//wire rst_all;
  wire rst_up;
  wire rst_dn;

`ifdef RTL_SIM

  logic up_ff;
  always_ff @(posedge CLKI_REF or posedge rst_up)
    if( rst_up )
      up_ff <=  1'b0;
    else
      up_ff <=  1'b1;

  logic dn_ff;
  always_ff @(posedge CLKI_FBK or posedge rst_dn)
    if( rst_dn )
      dn_ff <=  1'b0;
    else
      dn_ff <=  1'b1;
`else

  wire up_ff;
  sky130_fd_sc_hd__dfrtp_1 dfrtp_up_ff_reg ( .CLK(CLKI_REF), .D(1'h1), .Q(up_ff), .RESET_B( ~rst_up ));

  wire dn_ff;
  sky130_fd_sc_hd__dfrtp_1 dfrtp_dn_ff_reg ( .CLK(CLKI_FBK), .D(1'h1), .Q(dn_ff), .RESET_B( ~rst_dn ));

`endif // RTL_SIM

//assign  rst_all = RST_N? (up_ff & dn_ff) :  1'b1;
//assign  rst_up  = RST_N? dn_ff :  1'b1;
//assign  rst_dn  = RST_N? up_ff :  1'b1;
//assign  rst_up  = RST_N? (up_ff & dn_ff) :  1'b1;
//assign  rst_dn  = RST_N? (up_ff & dn_ff) :  1'b1;
//assign  rst_up  = RST_N? (up_ff & dn_ff & ~CLKI_FBK) :  1'b1;
//assign  rst_dn  = RST_N? (up_ff & dn_ff & ~CLKI_REF) :  1'b1;
//wire rst_up_algn;
//wire rst_dn_algn;
//assign  rst_up  = RST_N? (rst_up_algn | (up_ff & dn_ff)) :  1'b1;
//assign  rst_dn  = RST_N? (rst_dn_algn | (up_ff & dn_ff)) :  1'b1;
  assign  rst_up  = RST_N? (clk_ref_f_rst | (up_ff & dn_ff)) :  1'b1;
  assign  rst_dn  = RST_N? (clk_fbk_f_rst | (up_ff & dn_ff)) :  1'b1;

//logic up_dt_vld;  // prior cycle is almost aligned, fbk is leading
//logic dn_dt_vld;  // prior cycle is almost aligned, ref is leading
  logic dlt_vld_cyc;
  wire  up_src;
  // width propotional to delta timing
//assign  up_src = up_ff & ~dn_ff & up_dt_vld;
//assign  up_src = up_ff & ~dn_ff & dlt_vld_cyc;
  assign  up_src = up_ff & ~dn_ff;

  // width propotional to delta timing
  wire  dn_src;
//assign  dn_src = dn_ff & ~up_ff & dn_dt_vld;
//assign  dn_src = dn_ff & ~up_ff & dlt_vld_cyc;
  assign  dn_src = dn_ff & ~up_ff;


  // ------------------------------------------------------
  // UP
  always_ff @(posedge ref_clk_d0 or posedge clk_fbk_f_rst)
    if( clk_fbk_f_rst )
      UP[0] <=  1'b0;
    else
      UP[0] <=  up_src;

  always_ff @(posedge ref_clk_d1 or posedge clk_fbk_f_rst)
    if( clk_fbk_f_rst )
      UP[1] <=  1'b0;
    else
      UP[1] <=  up_src;

  always_ff @(posedge ref_clk_d2 or posedge clk_fbk_f_rst)
    if( clk_fbk_f_rst )
      UP[2] <=  1'b0;
    else
      UP[2] <=  up_src;

  always_ff @(posedge ref_clk_d4 or posedge clk_fbk_f_rst)
    if( clk_fbk_f_rst )
      UP[3] <=  1'b0;
    else
      UP[3] <=  up_src;

  always_ff @(posedge ref_clk_d7 or posedge clk_fbk_f_rst)
    if( clk_fbk_f_rst )
      UP[4] <=  1'b0;
    else
      UP[4] <=  up_src;
  
  // DOWN
  always_ff @(posedge fbk_clk_d0 or posedge clk_ref_f_rst)
    if( clk_ref_f_rst )
      DN[0] <=  1'b0;
    else
      DN[0] <=  dn_src;

  always_ff @(posedge fbk_clk_d1 or posedge clk_ref_f_rst )
    if( clk_ref_f_rst )
      DN[1] <=  1'b0;
    else
      DN[1] <=  dn_src;

  always_ff @(posedge fbk_clk_d2 or posedge clk_ref_f_rst )
    if( clk_ref_f_rst )
      DN[2] <=  1'b0;
    else
      DN[2] <=  dn_src;

  always_ff @(posedge fbk_clk_d4 or posedge clk_ref_f_rst )
    if( clk_ref_f_rst )
      DN[3] <=  1'b0;
    else
      DN[3] <=  dn_src;

  always_ff @(posedge fbk_clk_d7 or posedge clk_ref_f_rst )
    if( clk_ref_f_rst )
      DN[4] <=  1'b0;
    else
      DN[4] <=  dn_src;


  //------------------------------------------------------------------------------
  //------------------------------------------------------------------------------
  // use REF to monitor FBK
  logic ref_smp0;
  always_ff @(posedge ref_clk_d0 or posedge clk_ref_f_rst)
    if( clk_ref_f_rst )
      ref_smp0 <=  1'b0;
    else
      ref_smp0 <=  fbk_clk_d1;

  logic ref_smp1;
  always_ff @(posedge ref_clk_d2 or posedge clk_ref_f_rst)
    if( clk_ref_f_rst )
      ref_smp1 <=  1'b0;
    else
      ref_smp1 <=  fbk_clk_d1;

  wire  ref_aligned = ~ref_smp0 & ref_smp1;         // rising of CLKI_FBK is in between two CLKI_REF, REF is leading FBK

  /*
  // 1/2 T
  logic ref_lead_algn;
  always_ff @(posedge ref_aligned or posedge clk_fbk_f_rst)
    if( clk_fbk_f_rst )
      ref_lead_algn <=  1'b0;
    else
      ref_lead_algn <=  1'b1;
 
  logic ref_lead_algn_sync;
  always_ff @(negedge fbk_clk_d0 or negedge RST_N)
    if( !RST_N )
      ref_lead_algn_sync <=  1'b0;
    else
      ref_lead_algn_sync <=  ref_lead_algn;
  */

  //------------------------------------------------------------------
  // use FBK to monitor REF
  logic fbk_smp0;
  always_ff @(posedge fbk_clk_d0 or posedge clk_fbk_f_rst)
    if( clk_fbk_f_rst )
      fbk_smp0 <=  1'b0;
    else
    //fbk_smp0 <=  CLKI_REF;
      fbk_smp0 <=  ref_clk_d1;

  logic fbk_smp1;
  always_ff @(posedge fbk_clk_d2 or posedge clk_fbk_f_rst)
    if( clk_fbk_f_rst )
      fbk_smp1 <=  1'b0;
    else
      fbk_smp1 <=  ref_clk_d1;

  wire  fbk_aligned = ~fbk_smp0 & fbk_smp1;         // rising of CLKI_REF is in between two CLKI_FBK, FBK is leading REF

  /*
  // 1/2 T
  logic fbk_lead_algn;
  always_ff @(posedge fbk_aligned or posedge clk_ref_f_rst)
    if( clk_ref_f_rst )
      fbk_lead_algn <=  1'b0;
    else
      fbk_lead_algn <=  1'b1;

  logic fbk_lead_algn_sync;
  always_ff @(negedge ref_clk_d0 or negedge RST_N)
    if( !RST_N )
      fbk_lead_algn_sync <=  1'b0;
    else
      fbk_lead_algn_sync <=  fbk_lead_algn;
  */

  
  wire  clk_aligned = ref_aligned & fbk_aligned;
  wire       clk_alignel;

  LATCH_1T u_lth_clk_algn ( .SIG_I( clk_aligned ), .SIG_O( clk_alignel ), .CLK( CLKI_REF ), .RST_N( RST_N ) );


  // delta glitch
//wire  clk_aligned = ref_lead_algn_sync & fbk_lead_algn_sync;
  logic clk_aligned_sync;
  always_ff @(negedge CLKI_REF or negedge RST_N)
    if( !RST_N)
      clk_aligned_sync <= 1'b0;
    else
    //clk_aligned_sync <=  ref_aligned & fbk_aligned;
      clk_aligned_sync <=  clk_alignel;




  /*
  // delta
  logic up_dt_vld0;
  logic up_dt_vld1;
  logic up_dt_vld2;
  logic up_dt_vld3;
  logic up_dt_vld4;
  logic up_dt_vld5;
  always_ff @(negedge CLKI_REF or negedge RST_N)
    if( !RST_N) begin
      up_dt_vld0 <=  1'b0;
      up_dt_vld1 <=  1'b0;
      up_dt_vld2 <=  1'b0;
      up_dt_vld3 <=  1'b0;
      up_dt_vld4 <=  1'b0;
      up_dt_vld5 <=  1'b0;
      end
    else begin
    //up_dt_vld <=  clk_aligned;
    //up_dt_vld0 <=  up_dt_vld0? 1'b0 : fbk_lead_algn;
      up_dt_vld0 <=  up_dt_vld0? 1'b0 : clk_aligned;
    //up_dt_vld <=  ref_lead_algn;
      up_dt_vld1 <=  up_dt_vld0;
      up_dt_vld2 <=  up_dt_vld1;
      up_dt_vld3 <=  up_dt_vld2;
      up_dt_vld4 <=  up_dt_vld3;
      up_dt_vld5 <=  up_dt_vld4;
    end
    
//assign  up_dt_vld =  up_dt_vld1 | up_dt_vld2;  
//assign  up_dt_vld =  up_dt_vld0 | up_dt_vld4;  
//assign  up_dt_vld =  up_dt_vld1 ;  
  assign  up_dt_vld =  up_dt_vld0 | up_dt_vld4;  
//assign  up_dt_vld =  up_dt_vld0 ;  

  // delta
  logic dn_dt_vld0;
  logic dn_dt_vld1;
  logic dn_dt_vld2;
  logic dn_dt_vld3;
  logic dn_dt_vld4;
  logic dn_dt_vld5;
  always_ff @(negedge CLKI_FBK or negedge RST_N)
    if( !RST_N) begin
      dn_dt_vld0 <=  1'b0;
      dn_dt_vld1 <=  1'b0;
      dn_dt_vld2 <=  1'b0;
      dn_dt_vld3 <=  1'b0;
      dn_dt_vld4 <=  1'b0;
      dn_dt_vld5 <=  1'b0;
      end
    else begin
    //dn_dt_vld <=  clk_aligned;
    //dn_dt_vld0 <=  dn_dt_vld0? 1'b0 : ref_lead_algn;
      dn_dt_vld0 <=  dn_dt_vld0? 1'b0 : clk_aligned;
    //dn_dt_vld <=  fbk_lead_algn;
      dn_dt_vld1 <=  dn_dt_vld0;
      dn_dt_vld2 <=  dn_dt_vld1;
      dn_dt_vld3 <=  dn_dt_vld2;
      dn_dt_vld4 <=  dn_dt_vld3;
      dn_dt_vld5 <=  dn_dt_vld4;
    end

//assign  dn_dt_vld =  dn_dt_vld1 | dn_dt_vld2;  
//assign  dn_dt_vld =  dn_dt_vld0 | dn_dt_vld4;  
//assign  dn_dt_vld =  dn_dt_vld1 ;  
//assign  dn_dt_vld =  dn_dt_vld0 | dn_dt_vld4;  
  assign  dn_dt_vld =  dn_dt_vld2 ;  
*/

  /*
  logic clk_algn_sync;
  always_ff @(posedge CLKI_REF or negedge RST_N)
    if( !RST_N )
      clk_algn_sync <= 1'b0;
    else
      clk_algn_sync <= clk_aligned;

  // delta_valid_cyc
  logic dlt_vld_cyc0;
  logic dlt_vld_cyc1;
  logic dlt_vld_cyc2;
  logic dlt_vld_cyc3;
  logic dlt_vld_cyc4;
  logic dlt_vld_cyc5;
  logic dlt_vld_cyc6;
  logic dlt_vld_cyc7;
//always_ff @(negedge CLKI_FBK or negedge RST_N)
  always_ff @(negedge CLKI_REF or negedge RST_N)
    if( !RST_N) begin
      dlt_vld_cyc0 <=  1'b0;
      dlt_vld_cyc1 <=  1'b0;
      dlt_vld_cyc2 <=  1'b0;
      dlt_vld_cyc3 <=  1'b0;
      dlt_vld_cyc4 <=  1'b0;
      dlt_vld_cyc5 <=  1'b0;
      dlt_vld_cyc6 <=  1'b0;
      dlt_vld_cyc7 <=  1'b0;
      end
    else begin
    //dlt_vld_cyc0 <=  dlt_vld_cyc0? 1'b0 : clk_aligned;   // no up | down, don't care
      dlt_vld_cyc0 <=  dlt_vld_cyc0? 1'b0 : clk_algn_sync;   // no up | down, don't care
      dlt_vld_cyc1 <=  dlt_vld_cyc0 ;
      dlt_vld_cyc2 <=  dlt_vld_cyc1 ;
      dlt_vld_cyc3 <=  dlt_vld_cyc2 ;
      dlt_vld_cyc4 <=  dlt_vld_cyc3 ;
      dlt_vld_cyc5 <=  dlt_vld_cyc4 ;
      dlt_vld_cyc6 <=  dlt_vld_cyc5 ;
      dlt_vld_cyc7 <=  dlt_vld_cyc6 ;
    end

//logic clk_align_1t;
//always_ff @(negedge CLKI_REF or negedge RST_N)
//  if( !RST_N )
//    clk_align_1t <= 1'b0;
//  else
//    clk_align_1t <= clk_aligned;


//assign  dlt_vld_cyc =  dlt_vld_cyc1 | dlt_vld_cyc2;  
//assign  dlt_vld_cyc =  dlt_vld_cyc0 | dlt_vld_cyc4;  
//assign  dlt_vld_cyc =  dlt_vld_cyc1 ;  
//assign  dlt_vld_cyc =  dlt_vld_cyc0 | dlt_vld_cyc4;  
//assign  dlt_vld_cyc =  (dlt_vld_cyc0 | dlt_vld_cyc6) & ~clk_align_1t;
  assign  dlt_vld_cyc =  dlt_vld_cyc0 | ((dlt_vld_cyc3 | dlt_vld_cyc6) & ~clk_algn_sync);
//assign  dlt_vld_cyc =  clk_aligned | (dlt_vld_cyc6 & ~clk_algn_sync);
  */

//assign  F1ST_SYNC   =  clk_aligned_sync;
  assign  F1ST_SYNC   =  clk_alignel;



//assign rst_up_algn = clk_aligned & ~up_dt_vld;
//assign rst_dn_algn = clk_aligned & ~dn_dt_vld;

  //---------------------------------------------
  // LOCK
  logic [2:0] hi_cnt;
  always_ff @(posedge CLKI_OSC or negedge RST_N)
    if( !RST_N ) begin
      hi_cnt   <=  3'd0;
      TOO_FAST <=  1'b0;
      end
    else
      if( CLKI_REF )
        hi_cnt   <=  (&hi_cnt)? 3'd7 : (hi_cnt + 3'd1);
      else begin
        TOO_FAST <=  (hi_cnt > 3'd3)? 1'b1 : 1'b0;        // count 4 times
        hi_cnt   <=  3'd0;
      end

  logic [2:0] lo_cnt;
  always_ff @(posedge CLKI_OSC or negedge RST_N)
    if( !RST_N ) begin
      lo_cnt   <= 3'd0;
      TOO_SLOW <= 1'b0;
      end
    else
      if( CLKI_REF ) begin
        lo_cnt   <=  3'd0;
      // 20ns low window clocked by 8ns osc clock
        TOO_SLOW <=  ((lo_cnt ==3'd1)      )? 1'b1 : 1'b0;    // count at least two time
        end
      else
        lo_cnt   <=  (&lo_cnt)? 3'd7 : (lo_cnt + 3'd1);
  
  /*
  //---------------------------------------------
  always_ff @(posedge CLKI_OSC or negedge RST_N)
    if( !RST_N)
      TOO_FAST <= 1'b0;
    else
      TOO_FAST <= (hi_cnt > 3'd3)? 1'b1 : 1'b0;
 
  always_ff @(posedge CLKI_OSC or negedge RST_N)
    if( !RST_N)
      TOO_SLOW <= 1'b0;
    else
      TOO_SLOW <= (lo_cnt < 3'd3)? 1'b1 : 1'b0;
  */


  
endmodule // PFD

/* verilator lint_on TIMESCALEMOD */

module UP_DN_CTRL
(
  input  wire  [4:0] UP,          // slow, dec delay
  input  wire  [4:0] DN,          // fast, inc delay
  input  wire        F1ST_SYNC,

  input  logic       TOO_FAST,    // Ring OSC clock domain
  input  logic       TOO_SLOW,

  output logic [4:0] UP_LATCH,
  output logic [4:0] DN_LATCH,

  input  wire        LOAD_BASE,
  input  wire  [7:0] BASE_DLYS,
  output logic [7:0] CUR_DELAY,

  input  wire        REF_CLK,
  input  wire        RST_N
);

  /*
  // ------------------------------------------------------------------------------------------------
  wire [4:0] up_lth;
  LATCH_1T u_lth_up0 ( .SIG_I( UP[0] ), .SIG_O( up_lth[0] ), .CLK( REF_CLK ), .RST_N( RST_N ) );
  LATCH_1T u_lth_up1 ( .SIG_I( UP[1] ), .SIG_O( up_lth[1] ), .CLK( REF_CLK ), .RST_N( RST_N ) );
  LATCH_1T u_lth_up2 ( .SIG_I( UP[2] ), .SIG_O( up_lth[2] ), .CLK( REF_CLK ), .RST_N( RST_N ) );
  LATCH_1T u_lth_up3 ( .SIG_I( UP[3] ), .SIG_O( up_lth[3] ), .CLK( REF_CLK ), .RST_N( RST_N ) );
  LATCH_1T u_lth_up4 ( .SIG_I( UP[4] ), .SIG_O( up_lth[4] ), .CLK( REF_CLK ), .RST_N( RST_N ) );

  wire [4:0] dn_lth;
  LATCH_1T u_lth_dn0 ( .SIG_I( DN[0] ), .SIG_O( dn_lth[0] ), .CLK( REF_CLK ), .RST_N( RST_N ) );
  LATCH_1T u_lth_dn1 ( .SIG_I( DN[1] ), .SIG_O( dn_lth[1] ), .CLK( REF_CLK ), .RST_N( RST_N ) );
  LATCH_1T u_lth_dn2 ( .SIG_I( DN[2] ), .SIG_O( dn_lth[2] ), .CLK( REF_CLK ), .RST_N( RST_N ) );
  LATCH_1T u_lth_dn3 ( .SIG_I( DN[3] ), .SIG_O( dn_lth[3] ), .CLK( REF_CLK ), .RST_N( RST_N ) );
  LATCH_1T u_lth_dn4 ( .SIG_I( DN[4] ), .SIG_O( dn_lth[4] ), .CLK( REF_CLK ), .RST_N( RST_N ) );
  */


  // ------------------------------------------------------------------------------------------------
  // de-assert after negedge of CLK
  wire too_fast;
  wire too_slow;
  LATCH_1T u_lth_tfs ( .SIG_I( TOO_FAST ), .SIG_O( too_fast ), .CLK( REF_CLK ), .RST_N( RST_N ) );
  LATCH_1T u_lth_tsl ( .SIG_I( TOO_SLOW ), .SIG_O( too_slow ), .CLK( REF_CLK ), .RST_N( RST_N ) );


  logic f1st_adj_cyc;
  // ---------------------------------------------------
//always @(posedge REF_CLK or negedge RST_N)
//  if( !RST_N )
//    f1st_adj_sync <= 1'b0;
//  else 
//    f1st_adj_sync <= F1ST_ADJ;

  // delta_valid_cyc
  logic f1st_sync_cyc0;
  logic f1st_sync_cyc1;
  logic f1st_sync_cyc2;
  logic f1st_sync_cyc3;
  logic f1st_sync_cyc4;
  logic f1st_sync_cyc5;
  logic f1st_sync_cyc6;
  logic f1st_sync_cyc7;
  logic f1st_sync_cyc8;
//always_ff @(negedge CLKI_FBK or negedge RST_N)
  always_ff @(negedge REF_CLK or negedge RST_N)
    if( !RST_N) begin
      f1st_sync_cyc0 <=  1'b0;
      f1st_sync_cyc1 <=  1'b0;
      f1st_sync_cyc2 <=  1'b0;
      f1st_sync_cyc3 <=  1'b0;
      f1st_sync_cyc4 <=  1'b0;
      f1st_sync_cyc5 <=  1'b0;
      f1st_sync_cyc6 <=  1'b0;
      f1st_sync_cyc7 <=  1'b0;
      f1st_sync_cyc8 <=  1'b0;
      end
    else begin
      f1st_sync_cyc0 <=  f1st_sync_cyc0? 1'b0 : F1ST_SYNC;      // no up | down, don't care
      f1st_sync_cyc1 <=  f1st_sync_cyc0 ;
      f1st_sync_cyc2 <=  f1st_sync_cyc1 ;
      f1st_sync_cyc3 <=  f1st_sync_cyc2 ;
      f1st_sync_cyc4 <=  f1st_sync_cyc3 ;
      f1st_sync_cyc5 <=  f1st_sync_cyc4 ;
      f1st_sync_cyc6 <=  f1st_sync_cyc5 ;
      f1st_sync_cyc7 <=  f1st_sync_cyc6 ;
      f1st_sync_cyc8 <=  f1st_sync_cyc7 ;
    end

  assign f1st_adj_cyc = f1st_sync_cyc0;


//wire [4:0] up_vld = UP & (f1st_adj_cyc | f1st_sync_cyc4 | f1st_sync_cyc7);
//wire [4:0] dn_vld = DN & (f1st_adj_cyc | f1st_sync_cyc4 | f1st_sync_cyc7);

  // ---------------------------------------------------
  // Find turning point
  logic up_delta;
  always @(negedge REF_CLK or negedge RST_N)
    if( !RST_N )
      up_delta <= 1'b0;
    else
      up_delta <= |UP;

  logic dn_delta;
  always @(negedge REF_CLK or negedge RST_N)
    if( !RST_N )
      dn_delta <= 1'b0;
    else
      dn_delta <= |DN;

  logic turn_pnt;
  always @(negedge REF_CLK or negedge RST_N)
    if( !RST_N )
      turn_pnt <= 1'b0;
    else 
      turn_pnt <= (up_delta & |DN) | (dn_delta & |UP);


  // ---------------------------------------------------
  wire   actv_chk_cyc = f1st_adj_cyc |
                        ((f1st_sync_cyc2 | f1st_sync_cyc4) & ~F1ST_SYNC) |
                        (turn_pnt & (f1st_sync_cyc5 | f1st_sync_cyc6 | f1st_sync_cyc7 | f1st_sync_cyc8) & ~F1ST_SYNC);



  // ---------------------------------------------------
  always @(negedge REF_CLK or negedge RST_N)
    if( !RST_N )
      CUR_DELAY <=  8'b1000_0000;
    else
      if( LOAD_BASE )
        CUR_DELAY <=  BASE_DLYS;
      else
        case( {too_fast, too_slow} )
          2'b01:                      CUR_DELAY <=  (CUR_DELAY>=8'd20)? (CUR_DELAY - 8'd20) : 8'h00;
          2'b10:                      CUR_DELAY <=  (CUR_DELAY>=8'h6B)? 8'h7F : (CUR_DELAY + 8'd20);
          2'b00: if( actv_chk_cyc )
                   casex( {UP, DN} )
                     10'b00000_00001: CUR_DELAY <=  (&CUR_DELAY      )? 8'h7F : (CUR_DELAY + (f1st_adj_cyc? 8'd3  : 8'd1));
                     10'b00000_0001x: CUR_DELAY <=  (CUR_DELAY>=8'h7D)? 8'h7F : (CUR_DELAY + (f1st_adj_cyc? 8'd4  : 8'd2));
                     10'b00000_001xx: CUR_DELAY <=  (CUR_DELAY>=8'h7C)? 8'h7F : (CUR_DELAY + (f1st_adj_cyc? 8'd6  : 8'd3));
                     10'b00000_01xxx: CUR_DELAY <=  (CUR_DELAY>=8'h75)? 8'h7F : (CUR_DELAY + (f1st_adj_cyc? 8'd10 : 8'd5));
                     10'b00000_1xxxx: CUR_DELAY <=  (CUR_DELAY>=8'h6B)? 8'h7F : (CUR_DELAY + (f1st_adj_cyc? 8'd20 : 8'd9));
            
                     10'b00001_00000: CUR_DELAY <=  (CUR_DELAY>=8'd01)? (CUR_DELAY - (f1st_adj_cyc? 8'd3  : 8'd1)) : 8'h00;
                     10'b0001x_00000: CUR_DELAY <=  (CUR_DELAY>=8'd02)? (CUR_DELAY - (f1st_adj_cyc? 8'd4  : 8'd2)) : 8'h00;
                     10'b001xx_00000: CUR_DELAY <=  (CUR_DELAY>=8'd03)? (CUR_DELAY - (f1st_adj_cyc? 8'd6  : 8'd3)) : 8'h00;
                     10'b01xxx_00000: CUR_DELAY <=  (CUR_DELAY>=8'd05)? (CUR_DELAY - (f1st_adj_cyc? 8'd10 : 8'd5)) : 8'h00;
                     10'b1xxxx_00000: CUR_DELAY <=  (CUR_DELAY>=8'd09)? (CUR_DELAY - (f1st_adj_cyc? 8'd20 : 8'd9)) : 8'h00;
            
                     10'b00001_0001x: CUR_DELAY <=  (CUR_DELAY>=8'h7D)? 8'h7F : (CUR_DELAY + (f1st_adj_cyc? 8'd4  : 8'd2));
                     10'b000xx_001xx: CUR_DELAY <=  (CUR_DELAY>=8'h7C)? 8'h7F : (CUR_DELAY + (f1st_adj_cyc? 8'd6  : 8'd3));
                     10'b00xxx_01xxx: CUR_DELAY <=  (CUR_DELAY>=8'h75)? 8'h7F : (CUR_DELAY + (f1st_adj_cyc? 8'd10 : 8'd5));
                     10'b0xxxx_1xxxx: CUR_DELAY <=  (CUR_DELAY>=8'h6B)? 8'h7F : (CUR_DELAY + (f1st_adj_cyc? 8'd20 : 8'd9));
            
                     10'b0001x_00001: CUR_DELAY <=  (CUR_DELAY>=8'd02)? (CUR_DELAY - (f1st_adj_cyc? 8'd4  : 8'd2)) : 8'h00;
                     10'b001xx_0001x: CUR_DELAY <=  (CUR_DELAY>=8'd03)? (CUR_DELAY - (f1st_adj_cyc? 8'd6  : 8'd3)) : 8'h00;
                     10'b01xxx_001xx: CUR_DELAY <=  (CUR_DELAY>=8'd05)? (CUR_DELAY - (f1st_adj_cyc? 8'd10 : 8'd5)) : 8'h00;
                     10'b01xxx_001xx: CUR_DELAY <=  (CUR_DELAY>=8'd09)? (CUR_DELAY - (f1st_adj_cyc? 8'd20 : 8'd9)) : 8'h00;
            
                     default:         CUR_DELAY <=  CUR_DELAY;           // no change
                   endcase
            

          default:                    CUR_DELAY <=  CUR_DELAY;           // no change
        endcase
  
  /*
  always @(posedge REF_CLK or negedge RST_N)
    if( !RST_N )
      CUR_DELAY <=  7'b100_0000;
    else
      if( LOAD_BASE )
        CUR_DELAY <=  BASE_DLYS;
      else
        case( {too_fast, too_slow} )
          2'b01:                    CUR_DELAY <=  (CUR_DELAY>=7'd20)? (CUR_DELAY - 7'd20) : 7'h00;
          2'b10:                    CUR_DELAY <=  (CUR_DELAY>=7'h76)? 7'h7F : (CUR_DELAY + 7'd20);
          2'b00: casex( {up_lth, dn_lth} )
                   10'b00000_00001: CUR_DELAY <=  (&CUR_DELAY      )? 7'h7F : (CUR_DELAY + (f1st_adj_sync? 7'd3  : 7'd1));
                   10'b00000_0001x: CUR_DELAY <=  (CUR_DELAY>=7'h7D)? 7'h7F : (CUR_DELAY + (f1st_adj_sync? 7'd4  : 7'd2));
                   10'b00000_001xx: CUR_DELAY <=  (CUR_DELAY>=7'h7C)? 7'h7F : (CUR_DELAY + (f1st_adj_sync? 7'd6  : 7'd3));
                   10'b00000_01xxx: CUR_DELAY <=  (CUR_DELAY>=7'h75)? 7'h7F : (CUR_DELAY + (f1st_adj_sync? 7'd10 : 7'd5));
                   10'b00000_1xxxx: CUR_DELAY <=  (CUR_DELAY>=7'h6B)? 7'h7F : (CUR_DELAY + (f1st_adj_sync? 7'd20 : 7'd9));
          
                   10'b00001_00000: CUR_DELAY <=  (CUR_DELAY>=7'd01)? (CUR_DELAY - (f1st_adj_sync? 7'd3  : 7'd1)) : 7'h00;
                   10'b0001x_00000: CUR_DELAY <=  (CUR_DELAY>=7'd02)? (CUR_DELAY - (f1st_adj_sync? 7'd4  : 7'd2)) : 7'h00;
                   10'b001xx_00000: CUR_DELAY <=  (CUR_DELAY>=7'd03)? (CUR_DELAY - (f1st_adj_sync? 7'd6  : 7'd3)) : 7'h00;
                   10'b01xxx_00000: CUR_DELAY <=  (CUR_DELAY>=7'd05)? (CUR_DELAY - (f1st_adj_sync? 7'd10 : 7'd5)) : 7'h00;
                   10'b1xxxx_00000: CUR_DELAY <=  (CUR_DELAY>=7'd09)? (CUR_DELAY - (f1st_adj_sync? 7'd20 : 7'd9)) : 7'h00;
          
                   10'b0000x_0001x: CUR_DELAY <=  (CUR_DELAY>=7'h7D)? 7'h7F : (CUR_DELAY + (f1st_adj_sync? 7'd4  : 7'd2));
                   10'b000xx_001xx: CUR_DELAY <=  (CUR_DELAY>=7'h7C)? 7'h7F : (CUR_DELAY + (f1st_adj_sync? 7'd6  : 7'd3));
                   10'b00xxx_01xxx: CUR_DELAY <=  (CUR_DELAY>=7'h75)? 7'h7F : (CUR_DELAY + (f1st_adj_sync? 7'd10 : 7'd5));
                   10'b0xxxx_1xxxx: CUR_DELAY <=  (CUR_DELAY>=7'h6B)? 7'h7F : (CUR_DELAY + (f1st_adj_sync? 7'd20 : 7'd9));
          
                   10'b0001x_00001: CUR_DELAY <=  (CUR_DELAY>=7'd02)? (CUR_DELAY - (f1st_adj_sync? 7'd4  : 7'd2)) : 7'h00;
                   10'b001xx_0001x: CUR_DELAY <=  (CUR_DELAY>=7'd03)? (CUR_DELAY - (f1st_adj_sync? 7'd6  : 7'd3)) : 7'h00;
                   10'b01xxx_001xx: CUR_DELAY <=  (CUR_DELAY>=7'd05)? (CUR_DELAY - (f1st_adj_sync? 7'd10 : 7'd5)) : 7'h00;
                   10'b01xxx_001xx: CUR_DELAY <=  (CUR_DELAY>=7'd09)? (CUR_DELAY - (f1st_adj_sync? 7'd20 : 7'd9)) : 7'h00;
          
                   default:         CUR_DELAY <=  CUR_DELAY;           // no change
                endcase

          default:                  CUR_DELAY <=  CUR_DELAY;           // no change
        endcase
  */    


  // ---------------------------------------------------
  always @(negedge REF_CLK or negedge RST_N)
    if( !RST_N )
      UP_LATCH <= 5'd0;
    else
      UP_LATCH <= UP;


  always @(negedge REF_CLK or negedge RST_N)
    if( !RST_N )
      DN_LATCH <= 5'd0;
    else
      DN_LATCH <= DN;


endmodule // UP_DN_CTRL
