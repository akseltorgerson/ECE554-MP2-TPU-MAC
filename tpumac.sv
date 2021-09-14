// Spec v1.1
module tpumac
 #(parameter BITS_AB=8,
   parameter BITS_C=16)
  (
   input clk, rst_n, WrEn, en,
   input signed [BITS_AB-1:0] Ain,
   input signed [BITS_AB-1:0] Bin,
   input signed [BITS_C-1:0] Cin,
   output reg signed [BITS_AB-1:0] Aout,
   output reg signed [BITS_AB-1:0] Bout,
   output reg signed [BITS_C-1:0] Cout
  );
  
  logic signed [BITS_C-1:0] Cout_add;
  // chagne to non-literal values later
  logic signed [15:0] AB_mul;

  always_ff @(posedge clk, negedge rst_n) begin
  
    if (~rst_n) begin
      Aout <= 0;
      Bout <= 0;
      Cout <= 0;
    end
    else if (en) begin
      Aout <= Ain;
      Bout <= Bin;
      Cout <= Cout_add;
    end

  end

  assign Cout_add = WrEn ? Cin : Cout + AB_mul;
  assign AB_mul = Ain * Bin;

endmodule
