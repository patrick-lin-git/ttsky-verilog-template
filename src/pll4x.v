module PLL4X
(
  input  wire  CLK25I,
  output wire  CLK4XO,
  input  wire  RST_N
);

  // TBD
  assign CLK4XO = RST_N? CLK25I : 1'b0;

endmodule // PLL4X
