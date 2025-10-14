// Generic Standard Cell verilog model
//
//
//`timescale 1ns / 1ps

module DLY1 (
 A,
 Y
);

input  A;
output Y;

`ifdef RTL_SIM

  assign #0.03 Y = A;

`else

`ifdef USE_POWER_PINS

   supply1 VPWR;
   supply0 VGND;
   supply1 VPB;
   supply0 VNB;

   (* keep *) sky130_fd_sc_hd__clkdlybuf4s15_2 bufp ( .X(Y),
                                                      .A(A),
                                                      .VPWR(VPWR),
                                                      .VGND(VGND),
                                                      .VPB(VPB),
                                                      .VNB(VNB)   );

`else

   (* keep *) sky130_fd_sc_hd__clkdlybuf4s15_2 buf0 (.A( A ), .X( Y ));

`endif // USE_POWER_PINS


`endif // RTL_SIM 


endmodule
// Generic Standard Cell verilog model
//
//
//`timescale 1ns / 1ps

module DLY2 (
 A,
 Y
);

input  A;
output Y;

`ifdef RTL_SIM

  assign #0.04 Y = A;

`else

// (* blackbox * ) sky130_fd_sc_hd__clkdlybuf4s18_2 buf0 (.A( A ), .X( Y ));
//                 sky130_fd_sc_hd__clkdlybuf4s18_2 buf0 (.A( A ), .X( Y ));

`ifdef USE_POWER_PINS

   supply1 VPWR;
   supply0 VGND;
   supply1 VPB;
   supply0 VNB;

   (* keep *) sky130_fd_sc_hd__clkdlybuf4s18_2 bufx ( .X(Y),
                                                      .A(A),
                                                      .VPWR(VPWR),
                                                      .VGND(VGND),
                                                      .VPB(VPB),
                                                      .VNB(VNB)   );
`else

   (* keep *) sky130_fd_sc_hd__clkdlybuf4s18_2 buf0 (.A( A ), .X( Y ));

`endif // USE_POWER_PINS

`endif // RTL_SIM

endmodule

// Generic Standard Cell verilog model
//
//
//`timescale 1ns / 1ps

module DLY3 (
 A,
 Y
);

input  A;
output Y;

`ifdef RTL_SIM

  assign #0.05 Y = A;

`else

// (* blackbox * ) sky130_fd_sc_hd__clkdlybuf4s18_1 buf0 (.A( A ), .X( Y ));
//                 sky130_fd_sc_hd__clkdlybuf4s18_1 buf0 (.A( A ), .X( Y ));

`ifdef USE_POWER_PINS

   supply1 VPWR;
   supply0 VGND;
   supply1 VPB;
   supply0 VNB;

   (* keep *) sky130_fd_sc_hd__clkdlybuf4s18_1 bufx ( .X(Y),
                                                      .A(A),
                                                      .VPWR(VPWR),
                                                      .VGND(VGND),
                                                      .VPB(VPB),
                                                      .VNB(VNB)   );

`else

   (* keep *) sky130_fd_sc_hd__clkdlybuf4s18_1 buf0 (.A( A ), .X( Y ));

`endif // USE_POWER_PINS

`endif // RTL_SIM

endmodule
// Generic Standard Cell verilog model
//
//
//`timescale 1ns / 1ps

module DLY4 (
 A,
 Y
);

input  A;
output Y;

`ifdef RTL_SIM

  assign #0.06 Y = A;

`else

// (* blackbox * ) sky130_fd_sc_hd__clkdlybuf4s25_2 buf0 (.A( A ), .X( Y ));
//                 sky130_fd_sc_hd__clkdlybuf4s25_2 buf0 (.A( A ), .X( Y ));


`ifdef USE_POWER_PINS

   supply1 VPWR;
   supply0 VGND;
   supply1 VPB;
   supply0 VNB;

   (* keep *) sky130_fd_sc_hd__clkdlybuf4s25_2 bufx ( .X(Y),
                                                      .A(A),
                                                      .VPWR(VPWR),
                                                      .VGND(VGND),
                                                      .VPB(VPB),
                                                      .VNB(VNB)   );

`else

   (* keep *) sky130_fd_sc_hd__clkdlybuf4s25_2 buf0 (.A( A ), .X( Y ));

`endif // USE_POWER_PINS

`endif // RTL_SIM

endmodule
// Generic Standard Cell verilog model
//
//
//`timescale 1ns / 1ps

module DLY5 (
 A,
 Y
);

input  A;
output Y;

`ifdef RTL_SIM

  assign #0.07 Y = A;

`else

// (* blackbox * ) sky130_fd_sc_hd__clkdlybuf4s25_1 buf0 (.A( A ), .X( Y ));
//                 sky130_fd_sc_hd__clkdlybuf4s25_1 buf0 (.A( A ), .X( Y ));


`ifdef USE_POWER_PINS

   supply1 VPWR;
   supply0 VGND;
   supply1 VPB;
   supply0 VNB;

   (* keep *) sky130_fd_sc_hd__clkdlybuf4s25_1 bufx ( .X(Y),
                                                      .A(A),
                                                      .VPWR(VPWR),
                                                      .VGND(VGND),
                                                      .VPB(VPB),
                                                      .VNB(VNB)   );

`else

   (* keep *) sky130_fd_sc_hd__clkdlybuf4s25_1 buf0 (.A( A ), .X( Y ));

`endif // USE_POWER_PINS

`endif // RTL_SIM

endmodule
// Generic Standard Cell verilog model
//
//
//`timescale 1ns / 1ps

// (* keep *) module DLY7 (
module DLY7 (
 A,
 Y
);

input  A;
output Y;

`ifdef RTL_SIM

  assign #0.100 Y = A;

`else

// (* blackbox * ) sky130_fd_sc_hd__clkdlybuf4s50_2 buf0 (.A( A ), .X( Y ));
//                 sky130_fd_sc_hd__clkdlybuf4s50_2 buf0 (.A( A ), .X( Y ));


`ifdef USE_POWER_PINS

   supply1 VPWR;
   supply0 VGND;
   supply1 VPB;
   supply0 VNB;

   (* keep *) sky130_fd_sc_hd__clkdlybuf4s50_2 bufx ( .X(Y),
                                                      .A(A),
                                                      .VPWR(VPWR),
                                                      .VGND(VGND),
                                                      .VPB(VPB),
                                                      .VNB(VNB)   );
`else

   (* keep *) sky130_fd_sc_hd__clkdlybuf4s50_2 buf0 (.A( A ), .X( Y ));

`endif // USE_POWER_PINS

`endif // RTL_SIM

endmodule
// Generic Standard Cell verilog model
//
//
//`timescale 1ns / 1ps

module DLY9 (
 A,
 Y
);

input  A;
output Y;

`ifdef RTL_SIM

  assign #0.20 Y = A;

`else

// (* blackbox * ) sky130_fd_sc_hd__clkdlybuf4s50_1 buf0 (.A( A ), .X( Y ));
//                 sky130_fd_sc_hd__clkdlybuf4s50_1 buf0 (.A( A ), .X( Y ));


`ifdef USE_POWER_PINS

   supply1 VPWR;
   supply0 VGND;
   supply1 VPB;
   supply0 VNB;

   (* keep *) sky130_fd_sc_hd__clkdlybuf4s50_1 bufx ( .X(Y),
                                                      .A(A),
                                                      .VPWR(VPWR),
                                                      .VGND(VGND),
                                                      .VPB(VPB),
                                                      .VNB(VNB)   );
`else

   (* keep *) sky130_fd_sc_hd__clkdlybuf4s50_1 buf0 (.A( A ), .X( Y ));

`endif // USE_POWER_PINS

`endif // RTL_SIM

endmodule
// Generic Standard Cell verilog model
//
//
//`timescale 1ns / 1ps

module INV (
 A,
 Y
);

input  A;
output Y;

`ifdef RTL_SIM

  assign #0.030 Y = ~A;

`else

  assign        Y = ~A;

`endif // RTL_SIM

endmodule
// Generic Standard Cell verilog model
//
//
//`timescale 1ns / 1ps

module MUX2_1 (
 A,
 B,
 S,
 Y
);

input  A;
input  B;
input  S;
output Y;

`ifdef RTL_SIM

  assign #0.040 Y = S? B : A;

`else

  assign        Y = S? B : A;

`endif // RTL_SIM

endmodule
