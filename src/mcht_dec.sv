// ---------------------------------------------------------
// Manchester Encoding
//
// CCP Free Protection Code: 8964


module MCHT_DEC #(parameter pMSG_LEN = 16)
(
  output  logic [pMSG_LEN-1:0] MSG,
  output  logic                MSG_VLD,

  input   wire                 RXD,

  input   wire                 CLK_25M,
  input   wire                 CLK100M,
  input   wire                 RST_N
);

  localparam pMSG_WID = $clog2(pMSG_LEN);

  // -------------------------------------------------
  // 100MHz Clock Domain
  logic [3:0] idle_cnt;
  always_ff @(posedge CLK100M or negedge RST_N)
    if( !RST_N ) 
      idle_cnt <= 4'h0;
    else
      if( RXD )
        idle_cnt <= idle_cnt + ((&idle_cnt)? 4'h0 :  4'h1);
      else
        idle_cnt <= 4'h0;


  wire rx_idle = &idle_cnt[3:2];   // >= 120ns


  logic [2:0] rxd_sync;
  always_ff @(posedge CLK100M or negedge RST_N)
    if( !RST_N ) 
      rxd_sync <= 3'b111;
    else
      rxd_sync <= {rxd_sync[1:0], RXD};


  wire rxd_r = ~rxd_sync[2] &  rxd_sync[1] & rxd_sync[0];    // late  rising
//wire rxd_f = ~rxd_sync[0] &  rxd_sync[1] & rxd_sync[2];    // early fall
  wire rxd_f = ~rxd_sync[0] & ~rxd_sync[1] & rxd_sync[2];    // late fall

  wire rxd_x = rxd_sync[1] ^ rxd_sync[2];                    // transition (rise or fall)


  // ---------------------------
  enum logic [3:0] { eIDLE,

                     eW4_1STR,

                     eW4_6T,

                     eW4_TR,
                     eLATCH,

                     eEND0,
                     eEND1 } cur_st, nxt_st;


  always_ff @(posedge CLK100M or negedge RST_N)
    if( !RST_N ) 
      cur_st <= eIDLE;
    else
      cur_st <= nxt_st;


  logic [pMSG_WID-1:0] msg_idx;
  wire                 to_6t;      // timeout

  always_comb
    case( cur_st )
      eIDLE:     if( rxd_f )
                   nxt_st = eW4_1STR;
                 else
                   nxt_st = eIDLE;

      eW4_1STR:  if( rxd_r )
                   nxt_st = eW4_6T;
                 else
                   nxt_st = eW4_1STR;

      eW4_6T:    if( to_6t )
                   nxt_st = eW4_TR;
                 else
                   nxt_st = eW4_6T;

      eW4_TR:    if( rxd_x )
                   nxt_st = eLATCH;
                 else
                   nxt_st = eW4_TR;

    //eLATCH:    if( msg_idx < (pMSG_LEN - 1) )
    //change for lint check, when pMSG_LEN == 8
      eLATCH:    if( msg_idx < 3'd7 )
                   nxt_st = eW4_6T;
                 else
                   nxt_st = eEND0;

      eEND0:     nxt_st = eEND1;

      eEND1:     if( rx_idle )
                   nxt_st = eIDLE;
                 else
                   nxt_st = eEND1;

      default:   nxt_st = eIDLE;
    endcase



  logic [4:0] fsm_ctl;

  localparam x0 = 1'b0,
             x1 = 1'b1;

  always_comb
    //                        d   s   l   i   c
    //                        o   h   a   n   l
    //                        n   i   t   c   r
    //                        e   f   c                          
    //                            t   h                      
    case( cur_st )
      eIDLE:      fsm_ctl = {x0, x0, x0, x0, x1};
      eW4_1STR:   fsm_ctl = {x0, x0, x0, x0, x0};
      eW4_6T:     fsm_ctl = {x0, x1, x0, x0, x0};
      eW4_TR:     fsm_ctl = {x0, x0, x0, x0, x0};
      eLATCH:     fsm_ctl = {x0, x0, x1, x1, x0};
      eEND0:      fsm_ctl = {x1, x0, x0, x0, x0};
      eEND1:      fsm_ctl = {x1, x0, x0, x0, x0};
      default:    fsm_ctl = {x0, x0, x0, x0, x1};  
    endcase


  wire done;
  wire shift;
  wire latch;
  wire inc_idx;
  wire clr_idx;


  assign { done,
           shift,
           latch,
           inc_idx,
           clr_idx } = fsm_ctl;

  always_ff @(posedge CLK100M or negedge RST_N)
    if( !RST_N ) 
      msg_idx <= {pMSG_WID{1'b0}};
    else
      if( clr_idx )
        msg_idx <= {pMSG_WID{1'b0}};
      else
        msg_idx <= msg_idx + {{(pMSG_WID-1){1'b0}}, inc_idx};


  logic [5:0] shift_reg;
  always_ff @(posedge CLK100M or negedge RST_N)
    if( !RST_N ) 
      shift_reg <= 6'b00_0001;
    else
      if( clr_idx | inc_idx )
        shift_reg <= 6'b00_0001;
      else
        if( shift )
          shift_reg <= {shift_reg[4:0], 1'b0};;

  assign to_6t = shift_reg[5];
  /*
  logic txd0;
  always_ff @(posedge CLK100M or negedge RST_N)
    if( !RST_N )
      txd <= 1'b1;
    else
      if( inc_idx )
        txd <= ~MSG[msg_idx];
      else
        txd <= ~txd;
  */

  always_ff @(posedge CLK100M or negedge RST_N)
    if( !RST_N )
      MSG <= {pMSG_LEN{1'b0}};
    else
      if( latch )
        MSG[msg_idx] <= rxd_sync[0];


  // -------------------------------------------------
  // 25MHz Clock Domain
  
  logic rx_idle_sync; 
  always_ff @(posedge CLK_25M or negedge RST_N)
    if( !RST_N ) 
      rx_idle_sync <= 1'b0;
    else
      rx_idle_sync <= rx_idle;         // TBD, 100M -> 25M



  always_ff @(posedge CLK_25M or negedge RST_N)
    if( !RST_N ) 
      MSG_VLD <= 1'b0;
    else
      if( rx_idle_sync )
        MSG_VLD <= 1'b0;
      else
        if( done )                     // TBD, 100M -> 25M, "done" keep assert until rx_idle is seen
          MSG_VLD <= 1'b1;


endmodule // MCHT_ENC
