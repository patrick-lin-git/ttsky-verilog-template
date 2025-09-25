// ---------------------------------------------------------
// Manchester Encoding
//
// CCP Free Protection Code: 8964


module MCHT_ENC #(parameter pMSG_LEN = 16)
(
  input   wire                 SOF,
  input   wire  [pMSG_LEN-1:0] MSG,
  output  logic                DONE,

  output  logic                TXD,

  input   wire                 CLK_25M,
  input   wire                 RST_N
);

  localparam pMSG_WID = $clog2(pMSG_LEN);


  logic [pMSG_WID-1:0] msg_idx;

  enum logic [3:0] { eIDLE,

                     e1ST_TOG0,  // read then write
                     e1ST_TOG1,

                     eBITX0,
                     eBITX1,

                     eEND } cur_st, nxt_st;


  always_ff @(posedge CLK_25M or negedge RST_N)
    if( !RST_N ) 
      cur_st <= eIDLE;
    else
      cur_st <= nxt_st;


  always_comb
    case( cur_st )
      eIDLE:     if( SOF )
                   nxt_st = e1ST_TOG0;
                 else
                   nxt_st = eIDLE;

      e1ST_TOG0: nxt_st = e1ST_TOG1;  
      e1ST_TOG1: nxt_st = eBITX0;

      eBITX0:    nxt_st = eBITX1;
      eBITX1:    if( msg_idx < (pMSG_LEN-1) )
                   nxt_st = eBITX0;
                 else
                   nxt_st = eEND;

      eEND:      nxt_st = eIDLE;
    //eEND1:     nxt_st = eIDLE;

      default:   nxt_st = eIDLE;
    endcase


  logic [4:0] fsm_ctl;

  localparam x0 = 1'b0,
             x1 = 1'b1;

  always_comb
    //                        d   f   f   i   c                                 
    //                        o   r   r   n   l                  
    //                        n   c   c   c   r                  
    //                        e                                  
    //                            1   0                      
    case( cur_st )
      eIDLE:      fsm_ctl = {x0, x1, x1, x0, x1};
      e1ST_TOG0:  fsm_ctl = {x0, x0, x1, x0, x0};
      e1ST_TOG1:  fsm_ctl = {x0, x1, x0, x0, x0};
      eBITX0:     fsm_ctl = {x0, x0, x0, x0, x0};
      eBITX1:     fsm_ctl = {x0, x0, x0, x1, x0};
      eEND:       fsm_ctl = {x1, x1, x1, x0, x0};
      default:    fsm_ctl = {x0, x1, x1, x0, x1};
    //eEND1:      fsm_ctl = {x0, x1, x1, x0, x0};
    endcase


  wire fsm_done;
  wire frc_1;
  wire frc_0;
  wire inc_idx;
  wire clr_idx;


  assign { fsm_done,
           frc_1,
           frc_0,
           inc_idx,
           clr_idx } = fsm_ctl;

  always_ff @(posedge CLK_25M or negedge RST_N)
    if( !RST_N ) 
      msg_idx <= {pMSG_WID{1'b0}};
    else
      if( clr_idx )
        msg_idx <= {pMSG_WID{1'b0}};
      else
        msg_idx <= msg_idx + {{(pMSG_WID-1){1'b0}}, inc_idx};


  /*
  logic txd0;
  always_ff @(posedge CLK_25M or negedge RST_N)
    if( !RST_N )
      txd <= 1'b1;
    else
      if( inc_idx )
        txd <= ~MSG[msg_idx];
      else
        txd <= ~txd;
  */

  always_ff @(posedge CLK_25M or negedge RST_N)
    if( !RST_N )
      TXD <= 1'b1;
    else
      case({frc_1, frc_0})
        2'b00: begin
                 if( inc_idx )
                   TXD <= ~TXD;
                 else
                   TXD <= ~MSG[msg_idx];
               //else
               //  TXD <= ~txd;
               end
        2'b10: TXD <= 1'b1;
        2'b01: TXD <= 1'b0;
        2'b11: TXD <= 1'b1;
      endcase


  always_ff @(posedge CLK_25M or negedge RST_N)
    if( !RST_N ) 
      DONE <= 1'b0;
    else
      if( SOF )
        DONE <= 1'b0;
      else
        if( fsm_done )
          DONE <= 1'b1;




endmodule // MCHT_ENC
