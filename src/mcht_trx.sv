module MCHT_TRX #(parameter pTX_MSG_LEN = 16,
                            pRX_MSG_LEN = 16)
(
  // I/O
  output  logic                   TXD,
  input   wire                    RXD,

  // Tx
  input   wire                    TX_VLD,
  input   wire  [pTX_MSG_LEN-1:0] TX_MSG,
  output  wire                    TX_DNE, 
 
  // Rx
  output  logic [pRX_MSG_LEN-1:0] RX_MSG,
  output  logic                   RX_VLD,

  // -----
  input   wire                    CLK_25M,
  input   wire                    CLK100M,
  input   wire                    RST_N
);



//defparam u_mcht_enc_0.pMSG_LEN = pTX_MSG_LEN;
  MCHT_ENC #(.pMSG_LEN( pTX_MSG_LEN )) u_mcht_enc_0 (
                                                     .SOF        ( TX_VLD ),     // I
                                                     .MSG        ( TX_MSG ),     // I pMSG_LEN
                                                     .DONE       ( TX_DNE ),     // O
                                                     .TXD        ( TXD ),        // O
                                                     .CLK_25M    ( CLK_25M ),    // I
                                                     .RST_N      ( RST_N )       // I
                                                    );
  
  
//defparam u_mcht_dec_0.pMSG_LEN = pRX_MSG_LEN;
  MCHT_DEC #(.pMSG_LEN( pRX_MSG_LEN )) u_mcht_dec_0 (
                                                     .MSG        ( RX_MSG ),     // O pMSG_LEN
                                                     .MSG_VLD    ( RX_VLD ),     // O
                                                     .RXD        ( RXD ),        // I
                                                     .CLK_25M    ( CLK_25M ),    // I
                                                     .CLK100M    ( CLK100M ),    // I
                                                     .RST_N      ( RST_N )       // I
                                                    );



endmodule // MCHT_TRX
